#!/bin/bash

##############################################################################
# Script 08 : Restauration de la base de données
# Usage: bash 08-restaurer-db.sh [fichier_backup.sql.gz]
# Description: Restaure PostgreSQL depuis une sauvegarde
##############################################################################

set -e

echo "=========================================="
echo "Restauration de la base de données"
echo "=========================================="
echo ""

BACKUP_DIR="$HOME/apps/backups"

if [ -z "$1" ]; then
    echo "Sauvegardes disponibles :"
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "Aucune sauvegarde trouvée"
    echo ""
    echo "Usage: bash 08-restaurer-db.sh <fichier_backup.sql.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Erreur : Fichier $BACKUP_FILE introuvable"
    exit 1
fi

echo "Fichier à restaurer : $BACKUP_FILE"
echo ""
echo "⚠️  ATTENTION : Cette opération va REMPLACER toutes les données actuelles"
read -p "Continuer ? (o/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Restauration annulée"
    exit 0
fi

echo ""
echo "[1/4] Arrêt de l'application..."
cd ~/apps/contact-service-springboot
docker compose stop app

echo ""
echo "[2/4] Décompression de la sauvegarde..."
TEMP_FILE="/tmp/restore_temp.sql"
gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"

echo ""
echo "[3/4] Restauration dans PostgreSQL..."
docker exec -i contact-service-db psql -U postgres contact_service < "$TEMP_FILE"

rm "$TEMP_FILE"

echo ""
echo "[4/4] Redémarrage de l'application..."
docker compose start app

echo ""
echo "=========================================="
echo "✓ Restauration terminée"
echo "=========================================="
echo ""
docker compose ps
echo ""

