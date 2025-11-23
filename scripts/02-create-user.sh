#!/bin/bash

##############################################################################
# Script 02 : Création d'un utilisateur non-root avec droits Docker
# 
# Ce script doit être exécuté en tant que root ou avec sudo
# Usage : sudo bash 02-create-user.sh
##############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Création d'un utilisateur non-root${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Vérifier si root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Ce script doit être exécuté avec sudo${NC}"
    exit 1
fi

# Demander le nom d'utilisateur
echo -e "${BLUE}Entrez le nom d'utilisateur à créer (recommandé: deploy) :${NC}"
read -p "Username: " USERNAME

# Vérifier si l'utilisateur existe déjà
if id "$USERNAME" &>/dev/null; then
    echo -e "${YELLOW}L'utilisateur $USERNAME existe déjà.${NC}"
    echo -e "${YELLOW}Ajout des groupes si nécessaire...${NC}"
else
    echo ""
    echo -e "${YELLOW}[1/5] Création de l'utilisateur $USERNAME...${NC}"
    adduser $USERNAME
fi

echo ""
echo -e "${YELLOW}[2/5] Ajout au groupe sudo...${NC}"
usermod -aG sudo $USERNAME

echo ""
echo -e "${YELLOW}[3/5] Ajout au groupe docker...${NC}"
usermod -aG docker $USERNAME

echo ""
echo -e "${YELLOW}[4/5] Création de la structure de dossiers...${NC}"
# Créer les dossiers nécessaires
sudo -u $USERNAME mkdir -p /home/$USERNAME/apps
sudo -u $USERNAME mkdir -p /home/$USERNAME/apps/logs
sudo -u $USERNAME mkdir -p /home/$USERNAME/apps/backups

# Permissions
chown -R $USERNAME:$USERNAME /home/$USERNAME/apps

echo ""
echo -e "${YELLOW}[5/5] Configuration du shell...${NC}"
# Ajouter des alias utiles au .bashrc
cat >> /home/$USERNAME/.bashrc <<'EOF'

# Alias Docker
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dcps='docker compose ps'

# Alias utiles
alias ll='ls -lah'
alias apps='cd ~/apps'
EOF

chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Utilisateur créé avec succès !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Afficher les informations
echo -e "${BLUE}Informations de l'utilisateur :${NC}"
echo -e "Username      : $USERNAME"
echo -e "Home directory: /home/$USERNAME"
echo -e "Groupes       : $(groups $USERNAME)"
echo ""

# Tester Docker pour cet utilisateur
echo -e "${YELLOW}Test de Docker pour $USERNAME...${NC}"
sudo -u $USERNAME docker ps > /dev/null 2>&1 && echo -e "${GREEN}✓ Docker fonctionne pour $USERNAME${NC}" || echo -e "${RED}✗ Problème avec Docker${NC}"

echo ""
echo -e "${YELLOW}Pour vous connecter avec cet utilisateur :${NC}"
echo -e "  su - $USERNAME"
echo ""
echo -e "${YELLOW}Pour vous connecter via SSH :${NC}"
echo -e "  ssh $USERNAME@VOTRE_IP"
echo ""
echo -e "${YELLOW}Prochaine étape : Exécuter le script 03-secure-ssh.sh (optionnel)${NC}"
echo ""
