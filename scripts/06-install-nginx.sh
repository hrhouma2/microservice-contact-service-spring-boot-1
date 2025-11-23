#!/bin/bash
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installation de Nginx${NC}"

if [ "$EUID" -ne 0 ]; then 
    echo "Exécuter avec sudo"
    exit 1
fi

echo -e "${YELLOW}[1/3] Installation Nginx...${NC}"
apt install -y nginx

echo -e "${YELLOW}[2/3] Configuration reverse proxy...${NC}"
cat > /etc/nginx/sites-available/contact-api <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/contact-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo -e "${YELLOW}[3/3] Démarrage Nginx...${NC}"
nginx -t
systemctl restart nginx
systemctl enable nginx

echo -e "${GREEN}Nginx configuré !${NC}"
echo "Testez : curl http://VOTRE_IP/api/health"
