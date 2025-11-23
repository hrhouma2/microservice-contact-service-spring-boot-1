# Scripts d'Installation - Version Nettoyée

## Scripts Essentiels (14 fichiers)

### Installation Système (root)

| Script | Description | Usage |
|--------|-------------|-------|
| **00-verifier-prerequis.sh** | Vérifier les prérequis avant installation | `bash 00-verifier-prerequis.sh` |
| **00-installation-complete.sh** | Installation automatique complète | `sudo bash 00-installation-complete.sh` |
| **01-installer-docker.sh** | Installer Docker et Docker Compose | `sudo bash 01-installer-docker.sh` |
| **02-creer-utilisateur.sh** | Créer utilisateur deploy | `sudo bash 02-creer-utilisateur.sh` |
| **03-configurer-firewall.sh** | Configurer le firewall UFW | `sudo bash 03-configurer-firewall.sh` |

### Déploiement Application (utilisateur deploy)

| Script | Description | Usage |
|--------|-------------|-------|
| **04-deployer-application.sh** | Cloner et démarrer l'application | `bash 04-deployer-application.sh` |
| **05-installer-nginx.sh** | Installer Nginx (reverse proxy) | `sudo bash 05-installer-nginx.sh` |
| **06-configure-ssl.sh** | Configurer SSL/HTTPS | `sudo bash 06-configure-ssl.sh` |
| **06-tester-api.sh** | Tester tous les endpoints de l'API | `bash 06-tester-api.sh` |

### Maintenance (utilisateur deploy)

| Script | Description | Usage |
|--------|-------------|-------|
| **07-maintenance.sh** | Menu de maintenance complet | `bash 07-maintenance.sh` |
| **07-sauvegarder-db.sh** | Sauvegarder la base de données | `bash 07-sauvegarder-db.sh` |
| **08-restaurer-db.sh** | Restaurer une sauvegarde | `bash 08-restaurer-db.sh` |
| **09-mettre-a-jour.sh** | Mettre à jour l'application | `bash 09-mettre-a-jour.sh` |
| **10-check-status.sh** | Dashboard complet de l'état | `bash 10-check-status.sh` |
| **10-desinstaller.sh** | Désinstaller complètement | `bash 10-desinstaller.sh` |

---

## Installation Rapide

### Méthode 1 : Automatique (Recommandée)

```bash
# 1. Vérifier les prérequis
bash 00-verifier-prerequis.sh

# 2. Tout installer automatiquement
sudo bash 00-installation-complete.sh

# 3. Tester
bash 06-tester-api.sh
```

### Méthode 2 : Pas à pas

```bash
# Étape 1 : Docker
sudo bash 01-installer-docker.sh

# Étape 2 : Utilisateur
sudo bash 02-creer-utilisateur.sh

# Étape 3 : Firewall
sudo bash 03-configurer-firewall.sh

# Étape 4 : Application (en tant que deploy)
su - deploy
bash 04-deployer-application.sh

# Étape 5 : Nginx (optionnel)
sudo bash 05-installer-nginx.sh
```

---

## Commandes Quotidiennes

```bash
# Vérifier l'état
bash 10-check-status.sh

# Voir les logs
bash 07-maintenance.sh  # Puis choisir option 2

# Sauvegarder
bash 07-sauvegarder-db.sh

# Mettre à jour
bash 09-mettre-a-jour.sh
```

---

## Documentation Complète

Voir le dossier **documentation-etudiants/** :
- 00-README.md
- 01-guide-installation.md
- 02-tutoriel-video.md
- 03-faq.md
- 04-checklist.md
- 05-aide-memoire.md
- 90-resume-enseignant.md
- 99-rapport-analyse.md

---

**Version** : 2.0 (nettoyée)  
**Dernière mise à jour** : Novembre 2025
