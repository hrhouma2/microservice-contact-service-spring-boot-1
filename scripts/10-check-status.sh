#!/bin/bash

##############################################################################
# Script 10 : Vérification de l'état du système
# Usage: bash 10-check-status.sh
# Description: Affiche un résumé complet de l'installation
##############################################################################

echo "=========================================="
echo "   État du Contact Service API"
echo "=========================================="
echo ""

# Fonction pour afficher le statut
check_service() {
    if [ "$2" = "ok" ]; then
        echo "  ✅ $1"
    elif [ "$2" = "warn" ]; then
        echo "  ⚠️  $1"
    else
        echo "  ❌ $1"
    fi
}

# 1. Vérifier Docker
echo "🐳 Docker"
if systemctl is-active --quiet docker; then
    check_service "Service Docker actif" "ok"
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo "     Version: $DOCKER_VERSION"
else
    check_service "Service Docker inactif" "fail"
fi
echo ""

# 2. Vérifier les conteneurs
echo "📦 Conteneurs"
if [ -d ~/apps/contact-service-springboot ]; then
    cd ~/apps/contact-service-springboot
    
    # App container
    if docker compose ps app 2>/dev/null | grep -q "Up"; then
        check_service "contact-service-app: Running" "ok"
    else
        check_service "contact-service-app: Stopped" "fail"
    fi
    
    # DB container
    if docker compose ps postgres 2>/dev/null | grep -q "Up"; then
        check_service "contact-service-db: Running" "ok"
    else
        check_service "contact-service-db: Stopped" "fail"
    fi
else
    check_service "Application non trouvée" "fail"
fi
echo ""

# 3. Vérifier l'API
echo "🌐 API Health Check"
if curl -f -s http://localhost:8080/api/health > /dev/null 2>&1; then
    check_service "API accessible sur port 8080" "ok"
    
    # Obtenir le statut
    STATUS=$(curl -s http://localhost:8080/api/health | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    if [ "$STATUS" = "ok" ]; then
        check_service "Health status: OK" "ok"
    else
        check_service "Health status: $STATUS" "warn"
    fi
else
    check_service "API non accessible" "fail"
fi
echo ""

# 4. Vérifier la base de données
echo "💾 Base de Données"
if docker exec contact-service-db pg_isready -U postgres > /dev/null 2>&1; then
    check_service "PostgreSQL opérationnel" "ok"
    
    # Compter les soumissions
    COUNT=$(docker exec contact-service-db psql -U postgres -d contact_service -t -c "SELECT COUNT(*) FROM form_submissions;" 2>/dev/null | xargs)
    if [ -n "$COUNT" ]; then
        check_service "Soumissions enregistrées: $COUNT" "ok"
    fi
else
    check_service "PostgreSQL non accessible" "fail"
fi
echo ""

# 5. Vérifier le firewall
echo "🔥 Firewall"
if command -v ufw &> /dev/null; then
    if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
        check_service "UFW actif" "ok"
        
        # Vérifier les ports
        if sudo ufw status 2>/dev/null | grep -q "22/tcp"; then
            check_service "Port 22 (SSH) autorisé" "ok"
        fi
        if sudo ufw status 2>/dev/null | grep -q "80/tcp"; then
            check_service "Port 80 (HTTP) autorisé" "ok"
        fi
        if sudo ufw status 2>/dev/null | grep -q "443/tcp"; then
            check_service "Port 443 (HTTPS) autorisé" "ok"
        fi
    else
        check_service "UFW inactif" "warn"
    fi
else
    check_service "UFW non installé" "warn"
fi
echo ""

# 6. Vérifier Nginx (si installé)
echo "🔀 Nginx"
if systemctl list-units --type=service --all | grep -q nginx; then
    if systemctl is-active --quiet nginx; then
        check_service "Nginx actif" "ok"
    else
        check_service "Nginx installé mais inactif" "warn"
    fi
else
    check_service "Nginx non installé (optionnel)" "warn"
fi
echo ""

# 7. Ressources système
echo "💻 Ressources Système"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    check_service "Disque: ${DISK_USAGE}% utilisé" "ok"
else
    check_service "Disque: ${DISK_USAGE}% utilisé (attention)" "warn"
fi

MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
if [ "$MEM_PERCENT" -lt 80 ]; then
    check_service "RAM: ${MEM_USED}MB/${MEM_TOTAL}MB (${MEM_PERCENT}%)" "ok"
else
    check_service "RAM: ${MEM_USED}MB/${MEM_TOTAL}MB (${MEM_PERCENT}%) (attention)" "warn"
fi

CPU_COUNT=$(nproc)
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
check_service "CPU: ${CPU_COUNT} cores, load: ${LOAD_AVG}" "ok"
echo ""

# 8. Dernières soumissions
echo "📬 Dernières Soumissions"
if docker exec contact-service-db psql -U postgres -d contact_service -t -c "SELECT email, created_at FROM form_submissions ORDER BY created_at DESC LIMIT 3;" 2>/dev/null | grep -q "."; then
    echo ""
    docker exec contact-service-db psql -U postgres -d contact_service -c "SELECT email, name, created_at FROM form_submissions ORDER BY created_at DESC LIMIT 3;" 2>/dev/null
else
    check_service "Aucune soumission" "warn"
fi
echo ""

# Résumé
echo "=========================================="
echo "   Résumé"
echo "=========================================="
echo ""

# Vérifier si tout est OK
ALL_OK=true

if ! systemctl is-active --quiet docker; then
    ALL_OK=false
fi

if [ -d ~/apps/contact-service-springboot ]; then
    cd ~/apps/contact-service-springboot
    if ! docker compose ps app 2>/dev/null | grep -q "Up"; then
        ALL_OK=false
    fi
    if ! docker compose ps postgres 2>/dev/null | grep -q "Up"; then
        ALL_OK=false
    fi
else
    ALL_OK=false
fi

if ! curl -f -s http://localhost:8080/api/health > /dev/null 2>&1; then
    ALL_OK=false
fi

if [ "$ALL_OK" = true ]; then
    echo "✅ Système opérationnel - Tous les services fonctionnent"
    echo ""
    echo "Accès:"
    echo "  - API: http://localhost:8080"
    echo "  - Swagger: http://localhost:8080/swagger-ui.html"
    echo "  - Health: http://localhost:8080/api/health"
else
    echo "⚠️  Certains services présentent des problèmes"
    echo ""
    echo "Commandes de dépannage:"
    echo "  - Voir les logs: docker compose logs app"
    echo "  - Redémarrer: docker compose restart"
    echo "  - Vérifier Docker: systemctl status docker"
fi

echo ""
echo "Commandes utiles:"
echo "  bash 06-tester-api.sh      - Tester l'API"
echo "  bash 09-view-logs.sh       - Voir les logs"
echo "  bash 07-sauvegarder-db.sh  - Sauvegarder la DB"
echo ""
