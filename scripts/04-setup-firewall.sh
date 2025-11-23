#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Configuration Firewall UFW${NC}"
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Exécuter avec sudo${NC}"
    exit 1
fi

ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable
ufw status verbose
echo -e "${GREEN}Firewall configuré !${NC}"
