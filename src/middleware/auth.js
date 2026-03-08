const { verify } = require('../utils/jwt');
const logger = require('../utils/logger');

/**
 * Middleware base: verifica y decodifica el JWT
 */
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }
  const token = authHeader.split(' ')[1];
  try {
    req.user = verify(token);
    next();
  } catch (err) {
    logger.warn('JWT inválido:', err.message);
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
}

/**
 * Solo ciudadanos autenticados por OTP
 */
function requireCiudadano(req, res, next) {
  authenticate(req, res, () => {
    if (req.user.tipo !== 'ciudadano') {
      return res.status(403).json({ error: 'Acceso restringido a ciudadanos' });
    }
    next();
  });
}

/**
 * Solo operadores o admins internos
 */
function requireOperador(req, res, next) {
  authenticate(req, res, () => {
    if (req.user.tipo !== 'interno' || !['OPERADOR', 'ADMIN'].includes(req.user.rol)) {
      return res.status(403).json({ error: 'Acceso restringido a operadores' });
    }
    next();
  });
}

/**
 * Solo admins
 */
function requireAdmin(req, res, next) {
  authenticate(req, res, () => {
    if (req.user.tipo !== 'interno' || req.user.rol !== 'ADMIN') {
      return res.status(403).json({ error: 'Acceso restringido a administradores' });
    }
    next();
  });
}

/**
 * Worker interno
 */
function requireWorker(req, res, next) {
  authenticate(req, res, () => {
    if (!['worker', 'interno'].includes(req.user.tipo)) {
      return res.status(403).json({ error: 'Acceso restringido' });
    }
    next();
  });
}

module.exports = { authenticate, requireCiudadano, requireOperador, requireAdmin, requireWorker };
