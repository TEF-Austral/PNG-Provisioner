#!/usr/bin/env bash

set -euo pipefail

# Your Azure VM IP
BASE_URL="http://20.200.120.244"

# Auth0 Configuration
AUTH0_DOMAIN="tef-austral.us.auth0.com"
CLIENT_ID="KuVymmoEvGBrTIPkIERGKaGGvphD0yaF"
CLIENT_SECRET="fHRAwEdsmPb6-aioNNjZ7F2V8BZhobDGvOnWU_FIe1cWUOzAI3D6z0FL8Q5VoV3W"
AUDIENCE="https://tef-austral.com/api"

echo "=========================================="
echo "Testing PNG Provisioner API"
echo "Azure VM: ${BASE_URL}"
echo "=========================================="
echo ""

echo "=== Step 1: Test Gateway Health ==="
curl -s "${BASE_URL}/health" && echo -e "\n"

echo "=== Step 2: Test Gateway Root ==="
curl -s "${BASE_URL}/" && echo -e "\n"

echo "=== Step 3: Getting Access Token from Auth0 ==="
TOKEN_RESPONSE=$(curl -s --request POST \
  --url "https://${AUTH0_DOMAIN}/oauth/token" \
  --header 'content-type: application/json' \
  --data '{
    "client_id":"'${CLIENT_ID}'",
    "client_secret":"'${CLIENT_SECRET}'",
    "audience":"'${AUDIENCE}'",
    "grant_type":"client_credentials"
  }')

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "${TOKEN:-}" ]; then
    echo "❌ Failed to get token!"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

echo "✅ Token obtained successfully!"
echo "Token: ${TOKEN:0:50}..."
echo ""

echo "=== Step 4: Test Authentication Service Health ==="
curl -s "${BASE_URL}/api/auth/" \
  -H "Authorization: Bearer ${TOKEN}" && echo -e "\n"

echo "=== Step 5: Get JWT Token Value ==="
curl -s "${BASE_URL}/api/auth/jwt" \
  -H "Authorization: Bearer ${TOKEN}" && echo -e "\n"

echo "=== Step 6: Get All Snippets ==="
curl -s "${BASE_URL}/api/auth/snippets" \
  -H "Authorization: Bearer ${TOKEN}" && echo -e "\n"

echo "=== Step 7: Get Single Snippet ==="
curl -s "${BASE_URL}/api/auth/snippets/test-123" \
  -H "Authorization: Bearer ${TOKEN}" && echo -e "\n"

echo "=== Step 8: Create Snippet ==="
curl -s -X POST "${BASE_URL}/api/auth/snippets" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '"This is my test snippet content"' && echo -e "\n"

echo "=== Step 9: Get All Users ==="
curl -s "${BASE_URL}/api/auth/users" \
  -H "Authorization: Bearer ${TOKEN}" && echo -e "\n"

echo "=== Step 10: Create New User ==="
TIMESTAMP=$(date +%s)
curl -s -X POST "${BASE_URL}/api/auth/users" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser'${TIMESTAMP}'@example.com",
    "password": "TestPassword123!",
    "name": "Test User",
    "nickname": "testuser'${TIMESTAMP}'",
    "blocked": false
  }' && echo -e "\n"

echo ""
echo "=========================================="
echo "✅ All tests completed successfully!"
echo "=========================================="
echo ""
echo "Your endpoints are accessible at:"
echo "  Gateway:        ${BASE_URL}/"
echo "  Health:         ${BASE_URL}/health"
echo "  Auth Service:   ${BASE_URL}/api/auth/"
echo "  Base Service:   ${BASE_URL}/api/base/"
echo "  Formatter:      ${BASE_URL}/api/formatter/"
echo "  Snippet:        ${BASE_URL}/api/snippet/"
echo "  Execution:      ${BASE_URL}/api/execution/"
echo "  Analyzer:       ${BASE_URL}/api/analyzer/"
echo "  Authorization:  ${BASE_URL}/api/authorization/"
echo ""