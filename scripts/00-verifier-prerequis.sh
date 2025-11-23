#!/bin/bash

##############################################################################
# Script 00 : Vérification des Prérequis
# Usage: bash 00-verifier-prerequis.sh
# Description: Vérifie que la VM est prête pour l'installation
##############################################################################

echo "=========================================="
echo "Vérification des Prérequis"
echo "Contact Service API - Installation"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Fonction pour afficher les résultats
check_ok() {
    echo "✓ $1"
}

check_fail() {
    echo "✗ $1"
    ((ERRORS++))
}

check_warn() {
    echo "⚠ $1"
    ((WARNINGS++))
}

echo "[1/10] Vérification du système d'exploitation..."
if grep -q "Ubuntu" /etc/os-release; then
    VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    if [ "$VERSION" = "24.04" ]; then
        check_ok "Ubuntu 24.04 LTS détecté"
    else
        check_warn "Ubuntu $VERSION détecté (recommandé : 24.04)"
    fi
else
    check_warn "Système non-Ubuntu détecté (non testé)"
fi

echo ""
echo "[2/10] Vérification de la connexion Internet..."
if ping -c 1 google.com &>/dev/null; then
    check_ok "Connexion Internet OK"
else
    check_fail "Pas de connexion Internet"
fi

echo ""
echo "[3/10] Vérification de l'espace disque..."
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${DISK_FREE%%.*}" -ge 10 ]; then
    check_ok "Espace disque suffisant (${DISK_FREE}G disponible)"
else
    check_fail "Espace disque insuffisant (${DISK_FREE}G, minimum 10G requis)"
fi

echo ""
echo "[4/10] Vérification de la RAM..."
RAM_MB=$(free -m | awk 'NR==2 {print $2}')
if [ "$RAM_MB" -ge 2000 ]; then
    check_ok "RAM suffisante (${RAM_MB}MB)"
else
    check_warn "RAM limitée (${RAM_MB}MB, recommandé : 4096MB)"
fi

echo ""
echo "[5/10] Vérification des droits sudo/root..."
if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
    check_ok "Droits administrateur disponibles"
else
    check_fail "Pas de droits sudo/root"
fi

echo ""
echo "[6/10] Vérification de Git..."
if command -v git &>/dev/null; then
    check_ok "Git installé ($(git --version))"
else
    check_warn "Git non installé (sera installé automatiquement)"
fi

echo ""
echo "[7/10] Vérification de Curl..."
if command -v curl &>/dev/null; then
    check_ok "Curl installé"
else
    check_warn "Curl non installé (sera installé automatiquement)"
fi

echo ""
echo "[8/10] Vérification de Docker..."
if command -v docker &>/dev/null; then
    check_warn "Docker déjà installé ($(docker --version))"
    if systemctl is-active --quiet docker; then
        check_ok "Service Docker actif"
    else
        check_warn "Service Docker inactif"
    fi
else
    check_ok "Docker non installé (prêt pour installation)"
fi

echo ""
echo "[9/10] Vérification des ports..."
if command -v ss &>/dev/null || command -v netstat &>/dev/null; then
    for port in 80 443 8080 5432; do
        if ss -tuln 2>/dev/null | grep -q ":$port " || netstat -tuln 2>/dev/null | grep -q ":$port "; then
            check_warn "Port $port déjà utilisé"
        else
            check_ok "Port $port disponible"
        fi
    done
else
    check_warn "Impossible de vérifier les ports (ss/netstat non disponible)"
fi

echo ""
echo "[10/10] Vérification du hostname..."
HOSTNAME=$(hostname)
check_ok "Hostname : $HOSTNAME"

echo ""
echo "=========================================="
echo "Résumé de la Vérification"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✓ Tous les prérequis sont remplis !"
    echo ""
    echo "Vous pouvez lancer l'installation :"
    echo "  sudo bash 00-installation-complete.sh"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠ $WARNINGS avertissement(s) détecté(s)"
    echo ""
    echo "Vous pouvez continuer, mais vérifiez les points ci-dessus."
    echo ""
    read -p "Continuer quand même ? (o/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        echo "Lancement de l'installation :"
        echo "  sudo bash 00-installation-complete.sh"
        echo ""
        exit 0
    else
        echo "Installation annulée"
        exit 1
    fi
else
    echo "✗ $ERRORS erreur(s) critique(s) détectée(s)"
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠ $WARNINGS avertissement(s) supplémentaire(s)"
    fi
    echo ""
    echo "Veuillez corriger les erreurs avant de continuer."
    echo ""
    exit 1
fi

