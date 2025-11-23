#!/bin/bash

##############################################################################
# Script 10 : Désinstallation complète
# Usage: sudo bash 10-desinstaller.sh
# Description: Supprime tout (application, Docker, utilisateur)
##############################################################################

echo "========================================================"
echo "⚠️  DÉSINSTALLATION COMPLÈTE"
echo "========================================================"
echo ""
echo "Ce script va supprimer :"
echo "  - L'application Contact Service"
echo "  - Tous les conteneurs et volumes Docker"
echo "  - L'utilisateur deploy"
echo "  - Nginx"
echo "  - Docker Engine (optionnel)"
echo ""
echo "⚠️  TOUTES LES DONNÉES SERONT PERDUES !"
echo ""
read -p "Êtes-vous SÛR de vouloir continuer ? (tapez 'OUI' en majuscules) : " CONFIRM

if [ "$CONFIRM" != "OUI" ]; then
    echo "Désinstallation annulée"
    exit 0
fi

# Vérifier root
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Exécuter avec sudo"
   exit 1
fi

echo ""
echo "[1/6] Arrêt et suppression de l'application..."
if [ -d /home/deploy/apps/contact-service-springboot ]; then
    cd /home/deploy/apps/contact-service-springboot
    docker compose down -v 2>/dev/null || true
fi

echo ""
echo "[2/6] Suppression de Nginx..."
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true
apt remove -y nginx nginx-common 2>/dev/null || true
rm -rf /etc/nginx

echo ""
echo "[3/6] Suppression des dossiers de l'application..."
rm -rf /home/deploy/apps

echo ""
echo "[4/6] Suppression de l'utilisateur deploy..."
userdel -r deploy 2>/dev/null || true

echo ""
read -p "[5/6] Désinstaller Docker Engine ? (o/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Oo]$ ]]; then
    echo "Suppression de Docker..."
    docker system prune -a -f --volumes 2>/dev/null || true
    systemctl stop docker 2>/dev/null || true
    systemctl disable docker 2>/dev/null || true
    apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    rm -rf /var/lib/docker
    rm -rf /etc/docker
    rm /etc/apt/sources.list.d/docker.list
    rm /etc/apt/keyrings/docker.gpg
fi

echo ""
echo "[6/6] Nettoyage final..."
apt autoremove -y
apt autoclean

echo ""
echo "=========================================="
echo "✓ Désinstallation terminée"
echo "=========================================="
echo ""

