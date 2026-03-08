# ── Imagen base ──────────────────────────────────────────────────────────────
FROM node:20-alpine

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar dependencias primero (cache de capas)
COPY package*.json ./
RUN npm ci --omit=dev

# Copiar el resto del código fuente
COPY . .

# Crear carpetas necesarias
RUN mkdir -p storage/pdfs logs

# Exponer el puerto del backend
EXPOSE 3001

# Comando de inicio
CMD ["node", "src/app.js"]
