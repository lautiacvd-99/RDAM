const express = require('express');
const router = express.Router();

const { requireCiudadano, requireOperador, requireAdmin, requireWorker } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

// Controllers
const otpController = require('../controllers/otpController');
const solicitudesController = require('../controllers/solicitudesController');
const pagosController = require('../controllers/pagosController');
const operadorController = require('../controllers/operadorController');
const adminController = require('../controllers/adminController');
const sistemaController = require('../controllers/sistemaController');
const { pool } = require('../config/database');

// ─── Health ───────────────────────────────────────────────────────────────────
router.get('/health', async (req, res) => {
  try {
    await pool.execute('SELECT 1');
    res.status(200).json({ status: 'ok', db: 'connected', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(503).json({ status: 'error', db: 'disconnected', timestamp: new Date().toISOString() });
  }
});

// ─── Auth ciudadano (OTP) ─────────────────────────────────────────────────────
router.post('/auth/otp/solicitar', otpController.solicitarOTP);
router.post('/auth/otp/verificar', otpController.verificarOTP);

// ─── Portal ciudadano ─────────────────────────────────────────────────────────
router.post('/solicitudes', requireCiudadano, solicitudesController.crearSolicitud);
router.get('/solicitudes/mias', requireCiudadano, solicitudesController.getMisSolicitudes);
router.get('/solicitudes/:id/historial', requireCiudadano, solicitudesController.getHistorialSolicitud);
router.get('/solicitudes/:id/certificado', requireCiudadano, solicitudesController.getCertificado);

// ─── Pagos (PlusPagos) ───────────────────────────────────────────────────────
router.post('/pagos/iniciar',            requireCiudadano, pagosController.iniciarPago);
router.get( '/pagos/:id/checkout',       requireCiudadano, pagosController.checkoutPago);
router.get( '/pagos/:id/estado',         requireCiudadano, pagosController.estadoPago);
router.post('/pagos/webhook',            pagosController.webhookPago);
router.post('/pagos/webhook/fallido',    pagosController.webhookFallido);

// ─── Panel Operador ───────────────────────────────────────────────────────────
router.get('/operador/solicitudes', requireOperador, operadorController.listarSolicitudes);
router.patch('/operador/solicitudes/:id/tomar', requireOperador, operadorController.tomarSolicitud);
// ✅ NUEVO: historial de una solicitud para operador/admin
router.get('/operador/solicitudes/:id/historial', requireOperador, solicitudesController.getHistorialSolicitud);
// upload.single('pdf') procesa el archivo antes de llegar al controller
router.post('/operador/solicitudes/:id/resolucion', requireOperador, upload.single('pdf'), operadorController.emitirResolucion);
router.patch('/operador/solicitudes/:id/certificado-emitido', requireWorker, operadorController.certificadoEmitido);

// ─── Panel Admin ──────────────────────────────────────────────────────────────
router.post('/admin/auth/login', adminController.login);
router.post('/admin/usuarios', requireAdmin, adminController.crearUsuario);
router.get('/admin/usuarios', requireAdmin, adminController.listarUsuarios);
router.patch('/admin/usuarios/:id/desactivar', requireAdmin, adminController.desactivarUsuario);
router.get('/admin/auditoria', requireAdmin, adminController.getAuditoria);
router.patch('/admin/usuarios/:id/reset-password', requireAdmin, adminController.resetPassword);

// ─── Sistema / Worker ─────────────────────────────────────────────────────────
router.post('/sistema/solicitudes/:id/generar-pdf', requireWorker, sistemaController.generarPDF);

module.exports = router;
