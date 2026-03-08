const { pool } = require('../config/database');
const { generateOTP } = require('../utils/helpers');
const { signCiudadano } = require('../utils/jwt');
const { sendOTP } = require('../services/emailService');
const logger = require('../utils/logger');

const OTP_EXPIRATION_MINUTES = parseInt(process.env.OTP_EXPIRATION_MINUTES || '15');

/**
 * POST /auth/otp/solicitar
 * Genera y envía un OTP al email indicado (RN-04)
 */
async function solicitarOTP(req, res, next) {
  try {
    const { email } = req.body;

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: 'Email con formato inválido' });
    }

    const codigo = generateOTP();
    const expiracion = new Date(Date.now() + OTP_EXPIRATION_MINUTES * 60 * 1000);

    // Invalidar OTPs anteriores para este email
    await pool.execute(
      `UPDATE otp_session SET usado = 1 WHERE email = ? AND usado = 0`,
      [email]
    );

    // Insertar nuevo OTP
    await pool.execute(
      `INSERT INTO otp_session (email, codigo, expiracion, usado, fecha_creacion)
       VALUES (?, ?, ?, 0, NOW())`,
      [email, codigo, expiracion]
    );

    await sendOTP(email, codigo);

    logger.info(`OTP generado para ${email}`);
    return res.status(200).json({
      mensaje: 'Código enviado al email indicado',
      expira_en_segundos: OTP_EXPIRATION_MINUTES * 60,
    });
  } catch (err) {
    if (err.code === 'ECONNREFUSED' || err.responseCode) {
      logger.error('Error SMTP:', err.message);
      return res.status(500).json({ error: 'Error al enviar el email' });
    }
    next(err);
  }
}

/**
 * POST /auth/otp/verificar
 * Verifica el OTP y emite JWT ciudadano (RN-04)
 */
async function verificarOTP(req, res, next) {
  try {
    const { email, codigo } = req.body;

    if (!email || !codigo) {
      return res.status(400).json({ error: 'Email y código son requeridos' });
    }

    // Buscar OTP válido
    const [rows] = await pool.execute(
      `SELECT id FROM otp_session
       WHERE email = ? AND codigo = ? AND usado = 0 AND expiracion > NOW()
       LIMIT 1`,
      [email, codigo]
    );

    if (rows.length === 0) {
      // Distinguir "no encontrado" de "expirado/ya usado"
      const [exists] = await pool.execute(
        `SELECT id FROM otp_session WHERE email = ? AND codigo = ? LIMIT 1`,
        [email, codigo]
      );
      if (exists.length === 0) {
        return res.status(404).json({ error: 'OTP no encontrado para ese email' });
      }
      return res.status(400).json({ error: 'Código incorrecto, expirado o ya usado' });
    }

    // Marcar como usado
    await pool.execute(
      `UPDATE otp_session SET usado = 1 WHERE id = ?`,
      [rows[0].id]
    );

    const token = signCiudadano(email);

    return res.status(200).json({
      token,
      tipo: 'Bearer',
      expira_en: 3600,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { solicitarOTP, verificarOTP };
