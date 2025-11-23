#!/bin/bash
echo "Backup base de données..."
docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +%Y%m%d_%H%M%S).sql
echo "Backup créé dans ~/apps/backups/"
ls -lh ~/apps/backups/ | tail -5
