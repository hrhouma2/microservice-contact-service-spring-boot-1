#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Déploiement de l application${NC}"
echo ""

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: bash 05-deploy-app.sh GITHUB_REPO_URL${NC}"
    echo "Exemple: bash 05-deploy-app.sh https://github.com/username/contact-service-springboot.git"
    exit 1
fi

REPO_URL=$1
APP_DIR="$HOME/apps/contact-service-springboot"

echo -e "${YELLOW}[1/4] Clonage du repository...${NC}"
mkdir -p ~/apps
cd ~/apps
if [ -d "contact-service-springboot" ]; then
    echo "Le dossier existe déjà. Mise à jour..."
    cd contact-service-springboot
    git pull origin main
else
    git clone $REPO_URL
    cd contact-service-springboot
fi

echo ""
echo -e "${YELLOW}[2/4] Configuration .env...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${BLUE}Fichier .env créé. ÉDITEZ-LE avant de continuer !${NC}"
    echo "  nano .env"
    echo ""
    echo -e "${RED}Appuyez sur Entrée quand c est fait...${NC}"
    read
fi

echo ""
echo -e "${YELLOW}[3/4] Démarrage avec Docker Compose...${NC}"
docker compose up -d

echo ""
echo -e "${YELLOW}[4/4] Vérification...${NC}"
sleep 5
docker compose ps

echo ""
if curl -f http://localhost:8080/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}Application déployée avec succès !${NC}"
    echo ""
    echo "Accès local : http://localhost:8080/swagger-ui.html"
    echo "Health check: http://localhost:8080/api/health"
else
    echo -e "${RED}Erreur : L application ne répond pas${NC}"
    echo "Vérifiez les logs : docker compose logs -f"
fi
echo ""
