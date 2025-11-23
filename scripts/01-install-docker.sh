#!/bin/bash

##############################################################################
# Script 01 : Installation de Docker et Docker Compose sur Ubuntu 24.04
# 
# Ce script doit être exécuté en tant que root ou avec sudo
# Usage : sudo bash 01-install-docker.sh
##############################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation de Docker sur Ubuntu 24.04${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Vérifier si l'utilisateur est root ou a sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Ce script doit être exécuté avec sudo${NC}"
    echo "Usage: sudo bash 01-install-docker.sh"
    exit 1
fi

echo -e "${YELLOW}[1/7] Mise à jour du système...${NC}"
apt update
apt upgrade -y

echo ""
echo -e "${YELLOW}[2/7] Installation des prérequis...${NC}"
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    vim \
    nano \
    ufw \
    net-tools \
    htop

echo ""
echo -e "${YELLOW}[3/7] Ajout de la clé GPG Docker...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo ""
echo -e "${YELLOW}[4/7] Ajout du repository Docker...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ""
echo -e "${YELLOW}[5/7] Mise à jour des paquets...${NC}"
apt update

echo ""
echo -e "${YELLOW}[6/7] Installation de Docker Engine...${NC}"
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo ""
echo -e "${YELLOW}[7/7] Configuration de Docker...${NC}"

# Activer et démarrer Docker
systemctl enable docker
systemctl start docker

# Configuration daemon.json pour limiter les logs
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Redémarrer Docker pour appliquer la config
systemctl restart docker

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation terminée avec succès !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Vérifications
echo -e "${YELLOW}Vérifications :${NC}"
echo -e "Docker version : $(docker --version)"
echo -e "Docker Compose version : $(docker compose version)"
echo ""

# Test Docker
echo -e "${YELLOW}Test de Docker...${NC}"
docker run --rm hello-world

echo ""
echo -e "${GREEN}✓ Docker est installé et fonctionne correctement !${NC}"
echo ""
echo -e "${YELLOW}Prochaine étape : Exécuter le script 02-create-user.sh${NC}"
echo ""
