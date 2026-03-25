require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const routes = require('./routes/index');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const { testConnection } = require('./config/database');
const redis = require('./config/redis');
const logger = require('./utils/logger');

const app = express();

// ─── Seguridad ────────────────────────────────────────────────────────────────
// ─── Seguridad ────────────────────────────────────────────────────────────────
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      ...helmet.contentSecurityPolicy.getDefaultDirectives(),
      'frame-ancestors': [process.env.FRONTEND_URL || 'http://localhost:5173'],
    },
  },
  frameguard: false,
}));

// ✅ CORS 
app.use(cors({
  origin: ["http://localhost:5173", "http://localhost"],
  methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));

// Manejo explícito de preflight
app.options('*', cors());

// ─── Rate limiting ────────────────────────────────────────────────────────────
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  message: { error: 'Demasiadas solicitudes, intentá más tarde' },
}));

// Rate limiting estricto para OTP (anti-brute force)
app.use('/v1/auth/otp', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { error: 'Límite de intentos de OTP alcanzado' },
}));

// ─── Parsers ──────────────────────────────────────────────────────────────────
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: false }));

// ─── Logging HTTP ─────────────────────────────────────────────────────────────
app.use(morgan('combined', {
  stream: { write: (msg) => logger.http(msg.trim()) },
}));

// ─── Static PDFs ─────────────────────────────────────────────────────────────
app.use('/storage/pdfs', express.static(process.env.PDF_STORAGE_PATH || './storage/pdfs'));

// ─── Rutas API ────────────────────────────────────────────────────────────────
app.use('/v1', routes);

// ─── Manejo de errores ────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

// ─── Arranque ─────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3001;

async function start() {
  const dbOk = await testConnection();
  if (!dbOk) {
    logger.error('No se pudo conectar a MySQL. Saliendo...');
    process.exit(1);
  }

  try {
    await redis.connect();
  } catch (err) {
    logger.warn('Redis no disponible — continuando sin caché:', err.message);
  }

  app.listen(PORT, () => {
    logger.info(`🚀 RDAM API corriendo en http://localhost:${PORT}/v1`);
    logger.info(`   Health: http://localhost:${PORT}/v1/health`);
  });
}

start();

module.exports = app; // Para tests