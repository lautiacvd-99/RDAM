const { pool } = require('../config/database');
const { registrarTransicion } = require('../models/historial');
const logger = require('../utils/logger');
const { buildCheckoutHtml, parseWebhookPayload } = require('../services/pluspagosService');

/**
 * POST /pagos/iniciar
 *
 * Registra intención de pago y devuelve la URL del endpoint de checkout.
 * El frontend navega a checkout_url para que el HTML del form redirija al usuario.
 */
// Monto institucional del certificado — configurable por variable de entorno
const MONTO_CERTIFICADO = parseFloat(process.env.MONTO_CERTIFICADO || '2500');

async function iniciarPago(req, res, next) {
  try {
    const { solicitud_id } = req.body;

    const [rows] = await pool.execute(
      `SELECT id, estado, email_ciudadano FROM solicitud WHERE id = ? AND email_ciudadano = ?`,
      [solicitud_id, req.user.email]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Solicitud no encontrada' });
    }

    if (rows[0].estado !== 'PENDIENTE_PAGO') {
      return res.status(409).json({ error: `La solicitud no está en PENDIENTE_PAGO (estado actual: ${rows[0].estado})` });
    }

    const { transaccionComercioId } = buildCheckoutHtml({
      solicitudId: solicitud_id,
      montoARS:    MONTO_CERTIFICADO,
      descripcion: `Certificado RDAM - Solicitud #${solicitud_id}`,
    });

    await pool.execute(
      `INSERT INTO pago (solicitud_id, transaccion_id, estado_pago, monto, fecha_pago)
       VALUES (?, ?, 'PENDIENTE', ?, NOW())
       ON DUPLICATE KEY UPDATE estado_pago = 'PENDIENTE', fecha_pago = NOW()`,
      [solicitud_id, transaccionComercioId, MONTO_CERTIFICADO]
    );

    logger.info(`Pago iniciado: solicitud #${solicitud_id}, txn comercio ${transaccionComercioId}`);

    return res.status(200).json({
      mensaje: 'Pago iniciado',
      solicitud_id,
      transaccion_comercio_id: transaccionComercioId,
      checkout_url: `/api/pagos/${solicitud_id}/checkout`,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /pagos/:id/checkout
 *
 * Devuelve HTML que auto-redirige al navegador del ciudadano a PlusPagos.
 */
async function checkoutPago(req, res, next) {
  try {
    const solicitudId = req.params.id;

    const [rows] = await pool.execute(
      `SELECT s.id, s.estado, p.monto, p.transaccion_id
       FROM solicitud s
       JOIN pago p ON p.solicitud_id = s.id
       WHERE s.id = ? AND s.email_ciudadano = ?
       ORDER BY p.fecha_pago DESC LIMIT 1`,
      [solicitudId, req.user.email]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Pago no encontrado para esta solicitud' });
    }

    if (rows[0].estado !== 'PENDIENTE_PAGO') {
      return res.status(409).json({ error: 'La solicitud ya no está en PENDIENTE_PAGO' });
    }

    const { redirectHtml } = buildCheckoutHtml({
      solicitudId,
      montoARS:    rows[0].monto,
      descripcion: `Certificado RDAM - Solicitud #${solicitudId}`,
    });

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.send(redirectHtml);
  } catch (err) {
    next(err);
  }
}

/**
 * GET /pagos/:id/estado
 */
async function estadoPago(req, res, next) {
  try {
    const [rows] = await pool.execute(
      `SELECT p.id, p.solicitud_id, p.transaccion_id, p.estado_pago, p.monto, p.fecha_pago
       FROM pago p
       JOIN solicitud s ON s.id = p.solicitud_id
       WHERE p.id = ? AND s.email_ciudadano = ?`,
      [req.params.id, req.user.email]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Pago no encontrado' });
    }

    return res.status(200).json(rows[0]);
  } catch (err) {
    next(err);
  }
}

/**
 * POST /pagos/webhook
 *
 * Recibe la notificación de PlusPagos cuando el pago fue REALIZADO (EstadoId "3").
 * No requiere HMAC propio: la seguridad la garantiza el TransaccionComercioId firmado
 * con el SECRET_KEY compartido (solo PlusPagos puede haberlo generado).
 */
async function webhookPago(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const parsed = parseWebhookPayload(req.body);

    if (!parsed.solicitudId) {
      logger.warn('Webhook PlusPagos: TransaccionComercioId sin formato RDAM válido', req.body);
      return res.status(400).json({ error: 'TransaccionComercioId inválido' });
    }

    // Si el pago fue rechazado, delegar
    if (!parsed.aprobado) {
      conn.release();
      return webhookFallido(req, res, next);
    }

    const [rows] = await conn.execute(
      `SELECT id, estado FROM solicitud WHERE id = ? FOR UPDATE`,
      [parsed.solicitudId]
    );

    if (rows.length === 0 || rows[0].estado !== 'PENDIENTE_PAGO') {
      return res.status(400).json({ error: 'Solicitud no apta para procesar pago' });
    }

    await conn.beginTransaction();

    await conn.execute(
      `INSERT INTO pago (solicitud_id, transaccion_id, estado_pago, monto, metadata_webhook, fecha_pago)
       VALUES (?, ?, 'APROBADO', ?, ?, NOW())
       ON DUPLICATE KEY UPDATE estado_pago = 'APROBADO'`,
      [parsed.solicitudId, parsed.transaccionPlataformaId, parsed.monto, JSON.stringify(parsed.raw)]
    );

    // PENDIENTE_PAGO → PAGADA → PENDIENTE_REVISION (automático)
    await conn.execute(`UPDATE solicitud SET estado = 'PAGADA' WHERE id = ?`, [parsed.solicitudId]);
    await registrarTransicion(conn, {
      solicitudId:    parsed.solicitudId,
      estadoAnterior: 'PENDIENTE_PAGO',
      estadoNuevo:    'PAGADA',
      usuarioId:      null,
      observacion:    `Confirmado por PlusPagos. TransaccionPlataformaId: ${parsed.transaccionPlataformaId}`,
    });

    await conn.execute(`UPDATE solicitud SET estado = 'PENDIENTE_REVISION' WHERE id = ?`, [parsed.solicitudId]);
    await registrarTransicion(conn, {
      solicitudId:    parsed.solicitudId,
      estadoAnterior: 'PAGADA',
      estadoNuevo:    'PENDIENTE_REVISION',
      usuarioId:      null,
      observacion:    'Transición automática post-pago',
    });

    await conn.commit();

    logger.info(`Webhook PlusPagos OK: solicitud #${parsed.solicitudId}, plataforma txn ${parsed.transaccionPlataformaId}`);
    return res.status(200).json({ recibido: true });
  } catch (err) {
    await conn.rollback();
    if (err.code === 'ER_DUP_ENTRY') {
      logger.warn('Webhook PlusPagos duplicado, ya procesado.');
      return res.status(200).json({ recibido: true, nota: 'Ya procesado' });
    }
    next(err);
  } finally {
    conn.release();
  }
}

/**
 * POST /pagos/webhook/fallido
 *
 * Pago rechazado o cancelado por el usuario.
 */
async function webhookFallido(req, res, next) {
  try {
    const parsed = parseWebhookPayload(req.body);

    if (parsed.solicitudId) {
      await pool.execute(
        `INSERT INTO pago (solicitud_id, transaccion_id, estado_pago, metadata_webhook, fecha_pago)
         VALUES (?, ?, 'FALLIDO', ?, NOW())`,
        [parsed.solicitudId, parsed.transaccionPlataformaId || `FAIL-${Date.now()}`, JSON.stringify(parsed.raw)]
      );
      logger.info(`Pago fallido/cancelado: solicitud #${parsed.solicitudId}`);
    }

    return res.status(200).json({ recibido: true });
  } catch (err) {
    next(err);
  }
}

module.exports = { iniciarPago, checkoutPago, estadoPago, webhookPago, webhookFallido };