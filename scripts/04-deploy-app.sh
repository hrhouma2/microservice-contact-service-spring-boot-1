#!/bin/bash

###########################################
# Script 04 : Déploiement de l'application
# Ubuntu 24.04 LTS
# À exécuter en tant qu'utilisateur 'deploy' (PAS root)
###########################################

set -e

echo "=========================================="
echo "Déploiement de Contact Service API"
echo "=========================================="
echo ""

# Vérifier qu'on n'est PAS root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Erreur : Ce script NE DOIT PAS être exécuté en root !"
    echo "Usage : bash 04-deploy-app.sh (en tant qu'utilisateur deploy)"
    exit 1
fi

# Vérifier que Docker est accessible
if ! docker ps &>/dev/null; then
    echo "❌ Erreur : Docker n'est pas accessible"
    echo "Solution : Ajoutez votre utilisateur au groupe docker"
    echo "  sudo usermod -aG docker $USER"
    echo "  Puis déconnectez-vous et reconnectez-vous"
    exit 1
fi

echo "✓ Docker accessible"
echo ""

# Demander l'URL du repository
echo "Entrez l'URL de votre repository GitHub :"
echo "Exemple : https://github.com/username/contact-service-springboot.git"
read -r REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ Erreur : URL du repository requise"
    exit 1
fi

# Aller dans le dossier apps
echo "[1/8] Préparation du dossier..."
cd ~/apps
echo "✓ Dossier : ~/apps"
echo ""

# Cloner le projet
echo "[2/8] Clonage du repository..."
if [ -d "contact-service-springboot" ]; then
    echo "⚠️  Le dossier existe déjà. Suppression..."
    rm -rf contact-service-springboot
fi
git clone "$REPO_URL"
cd contact-service-springboot
echo "✓ Projet cloné"
echo ""

# Créer le fichier .env
echo "[3/8] Configuration des variables d'environnement..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✓ Fichier .env créé depuis .env.example"
    else
        cat > .env << 'EOF'
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
CONTACT_NOTIFICATION_EMAIL=notifications@yourdomain.com
CORS_ALLOWED_ORIGINS=http://localhost:8080
EOF
        echo "✓ Fichier .env créé par défaut"
    fi
    echo ""
    echo "⚠️  IMPORTANT : Éditez le fichier .env avec vos credentials !"
    echo "nano .env"
    echo ""
    read -p "Appuyez sur Entrée après avoir édité .env..."
else
    echo "ℹ️  Le fichier .env existe déjà"
fi
echo ""

# Vérifier que .env est rempli
echo "[4/8] Vérification du fichier .env..."
if grep -q "your-email@gmail.com" .env || grep -q "your-app-password" .env; then
    echo "⚠️  Le fichier .env contient encore des valeurs d'exemple !"
    echo "Voulez-vous continuer quand même ? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Éditer .env puis relancer le script."
        exit 1
    fi
else
    echo "✓ Fichier .env configuré"
fi
echo ""

# Vérifier les fichiers nécessaires
echo "[5/8] Vérification des fichiers..."
if [ ! -f docker-compose.yml ]; then
    echo "❌ Erreur : docker-compose.yml introuvable"
    exit 1
fi
if [ ! -f Dockerfile ]; then
    echo "❌ Erreur : Dockerfile introuvable"
    exit 1
fi
echo "✓ Fichiers Docker présents"
echo ""

# Lancer l'application
echo "[6/8] Construction et lancement de l'application..."
echo "⏳ Cela peut prendre 3-5 minutes (Maven build)..."
docker compose up -d --build
echo "✓ Application lancée"
echo ""

# Attendre que l'application soit prête
echo "[7/8] Attente du démarrage de l'application..."
sleep 10
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
        echo "✓ Application prête"
        break
    fi
    ATTEMPT=$((ATTEMPT+1))
    echo "Attente... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "⚠️  L'application prend plus de temps que prévu"
    echo "Vérifiez les logs : docker compose logs -f app"
fi
echo ""

# Vérification finale
echo "[8/8] Vérification finale..."
docker compose ps
echo ""

echo "=========================================="
echo "✓ Déploiement terminé avec succès !"
echo "=========================================="
echo ""
echo "Informations :"
echo "  - URL locale : http://localhost:8080"
echo "  - Health check : http://localhost:8080/api/health"
echo "  - Swagger UI : http://localhost:8080/swagger-ui.html"
echo ""
echo "Commandes utiles :"
echo "  - Voir les logs : docker compose logs -f"
echo "  - Arrêter : docker compose down"
echo "  - Redémarrer : docker compose restart"
echo ""
echo "Prochaine étape : Configurer Nginx (optionnel)"
echo "Usage : sudo bash 05-configure-nginx.sh"
echo ""

