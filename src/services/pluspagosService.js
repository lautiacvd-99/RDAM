/**
 * PlusPagos Integration Service
 * RDAM Backend - Integración con pasarela PlusPagos
 *
 * Encapsula toda la lógica de comunicación con PlusPagos:
 *  - Construcción del formulario de redirección (checkout)
 *  - Validación del webhook entrante (EstadoId 3 = REALIZADA, 4 = RECHAZADA)
 */

const { encryptString } = require('./pluspagos.crypto');

// ─── Configuración ────────────────────────────────────────────────────────────
// Todos los valores se leen desde variables de entorno (.env)
const CONFIG = {
  PLUSPAGOS_URL:  process.env.PLUSPAGOS_URL    || 'http://localhost:3000',
  MERCHANT_GUID:  process.env.PLUSPAGOS_GUID   || 'test-merchant-001',
  SECRET_KEY:     process.env.PLUSPAGOS_SECRET  || 'clave-secreta-campus-2026',
  BACKEND_URL:    process.env.BACKEND_URL       || 'http://localhost:3001',
  FRONTEND_URL:   process.env.FRONTEND_URL      || 'http://localhost:3000',
};

/**
 * Genera el HTML del formulario de redirección hacia PlusPagos.
 *
 * El navegador del ciudadano carga esta página, el form se auto-submitea
 * y el usuario llega a la pantalla de pago de la pasarela.
 *
 * @param {object} params
 * @param {number|string} params.solicitudId  - ID de la solicitud RDAM
 * @param {number}        params.montoARS     - Monto en pesos (ej: 2500)
 * @param {string}        params.descripcion  - Texto libre (ej: "Certificado RDAM #42")
 * @returns {{ redirectHtml: string, transaccionComercioId: string }}
 */
function buildCheckoutHtml({ solicitudId, montoARS, descripcion = 'Certificado RDAM' }) {
  const transaccionComercioId = `RDAM-${solicitudId}-${Date.now()}`;

  // PlusPagos espera el monto en CENTAVOS como entero
  const montoCentavos = Math.round(parseFloat(montoARS) * 100).toString();

  // URLs de callback (servidor → servidor)
  const callbackSuccess = `${CONFIG.BACKEND_URL}/api/pagos/webhook`;
  const callbackCancel  = `${CONFIG.BACKEND_URL}/api/pagos/webhook/fallido`;

  // URLs de redirección del usuario (browser redirect)
  const urlSuccess = `${CONFIG.FRONTEND_URL}/pago/resultado?status=success&solicitud=${solicitudId}`;
  const urlError   = `${CONFIG.FRONTEND_URL}/pago/resultado?status=error&solicitud=${solicitudId}`;

  const s = CONFIG.SECRET_KEY;

  const campos = {
    Comercio:              CONFIG.MERCHANT_GUID,
    TransaccionComercioId: transaccionComercioId,
    Monto:                 encryptString(montoCentavos,            s),
    CallbackSuccess:       encryptString(callbackSuccess,          s),
    CallbackCancel:        encryptString(callbackCancel,           s),
    UrlSuccess:            encryptString(urlSuccess,               s),
    UrlError:              encryptString(urlError,                 s),
    Informacion:           encryptString(descripcion,              s),
  };

  // Generar inputs ocultos
  const inputs = Object.entries(campos)
    .map(([name, value]) => `<input type="hidden" name="${name}" value="${value}">`)
    .join('\n    ');

  const redirectHtml = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Redirigiendo al pago...</title>
  <style>
    body { font-family: system-ui; background: #0f172a; color: #e2e8f0;
           display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .loader { text-align: center; }
    .spinner { width: 48px; height: 48px; border: 4px solid rgba(255,255,255,0.15);
               border-top-color: #3b82f6; border-radius: 50%;
               animation: spin 0.8s linear infinite; margin: 0 auto 16px; }
    @keyframes spin { to { transform: rotate(360deg); } }
    p { color: #94a3b8; }
  </style>
</head>
<body>
  <div class="loader">
    <div class="spinner"></div>
    <p>Conectando con la pasarela de pago…</p>
  </div>
  <form id="pp" action="${CONFIG.PLUSPAGOS_URL}" method="POST" style="display:none">
    ${inputs}
  </form>
  <script>document.getElementById('pp').submit();</script>
</body>
</html>`;

  return { redirectHtml, transaccionComercioId };
}

/**
 * Valida y parsea el payload del webhook de PlusPagos.
 *
 * El mock envía:
 * {
 *   Tipo:                    "PAGO",
 *   TransaccionPlataformaId: "123456",
 *   TransaccionComercioId:   "RDAM-42-1700000000000",
 *   Monto:                   "2500.00",
 *   EstadoId:                "3",          // "3" = REALIZADA, "4" = RECHAZADA
 *   Estado:                  "REALIZADA",
 *   FechaProcesamiento:      "2026-01-21T15:30:00.000Z"
 * }
 *
 * @param {object} body - req.body del webhook
 * @returns {{ ok: boolean, aprobado: boolean, solicitudId: string|null,
 *             transaccionPlataformaId: string, monto: string, raw: object }}
 */
function parseWebhookPayload(body) {
  const {
    TransaccionPlataformaId,
    TransaccionComercioId = '',
    Monto,
    EstadoId,
  } = body;

  // TransaccionComercioId tiene formato "RDAM-{solicitudId}-{timestamp}"
  const match = TransaccionComercioId.match(/^RDAM-(\d+)-/);
  const solicitudId = match ? match[1] : null;

  const aprobado = EstadoId === '3';  // 3 = REALIZADA

  return {
    ok:                    true,
    aprobado,
    solicitudId,
    transaccionPlataformaId: String(TransaccionPlataformaId || ''),
    transaccionComercioId:   TransaccionComercioId,
    monto:                   String(Monto || '0'),
    raw:                     body,
  };
}

module.exports = { buildCheckoutHtml, parseWebhookPayload, CONFIG };
