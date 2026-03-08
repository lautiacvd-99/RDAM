const { pool } = require('../config/database');
const { registrarTransicion } = require('../models/historial');
const { registrar } = require('../models/auditoria');
const { sendCertificadoDisponible, sendSolicitudRechazada } = require('../services/emailService');
const logger = require('../utils/logger');

async function listarSolicitudes(req, res, next) {
  try {
    const { ciudad, estado } = req.query;
    let query = `
      SELECT s.id, s.cuil, s.ciudad, s.estado, s.email_ciudadano, s.fecha_creacion,
             r.usuario_operario_id as operador_asignado,
             r.resultado            as resolucion_resultado,
             r.url_pdf              as resolucion_url_pdf,
             r.observaciones        as resolucion_observaciones,
             r.fecha_emision        as resolucion_fecha_emision
      FROM solicitud s
      LEFT JOIN resolucion r ON r.solicitud_id = s.id
      WHERE 1=1
    `;
    const params = [];

    if (ciudad) { query += ` AND s.ciudad = ?`; params.push(ciudad); }
    if (estado) { query += ` AND s.estado = ?`; params.push(estado); }

    query += ` ORDER BY s.fecha_creacion ASC`;
    const [rows] = await pool.execute(query, params);
    return res.status(200).json(rows);
  } catch (err) {
    next(err);
  }
}

async function tomarSolicitud(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const { id } = req.params;

    const [rows] = await conn.execute(
      `SELECT id, estado FROM solicitud WHERE id = ? FOR UPDATE`,
      [id]
    );

    if (rows.length === 0) return res.status(404).json({ error: 'Solicitud no encontrada' });
    if (rows[0].estado !== 'PENDIENTE_REVISION') {
      return res.status(409).json({ error: `Estado actual: ${rows[0].estado}. Se requiere PENDIENTE_REVISION` });
    }

    await conn.beginTransaction();

    await conn.execute(`UPDATE solicitud SET estado = 'EN_REVISION' WHERE id = ?`, [id]);
    await registrarTransicion(conn, {
      solicitudId: id,
      estadoAnterior: 'PENDIENTE_REVISION',
      estadoNuevo: 'EN_REVISION',
      usuarioId: req.user.id,
    });

    await conn.commit();
    return res.status(200).json({ id: parseInt(id), estado: 'EN_REVISION' });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

/**
 * POST /operador/solicitudes/:id/resolucion
 * Recibe multipart/form-data con campos: resultado, observaciones + archivo pdf
 */
async function emitirResolucion(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const { id } = req.params;
    const { resultado, observaciones } = req.body;
    const archivo = req.file;

    if (!['APROBADO', 'RECHAZADO'].includes(resultado)) {
      return res.status(400).json({ error: 'resultado debe ser APROBADO o RECHAZADO' });
    }

    if (resultado === 'RECHAZADO' && !observaciones) {
      return res.status(400).json({ error: 'observaciones es obligatorio cuando resultado es RECHAZADO' });
    }

    if (!archivo) {
      return res.status(400).json({ error: 'El archivo PDF es obligatorio' });
    }

    const [rows] = await conn.execute(
      `SELECT s.id, s.estado, s.email_ciudadano FROM solicitud s WHERE s.id = ? FOR UPDATE`,
      [id]
    );

    if (rows.length === 0) return res.status(404).json({ error: 'Solicitud no encontrada' });
    if (rows[0].estado !== 'EN_REVISION') {
      return res.status(409).json({ error: `Estado actual: ${rows[0].estado}. Se requiere EN_REVISION` });
    }

    await conn.beginTransaction();

    const nuevoEstado = resultado === 'APROBADO' ? 'APROBADA' : 'RECHAZADA';

    const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:3001';
    const url_pdf = `${BACKEND_URL}/storage/pdfs/${archivo.filename}`;

    const [resResult] = await conn.execute(
      `INSERT INTO resolucion (solicitud_id, usuario_operario_id, resultado, url_pdf, observaciones, fecha_emision)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [id, req.user.id, resultado, url_pdf, observaciones || null]
    );

    await conn.execute(`UPDATE solicitud SET estado = ? WHERE id = ?`, [nuevoEstado, id]);

    await registrarTransicion(conn, {
      solicitudId: id,
      estadoAnterior: 'EN_REVISION',
      estadoNuevo: nuevoEstado,
      usuarioId: req.user.id,
      observacion: observaciones || null,
    });

    await conn.commit();

    await registrar({
      usuarioId: req.user.id,
      solicitudId: id,
      accion: 'RESOLUCION_EMITIDA',
      ipOrigen: req.ip,
      detalle: `resultado: ${resultado}`,
    });

    if (resultado === 'RECHAZADO') {
      sendSolicitudRechazada(rows[0].email_ciudadano, id, observaciones).catch(logger.error);
    }

    return res.status(201).json({
      id: resResult.insertId,
      solicitud_id: parseInt(id),
      resultado,
      estado_solicitud: nuevoEstado,
      url_pdf,
      observaciones: observaciones || null,
      fecha_emision: new Date().toISOString(),
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

async function certificadoEmitido(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const { id } = req.params;
    const { url_pdf } = req.body;

    if (!url_pdf) return res.status(400).json({ error: 'url_pdf es requerido' });

    const [rows] = await conn.execute(
      `SELECT s.id, s.estado, s.email_ciudadano FROM solicitud s WHERE s.id = ? FOR UPDATE`,
      [id]
    );

    if (rows.length === 0) return res.status(404).json({ error: 'Solicitud no encontrada' });
    if (rows[0].estado !== 'APROBADA') {
      return res.status(409).json({ error: `Estado actual: ${rows[0].estado}. Se requiere APROBADA` });
    }

    await conn.beginTransaction();

    await conn.execute(`UPDATE resolucion SET url_pdf = ? WHERE solicitud_id = ?`, [url_pdf, id]);
    await conn.execute(`UPDATE solicitud SET estado = 'CERTIFICADO_EMITIDO' WHERE id = ?`, [id]);

    await registrarTransicion(conn, {
      solicitudId: id,
      estadoAnterior: 'APROBADA',
      estadoNuevo: 'CERTIFICADO_EMITIDO',
      usuarioId: req.user.id || null,
      observacion: 'PDF generado y almacenado',
    });

    await conn.commit();

    sendCertificadoDisponible(rows[0].email_ciudadano, id).catch(logger.error);

    return res.status(200).json({ solicitud_id: parseInt(id), estado: 'CERTIFICADO_EMITIDO', url_pdf });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

module.exports = { listarSolicitudes, tomarSolicitud, emitirResolucion, certificadoEmitido };
