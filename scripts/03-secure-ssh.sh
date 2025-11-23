#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Sécurisation SSH${NC}"
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Ce script doit être exécuté avec sudo${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/2] Backup configuration...${NC}"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

echo -e "${YELLOW}[2/2] Modification SSH...${NC}"
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

systemctl restart sshd
echo -e "${GREEN}SSH sécurisé !${NC}"
