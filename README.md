# RDAM Backend — API REST

Sistema de Certificados Digitales de Deuda Alimenticia  
i2T Software Factory · Curso de Verano 2026

## Stack

- Node.js + Express.js
- MySQL 8
- Redis 6+
- JWT + OTP
- SMTP (nodemailer)
- PDFKit (certificados)

## Setup rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar entorno
cp .env.example .env
# Editar .env con tus credenciales

# 3. Crear base de datos
mysql -u root -p < src/config/migrate.sql

# 4. Crear directorios necesarios
mkdir -p logs storage/pdfs

# 5. Levantar en desarrollo
npm run dev
```

## Endpoints principales

| Método | Path | Auth |
|--------|------|------|
| POST | `/v1/auth/otp/solicitar` | público |
| POST | `/v1/auth/otp/verificar` | público |
| POST | `/v1/solicitudes` | JWT ciudadano |
| GET | `/v1/solicitudes/mias` | JWT ciudadano |
| GET | `/v1/solicitudes/:id/historial` | JWT ciudadano |
| GET | `/v1/solicitudes/:id/certificado` | JWT ciudadano |
| POST | `/v1/pagos/iniciar` | JWT ciudadano |
| POST | `/v1/pagos/webhook` | HMAC |
| GET | `/v1/operador/solicitudes` | JWT OPERADOR |
| PATCH | `/v1/operador/solicitudes/:id/tomar` | JWT OPERADOR |
| POST | `/v1/operador/solicitudes/:id/resolucion` | JWT OPERADOR |
| POST | `/v1/admin/auth/login` | público |
| POST | `/v1/admin/usuarios` | JWT ADMIN |
| GET | `/v1/admin/auditoria` | JWT ADMIN |
| GET | `/v1/health` | público |

## Admin inicial

- Email: `admin@rdam.gob.ar`
- Password: `Admin1234!`
- ⚠️ Cambiar en producción

## Flujo de estados (RN-08)

```
PENDIENTE_PAGO → PAGADA → PENDIENTE_REVISION → EN_REVISION → APROBADA → CERTIFICADO_EMITIDO
                                                           ↘ RECHAZADA
```
