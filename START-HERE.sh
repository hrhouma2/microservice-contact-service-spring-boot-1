#!/bin/bash

##############################################################################
# START HERE - Script de Démarrage Rapide
# Usage: bash START-HERE.sh
# Description: Point d'entrée pour étudiants - Guide interactif
##############################################################################

clear

cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        📚 CONTACT SERVICE API - Installation sur VM            ║
║                                                                ║
║            Bienvenue ! Ce script va vous guider.               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

echo ""
echo "👋 Bonjour ! Vous êtes sur le point d'installer le Contact Service API."
echo ""
echo "Avant de commencer, vérifiez que vous avez :"
echo "  ✓ Une VM Ubuntu 24.04"
echo "  ✓ Accès root via SSH"
echo "  ✓ Un compte Gmail avec mot de passe d'application"
echo ""
read -p "Avez-vous tout cela ? (o/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo ""
    echo "Pas de problème ! Consultez d'abord :"
    echo "  📘 scripts/GUIDE-INSTALLATION-DEBUTANTS.md"
    echo ""
    exit 0
fi

clear

cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                    CHOIX DU MODE                               ║
╚════════════════════════════════════════════════════════════════╝

Choisissez votre niveau :

  1. 🎓 Débutant - Je découvre Linux/Docker
     → Vous serez guidé étape par étape avec explications

  2. 🚀 Intermédiaire - J'ai des bases
     → Installation automatique avec vérifications

  3. 📚 Documentation - Je veux lire d'abord
     → Accès aux guides et FAQ

  4. ❌ Quitter

EOF

read -p "Votre choix (1-4) : " choice

case $choice in
    1)
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           MODE DÉBUTANT - Guide Pas à Pas                     ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Excellent choix ! Voici votre parcours :"
        echo ""
        echo "📖 Étape 1 : Lisez le TUTORIEL-VIDEO.md"
        echo "   Il contient TOUTES les commandes à exécuter dans l'ordre."
        echo ""
        echo "   Commande pour l'ouvrir :"
        echo "   cat scripts/TUTORIEL-VIDEO.md | less"
        echo ""
        echo "✅ Étape 2 : Imprimez la CHECKLIST.md"
        echo "   Pour cocher au fur et à mesure."
        echo ""
        echo "🔧 Étape 3 : Vérifiez les prérequis"
        echo "   Commande : bash scripts/00-verifier-prerequis.sh"
        echo ""
        echo "🚀 Étape 4 : Lancez l'installation"
        echo "   Commande : sudo bash scripts/00-installation-complete.sh"
        echo ""
        echo "❓ En cas de problème : Consultez scripts/FAQ.md"
        echo ""
        read -p "Voulez-vous commencer la vérification des prérequis maintenant ? (o/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Oo]$ ]]; then
            bash scripts/00-verifier-prerequis.sh
        else
            echo "OK ! Quand vous êtes prêt, exécutez :"
            echo "  bash scripts/00-verifier-prerequis.sh"
        fi
        ;;
    
    2)
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║        MODE INTERMÉDIAIRE - Installation Automatique          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Parfait ! Voici les étapes :"
        echo ""
        echo "1. Vérification des prérequis..."
        echo ""
        
        bash scripts/00-verifier-prerequis.sh
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Prérequis OK !"
            echo ""
            read -p "Lancer l'installation complète maintenant ? (o/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Oo]$ ]]; then
                sudo bash scripts/00-installation-complete.sh
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo "✅ Installation terminée !"
                    echo ""
                    echo "Vérification de l'état du système..."
                    bash scripts/10-check-status.sh
                fi
            fi
        else
            echo ""
            echo "⚠️  Corrigez les problèmes avant de continuer."
        fi
        ;;
    
    3)
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    DOCUMENTATION                               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "📚 Documentation disponible :"
        echo ""
        echo "Pour les Débutants :"
        echo "  1. scripts/GUIDE-INSTALLATION-DEBUTANTS.md"
        echo "     → Guide complet avec prérequis et explications"
        echo ""
        echo "  2. scripts/TUTORIEL-VIDEO.md"
        echo "     → Tutoriel étape par étape (15 min)"
        echo ""
        echo "  3. scripts/CHECKLIST.md"
        echo "     → À imprimer et cocher"
        echo ""
        echo "  4. scripts/FAQ.md"
        echo "     → 28 questions fréquentes"
        echo ""
        echo "Pour les Formateurs :"
        echo "  5. scripts/RESUME-ENSEIGNANT.md"
        echo "     → Résumé pour préparer le TP"
        echo ""
        echo "  6. scripts/RAPPORT-ANALYSE.md"
        echo "     → Analyse complète du projet"
        echo ""
        echo "Scripts Disponibles :"
        echo "  • 00-verifier-prerequis.sh     - Vérifier avant installation"
        echo "  • 00-installation-complete.sh  - Installation tout-en-un"
        echo "  • 06-tester-api.sh             - Tester l'API"
        echo "  • 10-check-status.sh           - Vérifier l'état"
        echo "  • Plus de scripts dans scripts/"
        echo ""
        echo "Commande pour lire un fichier :"
        echo "  cat scripts/FICHIER.md | less"
        echo "  (Utilisez flèches et 'q' pour quitter)"
        echo ""
        read -p "Appuyez sur Entrée pour continuer..."
        ;;
    
    4)
        echo ""
        echo "Au revoir ! À bientôt."
        echo ""
        exit 0
        ;;
    
    *)
        echo ""
        echo "Choix invalide."
        echo "Relancez le script : bash START-HERE.sh"
        exit 1
        ;;
esac

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💡 Commandes utiles :"
echo ""
echo "  bash scripts/10-check-status.sh   - Vérifier l'état du système"
echo "  bash scripts/06-tester-api.sh     - Tester l'API"
echo "  cat scripts/FAQ.md | less         - Voir la FAQ"
echo ""
echo "  docker compose logs -f app        - Voir les logs en temps réel"
echo "  docker compose ps                 - Voir les conteneurs"
echo "  docker compose restart            - Redémarrer l'application"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🆘 Besoin d'aide ? Consultez scripts/FAQ.md"
echo ""

