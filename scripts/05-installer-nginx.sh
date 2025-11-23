#!/bin/bash

##############################################################################
# Script 05 : Installation et configuration de Nginx
# Usage: sudo bash 05-installer-nginx.sh
# Description: Installe Nginx et configure le reverse proxy
##############################################################################

set -e

echo "=========================================="
echo "Installation de Nginx"
echo "=========================================="
echo ""

# Vérifier root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Exécuter avec sudo"
   exit 1
fi

echo "[1/5] Installation de Nginx..."
apt install -y nginx

echo ""
echo "[2/5] Activation de Nginx..."
systemctl enable nginx
systemctl start nginx

echo ""
echo "[3/5] Configuration du reverse proxy..."

# Demander l'IP ou le domaine
IP_VM=$(hostname -I | awk '{print $1}')
echo "IP de cette VM : $IP_VM"
echo ""
echo "Avez-vous un nom de domaine ? (o/n)"
read -r has_domain

if [[ "$has_domain" =~ ^[Oo]$ ]]; then
    read -p "Nom de domaine (ex: contact-api.votredomaine.com) : " DOMAIN
    SERVER_NAME="$DOMAIN"
else
    SERVER_NAME="$IP_VM"
fi

# Créer la configuration Nginx
cat > /etc/nginx/sites-available/contact-api << EOF
server {
    listen 80;
    server_name $SERVER_NAME;

    # Logs
    access_log /var/log/nginx/contact-api-access.log;
    error_log /var/log/nginx/contact-api-error.log;

    # Proxy vers Spring Boot
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check (sans logs)
    location /api/health {
        proxy_pass http://localhost:8080/api/health;
        access_log off;
    }
}
EOF

echo ""
echo "[4/5] Activation du site..."
ln -sf /etc/nginx/sites-available/contact-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo ""
echo "[5/5] Test et rechargement de Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo ""
    echo "=========================================="
    echo "✓ Nginx configuré avec succès !"
    echo "=========================================="
    echo ""
    echo "Votre API est maintenant accessible via :"
    echo "  http://$SERVER_NAME"
    echo "  http://$SERVER_NAME/swagger-ui.html"
    echo "  http://$SERVER_NAME/api/health"
    echo ""
    
    if [[ "$has_domain" =~ ^[Oo]$ ]]; then
        echo "Pour activer HTTPS avec Let's Encrypt :"
        echo "  sudo certbot --nginx -d $DOMAIN"
        echo ""
    fi
    
    echo "Testez maintenant :"
    echo "  curl http://$SERVER_NAME/api/health"
else
    echo "ERREUR dans la configuration Nginx"
    exit 1
fi

echo ""
echo "Prochaine étape : Tester l'API avec 06-tester-api.sh"
echo ""

