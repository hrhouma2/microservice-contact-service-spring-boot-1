#!/bin/bash

###########################################
# Script 03 : Configuration du Firewall UFW
# Ubuntu 24.04 LTS
# À exécuter en tant que root ou avec sudo
###########################################

set -e

echo "=========================================="
echo "Configuration du Firewall UFW"
echo "=========================================="
echo ""

# Vérifier si on est root ou sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Erreur : Ce script doit être exécuté avec sudo"
    echo "Usage : sudo bash 03-configure-firewall.sh"
    exit 1
fi

# Vérifier si UFW est installé
if ! command -v ufw &> /dev/null; then
    echo "[0/5] Installation de UFW..."
    apt install -y ufw
    echo "✓ UFW installé"
    echo ""
fi

echo "[1/5] Configuration des règles par défaut..."
ufw default deny incoming
ufw default allow outgoing
echo "✓ Règles par défaut configurées"
echo ""

echo "[2/5] Autorisation SSH (port 22)..."
ufw allow 22/tcp comment 'SSH'
echo "✓ SSH autorisé"
echo ""

echo "[3/5] Autorisation HTTP et HTTPS..."
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
echo "✓ HTTP/HTTPS autorisés"
echo ""

echo "[4/5] Activation du firewall..."
echo "y" | ufw enable
echo "✓ Firewall activé"
echo ""

echo "[5/5] Vérification de la configuration..."
ufw status verbose
echo ""

echo "=========================================="
echo "✓ Firewall configuré avec succès !"
echo "=========================================="
echo ""
echo "Ports ouverts :"
echo "  - 22/tcp  : SSH"
echo "  - 80/tcp  : HTTP"
echo "  - 443/tcp : HTTPS"
echo ""
echo "Prochaine étape : Exécuter 04-deploy-app.sh"
echo "Usage : bash 04-deploy-app.sh (en tant qu'utilisateur deploy)"
echo ""
echo "⚠️  Important : Testez votre connexion SSH avant de vous déconnecter !"
echo ""

