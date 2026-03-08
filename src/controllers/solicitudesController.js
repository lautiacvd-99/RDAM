const { pool } = require('../config/database');
const { normalizeCUIL, formatCUIL } = require('../utils/helpers');
const { registrarTransicion } = require('../models/historial');
const logger = require('../utils/logger');

const CIUDADES_VALIDAS = ['SANTA_FE', 'ROSARIO', 'VENADO_TUERTO', 'RECONQUISTA', 'RAFAELA'];

async function crearSolicitud(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const { cuil, ciudad } = req.body;
    const emailCiudadano = req.user.email;

    const cuilNorm = normalizeCUIL(cuil || '');
    if (!cuilNorm) {
      return res.status(400).json({ error: 'CUIL inválido (debe tener 11 dígitos numéricos)' });
    }

    if (!ciudad || !CIUDADES_VALIDAS.includes(ciudad)) {
      return res.status(400).json({
        error: `Ciudad inválida. Valores permitidos: ${CIUDADES_VALIDAS.join(', ')}`,
      });
    }

    await conn.beginTransaction();

    const [result] = await conn.execute(
      `INSERT INTO solicitud (cuil, email_ciudadano, ciudad, estado, fecha_creacion)
       VALUES (?, ?, ?, 'PENDIENTE_PAGO', NOW())`,
      [cuilNorm, emailCiudadano, ciudad]
    );

    const solicitudId = result.insertId;

    await registrarTransicion(conn, {
      solicitudId,
      estadoAnterior: null,
      estadoNuevo: 'PENDIENTE_PAGO',
      usuarioId: null,
      observacion: 'Solicitud creada por ciudadano',
    });

    await conn.commit();

    logger.info(`Solicitud #${solicitudId} creada para ${emailCiudadano}`);

    return res.status(201).json({
      id: solicitudId,
      cuil: formatCUIL(cuilNorm),
      ciudad,
      email_ciudadano: emailCiudadano,
      estado: 'PENDIENTE_PAGO',
      fecha_creacion: new Date().toISOString(),
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

async function getMisSolicitudes(req, res, next) {
  try {
    const [rows] = await pool.execute(
      `SELECT id, cuil, ciudad, estado, fecha_creacion
       FROM solicitud
       WHERE email_ciudadano = ?
       ORDER BY fecha_creacion DESC`,
      [req.user.email]
    );
    return res.status(200).json(rows);
  } catch (err) {
    next(err);
  }
}

/**
 * GET /solicitudes/:id/historial        → solo el ciudadano dueño (token tipo ciudadano)
 * GET /operador/solicitudes/:id/historial → operador o admin (token tipo interno)
 *
 * Ambas rutas usan esta misma función. El middleware de cada ruta
 * garantiza el tipo de token correcto antes de llegar acá.
 */
async function getHistorialSolicitud(req, res, next) {
  try {
    const { id } = req.params;

    const [solicitudes] = await pool.execute(
      `SELECT id, email_ciudadano FROM solicitud WHERE id = ?`,
      [id]
    );

    if (solicitudes.length === 0) {
      return res.status(404).json({ error: 'Solicitud no encontrada' });
    }

    // Si es ciudadano, verificar que sea el dueño de la solicitud
    if (req.user.tipo === 'ciudadano' && solicitudes[0].email_ciudadano !== req.user.email) {
      return res.status(403).json({ error: 'No tenés permiso para ver esta solicitud' });
    }

    const { getHistorial } = require('../models/historial');
    const historial = await getHistorial(id);

    return res.status(200).json(historial);
  } catch (err) {
    next(err);
  }
}

/**
 * GET /solicitudes/:id/certificado
 * Devuelve el PDF de resolución si está disponible.
 * Aplica a estados: APROBADA, RECHAZADA, CERTIFICADO_EMITIDO
 */
async function getCertificado(req, res, next) {
  try {
    const { id } = req.params;
    const { registrar } = require('../models/auditoria');

    const [rows] = await pool.execute(
      `SELECT s.id, s.email_ciudadano, s.estado, r.url_pdf, r.observaciones, r.resultado
       FROM solicitud s
       LEFT JOIN resolucion r ON r.solicitud_id = s.id
       WHERE s.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Solicitud no encontrada' });
    }

    const solicitud = rows[0];

    if (solicitud.email_ciudadano !== req.user.email) {
      return res.status(403).json({ error: 'No tenés permiso para acceder a este certificado' });
    }

    const estadosConDocumento = ['CERTIFICADO_EMITIDO', 'APROBADA', 'RECHAZADA'];
    if (!estadosConDocumento.includes(solicitud.estado) || !solicitud.url_pdf) {
      return res.status(404).json({ error: 'Certificado aún no disponible' });
    }

    await registrar({
      usuarioId: null,
      solicitudId: id,
      accion: 'CERTIFICADO_DESCARGADO',
      ipOrigen: req.ip,
    });

    return res.status(200).json({
      url_pdf: solicitud.url_pdf,
      estado: solicitud.estado,
      resultado: solicitud.resultado,
      observaciones: solicitud.observaciones || null,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { crearSolicitud, getMisSolicitudes, getHistorialSolicitud, getCertificado };
