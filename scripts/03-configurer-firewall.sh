#!/bin/bash

##############################################################################
# Script 03 : Configuration du firewall UFW
# Usage: sudo bash 03-configurer-firewall.sh
# Description: Configure UFW avec les ports nécessaires (SSH, HTTP, HTTPS)
##############################################################################

set -e

echo "=========================================="
echo "Configuration du Firewall UFW"
echo "=========================================="
echo ""

# Vérifier que le script est exécuté en root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "Erreur : Ce script doit être exécuté avec sudo"
   echo "Usage: sudo bash 03-configurer-firewall.sh"
   exit 1
fi

echo "[1/6] Installation de UFW..."
apt install -y ufw

echo ""
echo "[2/6] Configuration des règles par défaut..."
ufw default deny incoming
ufw default allow outgoing

echo ""
echo "[3/6] Autorisation SSH (port 22)..."
ufw allow 22/tcp
echo "Port SSH 22 autorisé"

echo ""
echo "[4/6] Autorisation HTTP (port 80)..."
ufw allow 80/tcp

echo ""
echo "[5/6] Autorisation HTTPS (port 443)..."
ufw allow 443/tcp

echo ""
echo "[6/6] Activation du firewall..."
echo "y" | ufw enable

echo ""
echo "=========================================="
echo "Firewall configuré avec succès !"
echo "=========================================="
echo ""
echo "Règles actives :"
ufw status verbose
echo ""
echo "Ports autorisés :"
echo "  - 22/tcp  : SSH"
echo "  - 80/tcp  : HTTP"
echo "  - 443/tcp : HTTPS"
echo ""
echo "Note : Le port 8080 (Spring Boot) n'est PAS exposé publiquement."
echo "       L'accès se fait via Nginx sur les ports 80/443."
echo ""
echo "Prochaine étape : Exécuter 04-deployer-application.sh"
echo ""

