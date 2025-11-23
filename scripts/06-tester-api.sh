#!/bin/bash

##############################################################################
# Script 06 : Tests automatiques de l'API
# Usage: bash 06-tester-api.sh
# Description: Teste tous les endpoints de l'API
##############################################################################

echo "=========================================="
echo "Tests de l'API Contact Service"
echo "=========================================="
echo ""

# Demander l'URL de base
read -p "URL de l'API [http://localhost:8080] : " API_URL
API_URL=${API_URL:-http://localhost:8080}

echo ""
echo "Tests sur : $API_URL"
echo ""

# Test 1 : Health Check
echo "[Test 1/3] Health Check..."
HEALTH_RESPONSE=$(curl -s "$API_URL/api/health")

if echo "$HEALTH_RESPONSE" | grep -q '"status":"ok"'; then
    echo "✓ Health check OK"
    echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
else
    echo "✗ Health check échoué"
    echo "$HEALTH_RESPONSE"
fi

echo ""
echo "[Test 2/3] Documentation Swagger..."
SWAGGER_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/swagger-ui.html")

if [ "$SWAGGER_CODE" = "200" ]; then
    echo "✓ Swagger accessible : $API_URL/swagger-ui.html"
else
    echo "✗ Swagger non accessible (code: $SWAGGER_CODE)"
fi

echo ""
echo "[Test 3/3] POST /api/contact..."
CONTACT_RESPONSE=$(curl -s -X POST "$API_URL/api/contact" \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test-script",
    "email": "test@example.com",
    "name": "Test Script",
    "message": "Test automatique depuis le script 06"
  }')

if echo "$CONTACT_RESPONSE" | grep -q '"ok":true'; then
    echo "✓ POST /api/contact OK"
    echo "$CONTACT_RESPONSE" | jq . 2>/dev/null || echo "$CONTACT_RESPONSE"
else
    echo "✗ POST /api/contact échoué"
    echo "$CONTACT_RESPONSE"
fi

echo ""
echo "=========================================="
echo "Tests terminés"
echo "=========================================="
echo ""
echo "Vérifier l'email de notification et la base de données :"
echo "  docker exec -it contact-service-db psql -U postgres -d contact_service -c 'SELECT * FROM form_submissions ORDER BY created_at DESC LIMIT 3;'"
echo ""

