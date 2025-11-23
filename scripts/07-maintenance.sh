#!/bin/bash

###########################################
# Script 07 : Utilitaires de Maintenance
# Ubuntu 24.04 LTS
# À exécuter en tant qu'utilisateur deploy
###########################################

echo "=========================================="
echo "Utilitaires de Maintenance"
echo "=========================================="
echo ""

# Menu
PS3="Choisissez une action : "
options=(
    "Voir les logs de l'application"
    "Voir les logs PostgreSQL"
    "Redémarrer l'application"
    "Arrêter l'application"
    "Mettre à jour l'application"
    "Sauvegarder la base de données"
    "Nettoyer Docker"
    "Voir l'espace disque"
    "Voir les conteneurs"
    "Quitter"
)

select opt in "${options[@]}"
do
    case $opt in
        "Voir les logs de l'application")
            echo ""
            echo "=== Logs de l'application (Ctrl+C pour quitter) ==="
            cd ~/apps/contact-service-springboot
            docker compose logs -f app
            ;;
        "Voir les logs PostgreSQL")
            echo ""
            echo "=== Logs PostgreSQL (Ctrl+C pour quitter) ==="
            cd ~/apps/contact-service-springboot
            docker compose logs -f postgres
            ;;
        "Redémarrer l'application")
            echo ""
            echo "Redémarrage de l'application..."
            cd ~/apps/contact-service-springboot
            docker compose restart app
            echo "✓ Application redémarrée"
            ;;
        "Arrêter l'application")
            echo ""
            echo "Arrêt de l'application..."
            cd ~/apps/contact-service-springboot
            docker compose down
            echo "✓ Application arrêtée"
            ;;
        "Mettre à jour l'application")
            echo ""
            echo "Mise à jour de l'application..."
            cd ~/apps/contact-service-springboot
            git pull origin main
            docker compose up -d --build
            echo "✓ Application mise à jour"
            ;;
        "Sauvegarder la base de données")
            echo ""
            BACKUP_FILE=~/apps/backups/db_$(date +%Y%m%d_%H%M%S).sql
            echo "Création de la sauvegarde : $BACKUP_FILE"
            docker exec contact-service-db pg_dump -U postgres contact_service > "$BACKUP_FILE"
            echo "✓ Sauvegarde créée : $BACKUP_FILE"
            echo "Taille : $(du -h "$BACKUP_FILE" | cut -f1)"
            ;;
        "Nettoyer Docker")
            echo ""
            echo "Nettoyage de Docker..."
            docker system prune -a -f
            echo "✓ Docker nettoyé"
            ;;
        "Voir l'espace disque")
            echo ""
            df -h
            echo ""
            docker system df
            ;;
        "Voir les conteneurs")
            echo ""
            docker ps -a
            echo ""
            docker compose ps
            ;;
        "Quitter")
            echo "Au revoir !"
            break
            ;;
        *) 
            echo "Option invalide $REPLY"
            ;;
    esac
    echo ""
done

