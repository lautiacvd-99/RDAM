const { pool } = require('../config/database');

/**
 * Registra una transición de estado en historial_estado_solicitud.
 * Debe usarse SIEMPRE dentro de una transacción cuando se cambia el estado de una solicitud (RN-08).
 */
async function registrarTransicion(conn, { solicitudId, estadoAnterior, estadoNuevo, usuarioId = null, observacion = null }) {
  await conn.execute(
    `INSERT INTO historial_estado_solicitud 
       (solicitud_id, estado_anterior, estado_nuevo, usuario_id, observacion, fecha)
     VALUES (?, ?, ?, ?, ?, NOW())`,
    [solicitudId, estadoAnterior || null, estadoNuevo, usuarioId, observacion]
  );
}

async function getHistorial(solicitudId) {
  const [rows] = await pool.execute(
    `SELECT id, estado_anterior, estado_nuevo, usuario_id, observacion, fecha
     FROM historial_estado_solicitud
     WHERE solicitud_id = ?
     ORDER BY id ASC`,
    [solicitudId]
  );
  return rows;
}

module.exports = { registrarTransicion, getHistorial };
