const jwt = require('jsonwebtoken');

/**
 * Genera un JWT para ciudadano (autenticado vía OTP)
 */
function signCiudadano(email) {
  return jwt.sign(
    { email, tipo: 'ciudadano' },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
  );
}

/**
 * Genera un JWT para usuario interno (OPERADOR / ADMIN)
 */
function signInterno(usuario) {
  return jwt.sign(
    { id: usuario.id, email: usuario.email, rol: usuario.rol, tipo: 'interno' },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_INTERNAL_EXPIRES_IN || '8h' }
  );
}

/**
 * Genera un JWT para worker interno
 */
function signWorker() {
  return jwt.sign(
    { tipo: 'worker' },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
}

function verify(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

module.exports = { signCiudadano, signInterno, signWorker, verify };
