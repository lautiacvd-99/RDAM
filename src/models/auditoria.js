const { pool } = require('../config/database');

/**
 * Registra una acción en la tabla auditoria.
 * No lanza error para no romper el flujo principal.
 */
async function registrar({ usuarioId, solicitudId, accion, ipOrigen, detalle = null }) {
  try {
    await pool.execute(
      `INSERT INTO auditoria (usuario_id, solicitud_id, accion, ip_origen, detalle, fecha)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [usuarioId || null, solicitudId || null, accion, ipOrigen || null, detalle]
    );
  } catch (err) {
    // Auditoria nunca interrumpe el flujo
    const logger = require('../utils/logger');
    logger.error('Error al registrar auditoría:', err.message);
  }
}

module.exports = { registrar };
