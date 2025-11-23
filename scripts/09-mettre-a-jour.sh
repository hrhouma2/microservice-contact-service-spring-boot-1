#!/bin/bash

##############################################################################
# Script 09 : Mise à jour de l'application
# Usage: bash 09-mettre-a-jour.sh
# Description: Pull les dernières modifications et rebuild
##############################################################################

set -e

echo "=========================================="
echo "Mise à jour de l'application"
echo "=========================================="
echo ""

cd ~/apps/contact-service-springboot

echo "[1/5] Pull des dernières modifications GitHub..."
git pull origin main

echo ""
echo "[2/5] Arrêt de l'application..."
docker compose down

echo ""
echo "[3/5] Rebuild de l'image Docker..."
docker compose build --no-cache

echo ""
echo "[4/5] Redémarrage..."
docker compose up -d

echo ""
echo "[5/5] Attente du démarrage (30 secondes)..."
sleep 30

echo ""
echo "=========================================="
echo "✓ Mise à jour terminée"
echo "=========================================="
echo ""
docker compose ps
echo ""
curl -s http://localhost:8080/api/health | jq . || curl -s http://localhost:8080/api/health
echo ""

