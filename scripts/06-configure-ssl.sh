#!/bin/bash

###########################################
# Script 06 : Configuration SSL avec Certbot
# Ubuntu 24.04 LTS
# À exécuter avec sudo
# Prérequis : Avoir un nom de domaine
###########################################

set -e

echo "=========================================="
echo "Configuration SSL avec Certbot"
echo "=========================================="
echo ""

# Vérifier si on est root ou sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Erreur : Ce script doit être exécuté avec sudo"
    echo "Usage : sudo bash 06-configure-ssl.sh"
    exit 1
fi

# Vérifier que Nginx est installé
if ! systemctl is-active --quiet nginx; then
    echo "❌ Erreur : Nginx n'est pas installé ou ne fonctionne pas"
    echo "Exécutez d'abord : sudo bash 05-configure-nginx.sh"
    exit 1
fi

# Demander le nom de domaine
echo "Entrez votre nom de domaine (ex: contact-api.example.com) :"
read -r DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ Erreur : Nom de domaine requis"
    exit 1
fi

echo ""
echo "Domaine configuré : $DOMAIN"
echo ""

# Installer Certbot
echo "[1/4] Installation de Certbot..."
apt install -y certbot python3-certbot-nginx
echo "✓ Certbot installé"
echo ""

# Vérifier que le domaine pointe vers le serveur
echo "[2/4] Vérification DNS..."
echo "Vérifiez que votre domaine $DOMAIN pointe vers ce serveur"
echo "IP de ce serveur : $(hostname -I | awk '{print $1}')"
echo ""
echo "Voulez-vous continuer ? (y/n)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Configurez d'abord votre DNS puis relancez ce script."
    exit 0
fi
echo ""

# Obtenir le certificat SSL
echo "[3/4] Obtention du certificat SSL..."
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" || {
    echo "❌ Erreur lors de l'obtention du certificat"
    echo "Vérifiez que :"
    echo "  1. Le domaine $DOMAIN pointe vers l'IP de ce serveur"
    echo "  2. Les ports 80 et 443 sont ouverts"
    echo "  3. Nginx fonctionne correctement"
    exit 1
}
echo "✓ Certificat SSL obtenu"
echo ""

# Tester le renouvellement automatique
echo "[4/4] Test du renouvellement automatique..."
certbot renew --dry-run
echo "✓ Renouvellement automatique configuré"
echo ""

echo "=========================================="
echo "✓ SSL configuré avec succès !"
echo "=========================================="
echo ""
echo "Votre API est maintenant accessible via HTTPS :"
echo "  - https://$DOMAIN"
echo "  - https://$DOMAIN/api/health"
echo "  - https://$DOMAIN/swagger-ui.html"
echo ""
echo "Le certificat se renouvellera automatiquement tous les 90 jours."
echo ""

