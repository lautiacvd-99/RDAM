const path = require('path');
const fs = require('fs');
const PDFDocument = require('pdfkit');
const { pool } = require('../config/database');
const logger = require('../utils/logger');

const PDF_STORAGE_PATH = process.env.PDF_STORAGE_PATH || './storage/pdfs';
const PDF_BASE_URL = process.env.PDF_BASE_URL || 'http://localhost:3000/storage/pdfs';

/**
 * POST /sistema/solicitudes/:id/generar-pdf
 * Genera el PDF del certificado para una solicitud APROBADA
 */
async function generarPDF(req, res, next) {
  try {
    const { id } = req.params;

    const [rows] = await pool.execute(
      `SELECT s.id, s.cuil, s.ciudad, s.email_ciudadano, s.estado,
              r.id as resolucion_id, r.resultado, r.observaciones, r.fecha_emision,
              u.nombre as operador_nombre
       FROM solicitud s
       JOIN resolucion r ON r.solicitud_id = s.id
       JOIN usuario u ON u.id = r.usuario_operario_id
       WHERE s.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Resolución no encontrada para esta solicitud' });
    }

    const data = rows[0];

    if (data.estado !== 'APROBADA') {
      return res.status(400).json({ error: `La solicitud no está en estado APROBADA. Estado actual: ${data.estado}` });
    }

    // Asegurar directorio de storage
    if (!fs.existsSync(PDF_STORAGE_PATH)) {
      fs.mkdirSync(PDF_STORAGE_PATH, { recursive: true });
    }

    const filename = `certificado_${id}_${Date.now()}.pdf`;
    const filepath = path.join(PDF_STORAGE_PATH, filename);

    // Generar PDF
    await generarDocumentoPDF(filepath, data);

    const url_pdf = `${PDF_BASE_URL}/${filename}`;

    // Llamar al callback de certificado-emitido
    // En producción esto sería un job de Redis/Bull
    const axios_like = async () => {
      const { certificadoEmitido } = require('./operadorController');
      // Simular req/res para el callback interno
      const fakeReq = {
        params: { id },
        body: { url_pdf },
        user: { id: null, tipo: 'worker' },
        ip: '127.0.0.1',
      };
      const fakeRes = {
        status: (s) => ({ json: (d) => logger.info('Certificado emitido callback:', d) }),
      };
      await certificadoEmitido(fakeReq, fakeRes, (err) => { if (err) logger.error(err); });
    };

    await axios_like();

    logger.info(`PDF generado: ${filename} para solicitud #${id}`);

    return res.status(202).json({
      mensaje: 'PDF generado y certificado emitido',
      solicitud_id: parseInt(id),
      url_pdf,
      job_id: `job_${Date.now()}_${id}`,
    });
  } catch (err) {
    next(err);
  }
}

async function generarDocumentoPDF(filepath, data) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50 });
    const stream = fs.createWriteStream(filepath);
    doc.pipe(stream);

    // Encabezado
    doc.fontSize(18).font('Helvetica-Bold')
      .text('CERTIFICADO DE REGISTRO DE DEUDA ALIMENTARIA', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12).font('Helvetica')
      .text(`Provincia de Santa Fe — RDAM`, { align: 'center' });
    doc.moveDown(2);

    // Datos
    doc.font('Helvetica-Bold').text('Datos del trámite:');
    doc.font('Helvetica')
      .text(`N° Solicitud: ${data.id}`)
      .text(`CUIL consultado: ${data.cuil}`)
      .text(`Ciudad: ${data.ciudad}`)
      .text(`Email ciudadano: ${data.email_ciudadano}`);

    doc.moveDown();
    doc.font('Helvetica-Bold').text('Resultado:');
    doc.font('Helvetica')
      .text(`Resolución: ${data.resultado}`)
      .text(`Operador: ${data.operador_nombre}`)
      .text(`Fecha de emisión: ${new Date(data.fecha_emision).toLocaleDateString('es-AR')}`);

    if (data.observaciones) {
      doc.moveDown();
      doc.font('Helvetica-Bold').text('Observaciones:');
      doc.font('Helvetica').text(data.observaciones);
    }

    doc.moveDown(3);
    doc.font('Helvetica').fontSize(10)
      .text('Este certificado es válido exigible judicialmente.', { align: 'center' })
      .text(`Generado el: ${new Date().toLocaleString('es-AR')}`, { align: 'center' });

    doc.end();
    stream.on('finish', resolve);
    stream.on('error', reject);
  });
}

module.exports = { generarPDF };
