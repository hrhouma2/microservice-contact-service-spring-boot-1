#!/bin/bash
set -e

echo "=== Installation complète automatique ==="
echo ""
echo "Ce script va :"
echo "1. Installer Docker"
echo "2. Créer un utilisateur (deploy)"
echo "3. Configurer le firewall"
echo ""
echo "Appuyez sur Entrée pour continuer..."
read

# Vérifier si root
if [ "$EUID" -ne 0 ]; then 
    echo "Ce script doit être exécuté avec sudo"
    exit 1
fi

echo ""
echo "=== ÉTAPE 1/3 : Installation Docker ==="
bash 01-install-docker.sh

echo ""
echo "=== ÉTAPE 2/3 : Création utilisateur ==="
bash 02-create-user.sh

echo ""
echo "=== ÉTAPE 3/3 : Configuration firewall ==="
bash 04-setup-firewall.sh

echo ""
echo "=== INSTALLATION TERMINÉE ==="
echo ""
echo "Prochaines étapes :"
echo "1. su - deploy"
echo "2. bash ~/apps/contact-service-springboot/scripts/05-deploy-app.sh VOTRE_GITHUB_URL"
echo ""
