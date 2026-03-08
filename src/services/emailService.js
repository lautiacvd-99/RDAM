const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

function createTransporter() {
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

async function sendOTP(email, codigo) {
  const transporter = createTransporter();
  const expMin = process.env.OTP_EXPIRATION_MINUTES || 15;
  await transporter.sendMail({
    from: process.env.SMTP_FROM,
    to: email,
    subject: 'Tu código de acceso RDAM',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
        <h2 style="color: #1a3c6e;">Registro de Deuda Alimenticia</h2>
        <p>Tu código de acceso es:</p>
        <div style="font-size: 36px; font-weight: bold; letter-spacing: 12px; color: #1a3c6e; padding: 16px 0;">${codigo}</div>
        <p>Válido por <strong>${expMin} minutos</strong>. No lo compartas con nadie.</p>
        <p style="color: #888; font-size: 12px;">Si no solicitaste este código, ignorá este email.</p>
      </div>
    `,
  });
  logger.info(`OTP enviado a ${email}`);
}

async function sendCertificadoDisponible(email, solicitudId) {
  const transporter = createTransporter();
  await transporter.sendMail({
    from: process.env.SMTP_FROM,
    to: email,
    subject: 'Tu certificado RDAM está disponible',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
        <h2 style="color: #1a3c6e;">Tu certificado está listo</h2>
        <p>El trámite <strong>#${solicitudId}</strong> fue aprobado.</p>
        <p>Podés descargarlo ingresando a <a href="${process.env.PDF_BASE_URL}">rdam.gob.ar</a>.</p>
      </div>
    `,
  });
}

async function sendSolicitudRechazada(email, solicitudId, observaciones) {
  const transporter = createTransporter();
  await transporter.sendMail({
    from: process.env.SMTP_FROM,
    to: email,
    subject: 'Actualización sobre tu trámite RDAM',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
        <h2 style="color: #c0392b;">Trámite observado</h2>
        <p>El trámite <strong>#${solicitudId}</strong> fue rechazado.</p>
        <p><strong>Motivo:</strong> ${observaciones}</p>
        <p>Podés iniciar un nuevo trámite en rdam.gob.ar.</p>
      </div>
    `,
  });
}

module.exports = { sendOTP, sendCertificadoDisponible, sendSolicitudRechazada };
