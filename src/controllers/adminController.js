const bcrypt = require('bcryptjs');
const { pool } = require('../config/database');
const { signInterno } = require('../utils/jwt');
const { registrar } = require('../models/auditoria');
const logger = require('../utils/logger');

/**
 * POST /admin/auth/login
 */
async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email y password requeridos' });
    }

    const [rows] = await pool.execute(
      `SELECT id, nombre, email, password_hash, rol, activo FROM usuario WHERE email = ?`,
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Credenciales incorrectas' });
    }

    const usuario = rows[0];

    if (!usuario.activo) {
      return res.status(403).json({ error: 'Usuario desactivado' });
    }

    const passwordOk = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordOk) {
      return res.status(401).json({ error: 'Credenciales incorrectas' });
    }

    const token = signInterno(usuario);

    await registrar({
      usuarioId: usuario.id,
      accion: 'LOGIN',
      ipOrigen: req.ip,
    });

    return res.status(200).json({
      token,
      tipo: 'Bearer',
      rol: usuario.rol,
      expira_en: 28800,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/usuarios
 */
async function crearUsuario(req, res, next) {
  try {
    const { nombre, email, password, rol } = req.body;

    if (!nombre || !email || !password || !['ADMIN', 'OPERADOR'].includes(rol)) {
      return res.status(400).json({ error: 'Datos inválidos o rol no permitido' });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const [result] = await pool.execute(
      `INSERT INTO usuario (nombre, email, password_hash, rol, activo, fecha_creacion)
       VALUES (?, ?, ?, ?, 1, NOW())`,
      [nombre, email, passwordHash, rol]
    );

    const userId = result.insertId;

    await registrar({
      usuarioId: req.user.id,
      accion: 'USUARIO_CREADO',
      ipOrigen: req.ip,
      detalle: `email: ${email}, rol: ${rol}`,
    });

    return res.status(201).json({
      id: userId,
      nombre,
      email,
      rol,
      activo: true,
      fecha_creacion: new Date().toISOString(),
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email ya registrado' });
    }
    next(err);
  }
}

/**
 * GET /admin/usuarios
 */
async function listarUsuarios(req, res, next) {
  try {
    const { activo, rol } = req.query;
    let query = `SELECT id, nombre, email, rol, activo, fecha_creacion, fecha_desactivacion FROM usuario WHERE 1=1`;
    const params = [];

    if (activo !== undefined) {
      query += ` AND activo = ?`;
      params.push(activo === 'true' ? 1 : 0);
    }
    if (rol) {
      query += ` AND rol = ?`;
      params.push(rol);
    }

    query += ` ORDER BY fecha_creacion DESC`;
    const [rows] = await pool.execute(query, params);
    return res.status(200).json(rows);
  } catch (err) {
    next(err);
  }
}

/**
 * PATCH /admin/usuarios/:id/desactivar
 */
async function desactivarUsuario(req, res, next) {
  try {
    const { id } = req.params;

    // RN-07: admin no puede desactivarse a sí mismo
    if (parseInt(id) === req.user.id) {
      return res.status(400).json({ error: 'No podés desactivarte a vos mismo (RN-07)' });
    }

    const [rows] = await pool.execute(
      `SELECT id, activo FROM usuario WHERE id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const now = new Date();
    await pool.execute(
      `UPDATE usuario SET activo = 0, fecha_desactivacion = ? WHERE id = ?`,
      [now, id]
    );

    await registrar({
      usuarioId: req.user.id,
      accion: 'USUARIO_DESACTIVADO',
      ipOrigen: req.ip,
      detalle: `usuario_id: ${id}`,
    });

    return res.status(200).json({
      id: parseInt(id),
      activo: false,
      fecha_desactivacion: now.toISOString(),
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/auditoria
 */
async function getAuditoria(req, res, next) {
  try {
    const { usuario_id, solicitud_id, accion, desde, hasta, page = 1, limit = 50 } = req.query;

    let query = `SELECT id, usuario_id, accion, solicitud_id, detalle, ip_origen, fecha FROM auditoria WHERE 1=1`;
    const params = [];

    if (usuario_id) { query += ` AND usuario_id = ?`; params.push(usuario_id); }
    if (solicitud_id) { query += ` AND solicitud_id = ?`; params.push(solicitud_id); }
    if (accion) { query += ` AND accion = ?`; params.push(accion); }
    if (desde) { query += ` AND fecha >= ?`; params.push(desde); }
    if (hasta) { query += ` AND fecha <= ?`; params.push(hasta); }

    query += ` ORDER BY fecha DESC LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), (parseInt(page) - 1) * parseInt(limit));

    const [rows] = await pool.execute(query, params);
    return res.status(200).json(rows);
  } catch (err) {
    next(err);
  }
}
/**
 * PATCH /admin/usuarios/:id/reset-password
 * Admin resetea la password de un operario (RN-07: no puede resetearse a sí mismo)
 */
async function resetPassword(req, res, next) {
  try {
    const { id } = req.params;
    const { nueva_password } = req.body;

    // RN-07 extendida: admin no puede resetear su propia password por esta vía
    if (parseInt(id) === req.user.id) {
      return res.status(400).json({ error: 'No podés resetear tu propia password por esta vía' });
    }

    // Validaciones
    if (!nueva_password) {
      return res.status(400).json({ error: 'nueva_password es requerida' });
    }
    if (nueva_password.length < 8) {
      return res.status(400).json({ error: 'La password debe tener al menos 8 caracteres' });
    }
    if (!/[A-Z]/.test(nueva_password)) {
      return res.status(400).json({ error: 'La password debe contener al menos una mayúscula' });
    }
    if (!/[0-9]/.test(nueva_password)) {
      return res.status(400).json({ error: 'La password debe contener al menos un número' });
    }

    // Verificar que el usuario existe
    const [rows] = await pool.execute(
      `SELECT id, email, nombre FROM usuario WHERE id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    // Hashear nueva password
    const passwordHash = await bcrypt.hash(nueva_password, 12);

    await pool.execute(
      `UPDATE usuario SET password_hash = ? WHERE id = ?`,
      [passwordHash, id]
    );

    // Registrar en auditoría
    await registrar({
      usuarioId: req.user.id,
      accion: 'PASSWORD_RESETEADA',
      ipOrigen: req.ip,
      detalle: `usuario_id: ${id}, email: ${rows[0].email}`,
    });

    logger.info(`Password reseteada por admin para usuario #${id} (${rows[0].email})`);

    return res.status(200).json({
      mensaje: 'Password actualizada correctamente',
      usuario_id: parseInt(id),
      email: rows[0].email,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { login, crearUsuario, listarUsuarios, desactivarUsuario, getAuditoria, resetPassword };
