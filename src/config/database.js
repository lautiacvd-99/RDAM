const mysql = require('mysql2/promise');
const logger = require('../utils/logger');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+00:00',
  dateStrings: false,
});

pool.on('connection', () => {
  logger.debug('Nueva conexión MySQL establecida');
});

async function testConnection() {
  try {
    const conn = await pool.getConnection();
    await conn.ping();
    conn.release();
    logger.info('✅ MySQL conectado correctamente');
    return true;
  } catch (err) {
    logger.error('❌ Error conectando a MySQL:', err.message);
    return false;
  }
}

module.exports = { pool, testConnection };
