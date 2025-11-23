# Guide d'Utilisation des Scripts

Scripts prêts à l'emploi pour déployer le Contact Service API sur Ubuntu 24.04.

---

##  Guides pour Débutants

### Pour les étudiants et débutants, consultez ces guides pour l'installation :

1. ** [GUIDE-INSTALLATION-DEBUTANTS.md](GUIDE-INSTALLATION-DEBUTANTS.md)**
   - Guide complet avec explications détaillées
   - Comment obtenir un mot de passe d'application Gmail
   - Prérequis et ressources nécessaires

2. ** [TUTORIEL-VIDEO.md](TUTORIEL-VIDEO.md)**
   - Tutoriel étape par étape (format vidéo en texte)
   - Commandes à copier-coller
   - Timing précis de chaque étape (15 minutes)

3. ** [FAQ.md](FAQ.md)**
   - 28 questions fréquentes avec réponses
   - Solutions aux problèmes courants
   - Dépannage et troubleshooting

---

## Vue d'ensemble

**12 scripts** pour installer et gérer l'application sans effort.

---

## Scripts Disponibles

### Scripts d'Installation (à exécuter en tant que root/sudo)

| Script | Description | Commande |
|--------|-------------|----------|
| `00-verifier-prerequis.sh` | ⭐ Vérifie que la VM est prête | `bash 00-verifier-prerequis.sh` |
| `00-installation-complete.sh` | ⭐ Installation complète automatique (RECOMMANDÉ) | `sudo bash 00-installation-complete.sh` |
| `01-installer-docker.sh` | Installe Docker et Docker Compose | `sudo bash 01-installer-docker.sh` |
| `02-creer-utilisateur.sh` | Crée un utilisateur non-root | `sudo bash 02-creer-utilisateur.sh` |
| `03-configurer-firewall.sh` | Configure le firewall UFW | `sudo bash 03-configurer-firewall.sh` |
| `05-installer-nginx.sh` | Installe et configure Nginx | `sudo bash 05-installer-nginx.sh` |

### Scripts d'Application (à exécuter en tant qu'utilisateur normal)

| Script | Description | Commande |
|--------|-------------|----------|
| `04-deployer-application.sh` | Clone et démarre l'application | `bash 04-deployer-application.sh` |
| `06-tester-api.sh` | ⭐ Teste l'API complète | `bash 06-tester-api.sh` |
| `07-sauvegarder-db.sh` | Sauvegarde PostgreSQL | `bash 07-sauvegarder-db.sh` |
| `08-restaurer-db.sh` | Restaure une sauvegarde | `bash 08-restaurer-db.sh` |
| `09-mettre-a-jour.sh` | Met à jour l'application | `bash 09-mettre-a-jour.sh` |
| `09-view-logs.sh` | Affiche les logs | `bash 09-view-logs.sh` |
| `10-check-status.sh` | Vérifie le statut | `bash 10-check-status.sh` |
| `10-desinstaller.sh` | Désinstalle tout | `bash 10-desinstaller.sh` |

---

## ⭐ Installation Rapide pour Débutants (Méthode Automatique)

### Prérequis
- VM Ubuntu 24.04 LTS fraîche
- Accès root via SSH
- Mot de passe d'application Gmail ([Guide ici](GUIDE-INSTALLATION-DEBUTANTS.md))

### Étapes (10 minutes)

```bash
# 1. Connexion SSH
ssh root@VOTRE_IP_VM

# 2. Télécharger les scripts
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git
cd contact-service-springboot/scripts

# 3. Rendre exécutables
chmod +x *.sh

# 4. Vérifier les prérequis (RECOMMANDÉ)
bash 00-verifier-prerequis.sh

# 5. Installer TOUT automatiquement
sudo bash 00-installation-complete.sh

# 6. Tester l'API
bash 06-tester-api.sh
```

**C'est tout !** L'application est installée et prête à l'emploi.

**Besoin d'aide détaillée ?** Voir [GUIDE-INSTALLATION-DEBUTANTS.md](GUIDE-INSTALLATION-DEBUTANTS.md)

---

## Installation Pas à Pas (Méthode 2 : Étape par étape)

### Étape 1 : Installer Docker (en root)

```bash
ssh root@VOTRE_IP_VM
cd /root
wget https://github.com/VOTRE_USERNAME/contact-service-springboot/raw/main/scripts/01-install-docker.sh
chmod +x 01-install-docker.sh
sudo bash 01-install-docker.sh
```

### Étape 2 : Créer l'utilisateur

```bash
sudo bash 02-create-user.sh
# Entrez le nom (ex: deploy)
# Entrez un mot de passe
```

### Étape 3 : Configurer le firewall

```bash
sudo bash 04-setup-firewall.sh
```

### Étape 4 : Basculer vers l'utilisateur créé

```bash
su - deploy
```

### Étape 5 : Déployer l'application

```bash
bash 05-deploy-app.sh https://github.com/VOTRE_USERNAME/contact-service-springboot.git
# Suivre les instructions pour éditer .env
```

### Étape 6 : Installer Nginx (en root)

```bash
exit  # Quitter deploy
sudo bash 06-install-nginx.sh
```

---

## Utilisation Quotidienne

### Voir les logs

```bash
# En tant qu'utilisateur deploy
bash ~/scripts/09-view-logs.sh
# Choisir : 1 (app), 2 (postgres), 3 (docker), 4 (nginx)
```

### Sauvegarder la base

```bash
bash ~/scripts/07-backup-db.sh
```

### Mettre à jour l'application

```bash
bash ~/scripts/08-update-app.sh
```

### Redémarrer l'application

```bash
cd ~/apps/contact-service-springboot
docker compose restart
```

---

## Dépannage

### Script ne s'exécute pas

```bash
# Rendre exécutable
chmod +x nom-du-script.sh

# Exécuter
bash nom-du-script.sh
```

### Permission denied

```bash
# Ajouter sudo si nécessaire
sudo bash nom-du-script.sh
```

### Application ne démarre pas

```bash
cd ~/apps/contact-service-springboot
docker compose logs app
```

---

## Ordre d'Exécution Recommandé

```
1. 01-install-docker.sh       (root)
2. 02-create-user.sh           (root)
3. 04-setup-firewall.sh        (root)
4. Basculer vers deploy        (su - deploy)
5. 05-deploy-app.sh            (deploy)
6. 06-install-nginx.sh         (root)
```

**OU en un seul coup** :

```bash
sudo bash 00-install-all.sh  # Puis suivre les instructions
```

---

Version: 1.0.0
