const multer = require('multer');
const path = require('path');
const fs = require('fs');

const PDF_DIR = process.env.PDF_STORAGE_PATH || './storage/pdfs';

// Crear el directorio si no existe
if (!fs.existsSync(PDF_DIR)) {
  fs.mkdirSync(PDF_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, PDF_DIR);
  },
  filename: (req, file, cb) => {
    const solicitudId = req.params.id || 'unknown';
    const timestamp = Date.now();
    cb(null, `resolucion-${solicitudId}-${timestamp}.pdf`);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype === 'application/pdf') {
    cb(null, true);
  } else {
    cb(new Error('Solo se permiten archivos PDF'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 20 * 1024 * 1024 }, // 20MB máximo
});

module.exports = { upload };