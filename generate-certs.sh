#!/bin/bash

# Script para generar certificados SSL autofirmados
# Ejecutar desde la raíz del proyecto

echo "=== Generando certificados SSL autofirmados ==="

# Crear directorio para certificados si no existe
mkdir -p nginx/certs

# Generar certificado autofirmado válido por 365 días
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/nginx-selfsigned.key \
  -out nginx/certs/nginx-selfsigned.crt \
  -subj "/C=AR/ST=BuenosAires/L=BuenosAires/O=PrintScript/CN=printscript.local"

# Generar parámetros Diffie-Hellman para mayor seguridad
openssl dhparam -out nginx/certs/dhparam.pem 2048

# Ajustar permisos
chmod 600 nginx/certs/nginx-selfsigned.key
chmod 644 nginx/certs/nginx-selfsigned.crt
chmod 644 nginx/certs/dhparam.pem

echo "✅ Certificados generados en nginx/certs/"
echo "   - nginx-selfsigned.crt"
echo "   - nginx-selfsigned.key"
echo "   - dhparam.pem"
echo ""
echo "⚠️  IMPORTANTE: Estos son certificados autofirmados."
echo "   Los navegadores mostrarán una advertencia de seguridad."
echo "   Para producción, considera usar Let's Encrypt."
echo ""
echo "🔧 No olvides abrir el puerto 443 en tu VM:"
echo "   sudo ufw allow 443/tcp"