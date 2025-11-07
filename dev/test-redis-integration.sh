#!/bin/bash

echo "🧪 Testing complete Redis integration flow"
echo ""

# 1. Verificar que los servicios estén corriendo
echo "1️⃣ Checking services..."
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "snippet|printscript|redis"
echo ""

# 2. Limpiar SÓLO los streams de REQUESTS
echo "2️⃣ Cleaning previous request data..."
docker exec redis_bus_dev redis-cli DEL formatting-requests
docker exec redis_bus_dev redis-cli DEL linting-requests
docker exec redis_bus_dev redis-cli DEL testing-requests
docker exec redis_bus_dev redis-cli DEL formatting-results # Limpiamos también resultados
echo "✅ Request streams cleaned"
echo ""

# 3. Reiniciar servicios
echo "3️⃣ Restarting services..."
docker restart printscript-service-api-dev snippet-service-api-dev
echo "   Waiting for services to restart... (20 seconds)"
sleep 20
echo "✅ Services restarted and warmed up"
echo ""

# 4. Crear un asset de prueba en Azurite (asset-service)
echo "4️⃣ Creating dummy asset in asset-service (Azurite)..."
TEST_CONTENT="let x:number=5;println(x);"
CONTAINER="test-bucket"
KEY="test.ps-$(date +%s)" # Usamos una key única

# --- INICIO DE LA CORRECCIÓN ---
# Usamos la URL externa (la de Nginx) que está en el .env.example
CREATE_URL="http://localhost/api/assets/v1/asset/$CONTAINER/$KEY"
echo "   Calling: PUT $CREATE_URL"

# Agregamos -L (para seguir la redirección 301) y -k (para ignorar SSL en dev)
HTTP_STATUS=$(curl -o /dev/null -w "%{http_code}" -L -k -X PUT "$CREATE_URL" \
     -H "Content-Type: text/plain" \
     --data "$TEST_CONTENT")

if [ "$HTTP_STATUS" -ne 201 ] && [ "$HTTP_STATUS" -ne 200 ]; then
    echo "❌ ERROR: No se pudo crear el asset. Nginx respondió: $HTTP_STATUS"
    echo "   Abortando test."
    exit 1
fi
echo "   ✅ Asset created: $CONTAINER/$KEY (Status: $HTTP_STATUS)"
echo ""
# --- FIN DE LA CORRECCIÓN ---


# 5. Enviar evento de prueba como CAMPOS SEPARADOS
echo "5️⃣ Sending test formatting request (as Fields)..."
TIMESTAMP=$(date +%s)

MESSAGE_ID=$(docker exec redis_bus_dev redis-cli XADD formatting-requests "*" \
  "_class" "requests.FormattingRequestEvent" \
  "requestId" "test-$TIMESTAMP" \
  "bucketContainer" "$CONTAINER" \
  "bucketKey" "$KEY" \
  "languageId" "printscript" \
  "version" "1.1" \
  "userId" "test-user-123")

echo "   Message ID: $MESSAGE_ID"
echo ""

# 6. Esperar un poco para que se procese
echo "6️⃣ Waiting for processing..."
sleep 5
echo ""

# 7. Verificar que el mensaje se consumió
echo "7️⃣ Checking consumer groups (printscript-service)..."
docker exec redis_bus_dev redis-cli XINFO GROUPS formatting-requests
echo ""

# 8. Ver el resultado (¡AHORA DEBERÍA HABER 1 Y success=1!)
echo "8️⃣ Checking for results..."
docker exec redis_bus_dev redis-cli XLEN formatting-results
docker exec redis_bus_dev redis-cli XRANGE formatting-results - + COUNT 5
echo ""

# 9. Ver logs del PrintScript service
echo "9️⃣ PrintScript Service logs (last 30 lines)..."
docker logs --tail 30 printscript-service-api-dev
echo ""

echo "✅ Test completed!"