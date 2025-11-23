#!/bin/bash

##############################################################################
# Script 07 : Sauvegarde de la base de données
# Usage: bash 07-sauvegarder-db.sh
# Description: Crée une sauvegarde de PostgreSQL
##############################################################################

echo "=========================================="
echo "Sauvegarde de la base de données"
echo "=========================================="
echo ""

BACKUP_DIR="$HOME/apps/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/contact_service_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "Création de la sauvegarde..."
docker exec contact-service-db pg_dump -U postgres contact_service > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Sauvegarde créée : $BACKUP_FILE"
    echo "  Taille : $(du -h $BACKUP_FILE | cut -f1)"
    
    # Compresser
    gzip "$BACKUP_FILE"
    echo "✓ Sauvegarde compressée : $BACKUP_FILE.gz"
    echo "  Taille : $(du -h $BACKUP_FILE.gz | cut -f1)"
    
    # Nettoyer les anciennes sauvegardes (> 30 jours)
    find "$BACKUP_DIR" -name "contact_service_*.sql.gz" -mtime +30 -delete
    echo ""
    echo "Anciennes sauvegardes (>30 jours) supprimées"
else
    echo "✗ Erreur lors de la sauvegarde"
    exit 1
fi

echo ""
echo "Sauvegardes disponibles :"
ls -lh "$BACKUP_DIR"
echo ""

