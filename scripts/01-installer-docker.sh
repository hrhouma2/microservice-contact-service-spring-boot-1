#!/bin/bash

##############################################################################
# Script 01 : Installation de Docker et Docker Compose sur Ubuntu 24.04
# Usage: sudo bash 01-installer-docker.sh
# Description: Installe Docker Engine et Docker Compose automatiquement
##############################################################################

set -e

echo "=========================================="
echo "Installation Docker sur Ubuntu 24.04"
echo "=========================================="
echo ""

# Vérifier root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Ce script doit être exécuté avec sudo"
   echo "Usage: sudo bash 01-installer-docker.sh"
   exit 1
fi

# Vérifier Ubuntu 24.04
if ! grep -q "24.04" /etc/os-release; then
    echo "ATTENTION : Ce script est optimisé pour Ubuntu 24.04"
    echo "Votre version : $(lsb_release -d | cut -f2)"
    read -p "Continuer quand même ? (o/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

echo "[1/8] Mise à jour du système..."
apt update && apt upgrade -y

echo ""
echo "[2/8] Installation des outils de base..."
apt install -y ca-certificates curl gnupg lsb-release wget git vim nano ufw htop net-tools

echo ""
echo "[3/8] Suppression des anciennes versions Docker..."
for pkg in docker docker-engine docker.io containerd runc; do
    apt remove -y $pkg 2>/dev/null || true
done

echo ""
echo "[4/8] Configuration du repository Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ""
echo "[5/8] Mise à jour de la liste des paquets..."
apt update

echo ""
echo "[6/8] Installation Docker Engine + Compose..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo "[7/8] Configuration Docker..."
# Créer le fichier de config Docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

echo ""
echo "[8/8] Démarrage de Docker..."
systemctl enable docker
systemctl start docker

# Attendre que Docker soit prêt
sleep 3

# Test
docker run --rm hello-world

echo ""
echo "=========================================="
echo "✓ Docker installé avec succès !"
echo "=========================================="
echo ""
docker --version
docker compose version
echo ""
systemctl status docker --no-pager | head -5
echo ""
echo "Prochaine étape : sudo bash 02-creer-utilisateur.sh"
echo ""
