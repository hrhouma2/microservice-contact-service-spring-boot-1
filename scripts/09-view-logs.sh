#!/bin/bash

echo "=== Logs de l application ==="
echo ""
echo "1. Logs application"
echo "2. Logs PostgreSQL"
echo "3. Logs Docker système"
echo "4. Logs Nginx"
echo ""
read -p "Choisir (1-4): " CHOICE

case $CHOICE in
    1)
        docker compose logs -f app
        ;;
    2)
        docker compose logs -f postgres
        ;;
    3)
        sudo journalctl -u docker -f
        ;;
    4)
        sudo tail -f /var/log/nginx/contact-api-access.log
        ;;
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac
