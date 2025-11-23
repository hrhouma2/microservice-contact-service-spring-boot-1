#!/bin/bash
set -e
echo "Mise à jour de l'application..."
cd ~/apps/contact-service-springboot
git pull origin main
docker compose up -d --build
echo "Vérification..."
sleep 5
curl http://localhost:8080/api/health
echo -e "\nApplication mise à jour !"
