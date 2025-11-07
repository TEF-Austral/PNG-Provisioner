#!/bin/bash
# comprehensive-redis-test.sh

echo "🧪 Testing Redis Integration"
echo ""

# 1. Verificar que Redis esté corriendo
echo "1️⃣ Checking Redis container..."
if docker ps | grep -q redis_bus_dev; then
    echo "✅ Redis container is running"
else
    echo "❌ Redis container is NOT running"
    exit 1
fi

# 2. Verificar conexión
echo ""
echo "2️⃣ Testing Redis connection..."
docker exec redis_bus_dev redis-cli PING

# 3. Ver streams existentes
echo ""
echo "3️⃣ Existing streams:"
docker exec redis_bus_dev redis-cli KEYS "*"

# 4. Ver consumer groups
echo ""
echo "4️⃣ Consumer groups:"
docker exec redis_bus_dev redis-cli XINFO GROUPS formatting-requests 2>/dev/null || echo "No groups yet"

# 5. Enviar evento de prueba
echo ""
echo "5️⃣ Sending test event..."
docker exec redis_bus_dev redis-cli XADD formatting-requests "*" \
  requestId "test-$(date +%s)" \
  snippetId "1" \
  bucketContainer "test" \
  bucketKey "test.ps" \
  version "1.0" \
  userId "test-user"

# 6. Ver logs del servicio
echo ""
echo "6️⃣ Service logs (last 20 lines):"
docker logs --tail 20 printscript-service-api-dev

echo ""
echo "✅ Test completed!"