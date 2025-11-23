#!/bin/bash

###########################################
# Script 05 : Configuration de Nginx
# Ubuntu 24.04 LTS
# À exécuter avec sudo
###########################################

set -e

echo "=========================================="
echo "Configuration de Nginx"
echo "=========================================="
echo ""

# Vérifier si on est root ou sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Erreur : Ce script doit être exécuté avec sudo"
    echo "Usage : sudo bash 05-configure-nginx.sh"
    exit 1
fi

# Installer Nginx
echo "[1/5] Installation de Nginx..."
apt install -y nginx
echo "✓ Nginx installé"
echo ""

# Démarrer et activer Nginx
echo "[2/5] Démarrage de Nginx..."
systemctl start nginx
systemctl enable nginx
echo "✓ Nginx démarré et activé"
echo ""

# Obtenir l'IP de la VM
IP_VM=$(hostname -I | awk '{print $1}')

# Créer la configuration
echo "[3/5] Configuration du reverse proxy..."
cat > /etc/nginx/sites-available/contact-api << EOF
server {
    listen 80;
    server_name $IP_VM;

    # Logs
    access_log /var/log/nginx/contact-api-access.log;
    error_log /var/log/nginx/contact-api-error.log;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /api/health {
        proxy_pass http://localhost:8080/api/health;
        access_log off;
    }
}
EOF
echo "✓ Configuration créée"
echo ""

# Activer le site
echo "[4/5] Activation du site..."
ln -sf /etc/nginx/sites-available/contact-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
echo "✓ Site activé"
echo ""

# Tester et recharger
echo "[5/5] Test et rechargement de Nginx..."
nginx -t
systemctl reload nginx
echo "✓ Nginx rechargé"
echo ""

echo "=========================================="
echo "✓ Nginx configuré avec succès !"
echo "=========================================="
echo ""
echo "Accès à l'API :"
echo "  - Depuis la VM : http://localhost"
echo "  - Depuis l'extérieur : http://$IP_VM"
echo ""
echo "Endpoints :"
echo "  - Health : http://$IP_VM/api/health"
echo "  - Swagger : http://$IP_VM/swagger-ui.html"
echo "  - Contact : POST http://$IP_VM/api/contact"
echo ""
echo "Pour tester depuis votre PC :"
echo "  curl http://$IP_VM/api/health"
echo ""

