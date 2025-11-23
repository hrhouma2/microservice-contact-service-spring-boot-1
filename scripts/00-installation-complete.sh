#!/bin/bash

##############################################################################
# Script 00 : Installation COMPLÈTE automatique
# Usage: sudo bash 00-installation-complete.sh
# Description: Exécute tous les scripts d'installation dans l'ordre
##############################################################################

set -e

echo "========================================================"
echo "   INSTALLATION COMPLÈTE - Contact Service API"
echo "   Ubuntu 24.04 + Docker + PostgreSQL + Nginx"
echo "========================================================"
echo ""
echo "Ce script va installer et configurer TOUT automatiquement :"
echo "  1. Docker et Docker Compose"
echo "  2. Utilisateur 'deploy' avec droits sudo et docker"
echo "  3. Firewall UFW"
echo "  4. Nginx reverse proxy"
echo ""
echo "Durée estimée : 5-10 minutes"
echo ""
read -p "Continuer ? (o/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Installation annulée"
    exit 0
fi

# Vérifier root
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Exécuter avec sudo"
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================================"
echo "ÉTAPE 1/5 : Installation de Docker"
echo "========================================================"
bash "$SCRIPT_DIR/01-installer-docker.sh"

echo ""
echo "========================================================"
echo "ÉTAPE 2/5 : Création de l'utilisateur deploy"
echo "========================================================"
bash "$SCRIPT_DIR/02-creer-utilisateur.sh"

echo ""
echo "========================================================"
echo "ÉTAPE 3/5 : Configuration du firewall"
echo "========================================================"
bash "$SCRIPT_DIR/03-configurer-firewall.sh"

echo ""
echo "========================================================"
echo "ÉTAPE 4/5 : Installation de Nginx"
echo "========================================================"
bash "$SCRIPT_DIR/05-installer-nginx.sh"

echo ""
echo "========================================================"
echo "✓ INSTALLATION SYSTÈME TERMINÉE"
echo "========================================================"
echo ""
echo "Pour déployer l'application :"
echo "  1. Se connecter en tant que deploy :"
echo "     su - deploy"
echo ""
echo "  2. Exécuter le script de déploiement :"
echo "     cd ~/scripts"
echo "     bash 04-deployer-application.sh"
echo ""
echo "OU vous pouvez aussi exécuter maintenant (en restant root) :"
read -p "Déployer l'application maintenant ? (o/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Oo]$ ]]; then
    echo ""
    echo "========================================================"
    echo "ÉTAPE 5/5 : Déploiement de l'application"
    echo "========================================================"
    
    # Copier le script dans le home de deploy
    cp "$SCRIPT_DIR/04-deployer-application.sh" /home/deploy/
    chown deploy:deploy /home/deploy/04-deployer-application.sh
    chmod +x /home/deploy/04-deployer-application.sh
    
    # Exécuter en tant que deploy
    sudo -u deploy bash /home/deploy/04-deployer-application.sh
fi

echo ""
echo "========================================================"
echo "✓ INSTALLATION COMPLÈTE TERMINÉE !"
echo "========================================================"
echo ""

