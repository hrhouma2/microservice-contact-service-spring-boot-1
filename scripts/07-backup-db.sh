#!/bin/bash
set -e

echo "=== Sauvegarde automatique de la base de données ==="
echo ""

BACKUP_DIR="$HOME/apps/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/db_$TIMESTAMP.sql"

mkdir -p $BACKUP_DIR

echo "Création de la sauvegarde..."
docker exec contact-service-db pg_dump -U postgres contact_service > $BACKUP_FILE

if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Sauvegarde créée : $BACKUP_FILE ($SIZE)"
    
    # Nettoyer les anciennes sauvegardes (garder 30 derniers jours)
    find $BACKUP_DIR -name "db_*.sql" -mtime +30 -delete
    echo "Anciennes sauvegardes nettoyées (>30 jours)"
else
    echo "Erreur lors de la sauvegarde"
    exit 1
fi
