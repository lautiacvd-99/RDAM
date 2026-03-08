/**
 * Genera un código OTP de 4 dígitos
 */
function generateOTP() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

/**
 * Normaliza CUIL: elimina guiones y valida 11 dígitos
 */
function normalizeCUIL(cuil) {
  const clean = cuil.replace(/-/g, '');
  if (!/^\d{11}$/.test(clean)) return null;
  return clean;
}

/**
 * Formatea CUIL con guiones: XX-XXXXXXXX-X
 */
function formatCUIL(cuil) {
  const c = cuil.replace(/-/g, '');
  return `${c.slice(0, 2)}-${c.slice(2, 10)}-${c.slice(10)}`;
}

module.exports = { generateOTP, normalizeCUIL, formatCUIL };
