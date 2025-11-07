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

# 3. Recrear consumer groups
echo "3️⃣ Restarting services..."
docker restart printscript-service-api-dev snippet-service-api-dev
echo "   Waiting for services to restart... (20 seconds)"
sleep 20
echo "✅ Services restarted and warmed up"
echo ""

# --- INICIO DE LA CORRECCIÓN ---
# 4. Crear un asset de prueba en Azurite (asset-service)
#    Usamos la URL de nginx (http://localhost) que redirige a asset-service-api
#    NOTA: Asumimos que Azurite está vacío.
echo "4️⃣ Creating dummy asset in asset-service (Azurite)..."
TEST_CONTENT="let x:number=5;println(x);"
CONTAINER="test-bucket"
KEY="test.ps-$(date +%s)" # Usamos una key única para evitar colisiones

# Ajusta esta URL si tu nginx no está en localhost:80
# El docker-compose de dev expone nginx en el puerto 80
curl -s -X PUT "http://localhost/api/assets/v1/asset/$CONTAINER/$KEY" \
     -H "Content-Type: text/plain" \
     --data "$TEST_CONTENT"
echo "   Asset created: $CONTAINER/$KEY"
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