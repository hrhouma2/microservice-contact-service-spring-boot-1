#!/bin/bash
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echo -e "${GREEN}Configuration SSL avec Certbot${NC}"
if [ "$EUID" -ne 0 ]; then echo "Sudo requis"; exit 1; fi
read -p "Nom de domaine (ex: api.exemple.com) : " DOMAIN
read -p "Email pour SSL : " EMAIL
echo -e "${YELLOW}Installation Certbot...${NC}"
apt install -y certbot python3-certbot-nginx
echo -e "${YELLOW}Obtention certificat SSL...${NC}"
certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect
echo -e "${GREEN}SSL configuré pour $DOMAIN !${NC}"
echo "Renouvellement auto: sudo certbot renew --dry-run"
