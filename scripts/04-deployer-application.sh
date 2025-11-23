#!/bin/bash

##############################################################################
# Script 04 : Déploiement de l'application Contact Service
# Usage: bash 04-deployer-application.sh (en tant qu'utilisateur deploy)
# Description: Clone le projet, configure et démarre l'application
##############################################################################

set -e

echo "=========================================="
echo "Déploiement du Contact Service"
echo "=========================================="
echo ""

# Vérifier qu'on n'est PAS root
if [[ $EUID -eq 0 ]]; then
   echo "Erreur : Ce script NE DOIT PAS être exécuté en root"
   echo "Basculez vers l'utilisateur deploy :"
   echo "  su - deploy"
   echo "Puis relancez : bash 04-deployer-application.sh"
   exit 1
fi

# Vérifier que l'utilisateur est dans le groupe docker
if ! groups | grep -q docker; then
    echo "Erreur : L'utilisateur actuel n'est pas dans le groupe docker"
    echo "Exécutez : sudo usermod -aG docker $USER"
    echo "Puis reconnectez-vous"
    exit 1
fi

echo "Utilisateur actuel : $USER"
echo "Groupes : $(groups)"
echo ""

# Demander l'URL du repository GitHub
echo "Entrez l'URL de votre repository GitHub :"
echo "Exemple : https://github.com/username/contact-service-springboot.git"
read -r REPO_URL

if [[ -z "$REPO_URL" ]]; then
    echo "Erreur : URL du repository requise"
    exit 1
fi

echo ""
echo "[1/6] Création de la structure de dossiers..."
mkdir -p ~/apps/logs
mkdir -p ~/apps/backups

# Extraire le nom du repository depuis l'URL
REPO_NAME=$(basename "$REPO_URL" .git)

echo ""
echo "[2/6] Clonage du repository..."
cd ~/apps

# Supprimer le dossier s'il existe déjà
if [ -d "$REPO_NAME" ]; then
    echo "Le dossier existe déjà. Voulez-vous le supprimer et re-cloner ? (o/n)"
    read -r response
    if [[ "$response" =~ ^[Oo]$ ]]; then
        rm -rf "$REPO_NAME"
    else
        echo "Opération annulée."
        exit 0
    fi
fi

git clone "$REPO_URL"
cd "$REPO_NAME"

echo ""
echo "[3/6] Configuration des variables d'environnement..."
echo ""
echo "Configuration SMTP (Gmail recommandé) :"
echo ""

# Créer le fichier .env interactivement
if [ ! -f .env ]; then
    echo "Création du fichier .env..."
    
    read -p "SMTP_HOST [smtp.gmail.com] : " SMTP_HOST
    SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
    
    read -p "SMTP_PORT [587] : " SMTP_PORT
    SMTP_PORT=${SMTP_PORT:-587}
    
    read -p "SMTP_USER (email complet) : " SMTP_USER
    
    read -sp "SMTP_PASS (mot de passe d'application) : " SMTP_PASS
    echo ""
    
    read -p "CONTACT_NOTIFICATION_EMAIL : " NOTIFICATION_EMAIL
    
    read -p "CORS_ALLOWED_ORIGINS (séparés par virgules) : " CORS_ORIGINS
    
    # Écrire le fichier .env
    cat > .env << EOF
SMTP_HOST=$SMTP_HOST
SMTP_PORT=$SMTP_PORT
SMTP_USER=$SMTP_USER
SMTP_PASS=$SMTP_PASS
CONTACT_NOTIFICATION_EMAIL=$NOTIFICATION_EMAIL
CORS_ALLOWED_ORIGINS=$CORS_ORIGINS
EOF
    
    chmod 600 .env
    echo ""
    echo "Fichier .env créé avec succès"
else
    echo "Le fichier .env existe déjà"
fi

echo ""
echo "[4/6] Vérification de Docker..."
if ! docker ps &>/dev/null; then
    echo "Erreur : Docker n'est pas accessible"
    echo "Vérifiez que Docker est installé et que vous êtes dans le groupe docker"
    exit 1
fi

echo "Docker OK"

echo ""
echo "[5/6] Démarrage de l'application avec Docker Compose..."
docker compose up -d

echo ""
echo "[6/6] Attente du démarrage (30 secondes)..."
sleep 30

echo ""
echo "=========================================="
echo "Déploiement terminé !"
echo "=========================================="
echo ""
echo "Vérifications :"
docker compose ps
echo ""

# Tester le health check
if curl -f http://localhost:8080/api/health &>/dev/null; then
    echo "✓ Health check OK : http://localhost:8080/api/health"
else
    echo "⚠ Health check échoué, vérifiez les logs :"
    echo "  docker compose logs app"
fi

echo ""
echo "Accès à l'application :"
echo "  - API : http://localhost:8080"
echo "  - Swagger : http://localhost:8080/swagger-ui.html"
echo "  - Health : http://localhost:8080/api/health"
echo ""
echo "Commandes utiles :"
echo "  docker compose logs -f        # Voir les logs"
echo "  docker compose ps             # Statut"
echo "  docker compose down           # Arrêter"
echo "  docker compose restart        # Redémarrer"
echo ""
echo "Prochaine étape : Exécuter 05-installer-nginx.sh (avec sudo)"
echo ""

