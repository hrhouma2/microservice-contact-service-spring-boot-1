#!/bin/bash
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Mise à jour de l application${NC}"
cd ~/apps/contact-service-springboot

echo -e "${YELLOW}[1/3] Git pull...${NC}"
git pull origin main

echo -e "${YELLOW}[2/3] Rebuild Docker...${NC}"
docker compose up -d --build

echo -e "${YELLOW}[3/3] Vérification...${NC}"
sleep 5
docker compose ps
curl -f http://localhost:8080/api/health && echo -e "${GREEN}Mise à jour réussie !${NC}" || echo "Erreur"
