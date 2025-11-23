#!/bin/bash

##############################################################################
# Script 02 : Création utilisateur deploy avec droits sudo et docker
# Usage: sudo bash 02-creer-utilisateur.sh
# Description: Crée l'utilisateur 'deploy' de façon sécurisée
##############################################################################

set -e

echo "=========================================="
echo "Création utilisateur deploy"
echo "=========================================="
echo ""

# Vérifier root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Exécuter avec sudo"
   echo "Usage: sudo bash 02-creer-utilisateur.sh"
   exit 1
fi

USERNAME="deploy"

# Vérifier si existe
if id "$USERNAME" &>/dev/null; then
    echo "L'utilisateur '$USERNAME' existe déjà"
    echo "Voulez-vous reconfigurer ses droits ? (o/n)"
    read -r response
    if [[ ! "$response" =~ ^[Oo]$ ]]; then
        exit 0
    fi
    SKIP_CREATE=true
else
    SKIP_CREATE=false
fi

if [ "$SKIP_CREATE" = false ]; then
    echo "[1/6] Création de l'utilisateur $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME"
    
    echo ""
    echo "Définissez un MOT DE PASSE FORT pour $USERNAME :"
    passwd "$USERNAME"
fi

echo ""
echo "[2/6] Ajout au groupe sudo..."
usermod -aG sudo "$USERNAME"

echo ""
echo "[3/6] Ajout au groupe docker..."
usermod -aG docker "$USERNAME"

echo ""
echo "[4/6] Création de la structure de dossiers..."
sudo -u "$USERNAME" bash << 'EOFUSER'
mkdir -p ~/apps
mkdir -p ~/apps/logs
mkdir -p ~/apps/backups
mkdir -p ~/.ssh
chmod 700 ~/.ssh
EOFUSER

echo ""
echo "[5/6] Configuration des permissions..."
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"

echo ""
echo "[6/6] Configuration SSH pour $USERNAME..."
echo ""
echo "Voulez-vous copier les clés SSH de root vers $USERNAME ? (o/n)"
read -r copy_ssh

if [[ "$copy_ssh" =~ ^[Oo]$ ]]; then
    if [ -d /root/.ssh ]; then
        cp -r /root/.ssh/* /home/"$USERNAME"/.ssh/ 2>/dev/null || true
        chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
        chmod 700 /home/"$USERNAME"/.ssh
        chmod 600 /home/"$USERNAME"/.ssh/authorized_keys 2>/dev/null || true
        echo "Clés SSH copiées"
    else
        echo "Aucune clé SSH trouvée dans /root/.ssh"
    fi
fi

echo ""
echo "=========================================="
echo "✓ Utilisateur créé avec succès !"
echo "=========================================="
echo ""
echo "Informations :"
echo "  Utilisateur : $USERNAME"
echo "  Home : /home/$USERNAME"
echo "  Groupes : $(groups $USERNAME)"
echo ""
echo "Pour basculer vers cet utilisateur :"
echo "  su - $USERNAME"
echo ""
echo "Pour tester Docker sans sudo :"
echo "  su - $USERNAME"
echo "  docker ps"
echo ""
echo "Prochaine étape : sudo bash 03-configurer-firewall.sh"
echo ""
