# Guide d'Installation Docker sur VPS Ubuntu - Bonnes Pratiques

Guide complet et sécurisé pour installer Docker sur un VPS Ubuntu.

---

## Table des Matières

1. [Bonnes Pratiques de Sécurité](#bonnes-pratiques-de-sécurité)
2. [Configuration Initiale du VPS](#configuration-initiale-du-vps)
3. [Installation de Docker](#installation-de-docker)
4. [Configuration Post-Installation](#configuration-post-installation)
5. [Sécurisation](#sécurisation)
6. [Vérification](#vérification)

---

## Bonnes Pratiques de Sécurité

### ❌ À NE PAS FAIRE

```bash
# NE JAMAIS faire ceci :
# - Se connecter en root directement
# - Utiliser root pour Docker au quotidien
# - Exposer le port SSH par défaut (22)
# - Utiliser des mots de passe faibles
```

### ✅ À FAIRE

```bash
# TOUJOURS :
# - Créer un utilisateur non-root avec sudo
# - Ajouter cet utilisateur au groupe docker
# - Utiliser des clés SSH
# - Changer le port SSH par défaut
# - Configurer le firewall (UFW)
# - Mettre à jour régulièrement le système
```

---

## Configuration Initiale du VPS

### Étape 1 : Première connexion (en root)

```bash
# Connexion SSH initiale (souvent root par défaut chez les hébergeurs)
ssh root@votre-ip-vps

# OU avec un autre utilisateur si déjà fourni
ssh utilisateur@votre-ip-vps
```

### Étape 2 : Mise à jour du système

```bash
# Mettre à jour la liste des paquets
apt update

# Mettre à jour tous les paquets installés
apt upgrade -y

# Installer les paquets essentiels
apt install -y curl git wget vim ufw
```

### Étape 3 : Créer un utilisateur non-root

```bash
# Créer un nouvel utilisateur (exemple: deploy)
adduser deploy

# Vous serez invité à entrer :
# - Un mot de passe (fort et unique)
# - Nom complet (optionnel)
# - Autres informations (optionnel, appuyez sur Entrée)
```

**Choix du nom d'utilisateur** :
- `deploy` (pour déploiement)
- `admin` (pour administration)
- `appuser` (pour l'application)
- Votre nom/prénom
- **Évitez** : `root`, `admin`, `test`, `user` (trop communs, cibles des bots)

### Étape 4 : Donner les droits sudo

```bash
# Ajouter l'utilisateur au groupe sudo
usermod -aG sudo deploy

# Vérifier que l'utilisateur est bien dans le groupe
groups deploy

# Devrait afficher : deploy : deploy sudo
```

### Étape 5 : Configurer l'accès SSH avec clés (RECOMMANDÉ)

**Sur votre machine locale** :

```bash
# Générer une paire de clés SSH (si vous n'en avez pas déjà)
ssh-keygen -t ed25519 -C "votre-email@example.com"

# Appuyez sur Entrée pour l'emplacement par défaut (~/.ssh/id_ed25519)
# Entrez un mot de passe (optionnel mais recommandé)

# Copier la clé publique vers le VPS
ssh-copy-id deploy@votre-ip-vps

# Entrez le mot de passe de l'utilisateur deploy
```

**Sur le VPS (si ssh-copy-id ne fonctionne pas)** :

```bash
# Se connecter en tant que deploy
su - deploy

# Créer le dossier .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Créer le fichier authorized_keys
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Coller votre clé publique
nano ~/.ssh/authorized_keys
# Coller le contenu de votre fichier ~/.ssh/id_ed25519.pub (de votre machine locale)
# Ctrl+X, Y, Entrée pour sauvegarder

# Quitter la session deploy
exit
```

### Étape 6 : Sécuriser SSH

```bash
# Éditer la configuration SSH
nano /etc/ssh/sshd_config

# Modifier ces lignes :
```

```properties
# Désactiver la connexion root
PermitRootLogin no

# Autoriser uniquement l'authentification par clé
PasswordAuthentication no

# Changer le port SSH (optionnel mais recommandé)
Port 2222

# Autoriser uniquement votre utilisateur
AllowUsers deploy

# Autres paramètres de sécurité
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
```

```bash
# Redémarrer le service SSH
systemctl restart sshd

# ⚠️ NE PAS fermer votre session actuelle avant de tester !
```

### Étape 7 : Tester la connexion SSH

**Dans un NOUVEAU terminal (sans fermer l'ancien)** :

```bash
# Tester la connexion avec le nouvel utilisateur
# Si vous avez changé le port :
ssh -p 2222 deploy@votre-ip-vps

# Si le port est resté 22 :
ssh deploy@votre-ip-vps

# ✅ Si ça fonctionne : vous pouvez fermer l'ancienne session
# ❌ Si ça ne fonctionne pas : corrigez dans l'ancienne session
```

### Étape 8 : Configurer le firewall (UFW)

```bash
# Se connecter en tant que deploy (avec sudo)
ssh -p 2222 deploy@votre-ip-vps

# Configurer le firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (adapter le port si modifié)
sudo ufw allow 2222/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer le firewall
sudo ufw enable

# Vérifier le statut
sudo ufw status
```

**Résultat attendu** :

```
Status: active

To                         Action      From
--                         ------      ----
2222/tcp                   ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

---

## Installation de Docker

### Méthode 1 : Script officiel Docker (Recommandé)

```bash
# Se connecter avec votre utilisateur non-root
ssh -p 2222 deploy@votre-ip-vps

# Télécharger et exécuter le script d'installation officiel
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Nettoyer
rm get-docker.sh
```

### Méthode 2 : Installation manuelle (Ubuntu/Debian)

```bash
# Mettre à jour les paquets
sudo apt update

# Installer les prérequis
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Ajouter la clé GPG officielle de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter le dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mettre à jour les paquets
sudo apt update

# Installer Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## Configuration Post-Installation

### Étape 1 : Ajouter l'utilisateur au groupe Docker

```bash
# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Appliquer les changements de groupe (sans se déconnecter)
newgrp docker

# OU se déconnecter et se reconnecter
exit
ssh -p 2222 deploy@votre-ip-vps
```

### Étape 2 : Vérifier que Docker fonctionne sans sudo

```bash
# Tester Docker (SANS sudo)
docker run hello-world

# Si ça fonctionne, vous devriez voir :
# "Hello from Docker!"
```

### Étape 3 : Installer Docker Compose V2 (normalement déjà installé)

```bash
# Vérifier la version
docker compose version

# Si pas installé, installer manuellement
sudo apt install docker-compose-plugin
```

### Étape 4 : Configuration de Docker (optionnel mais recommandé)

```bash
# Créer le fichier de configuration
sudo nano /etc/docker/daemon.json
```

Ajouter :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "userland-proxy": false
}
```

```bash
# Redémarrer Docker
sudo systemctl restart docker
```

**Explication** :
- `log-driver` : Limite la taille des logs Docker
- `max-size` : Taille max par fichier de log (10 MB)
- `max-file` : Nombre de fichiers de log à conserver (3)
- `storage-driver` : Driver de stockage recommandé
- `userland-proxy` : Désactiver pour de meilleures performances

---

## Sécurisation

### 1. Activer le démarrage automatique de Docker

```bash
# Activer Docker au démarrage
sudo systemctl enable docker

# Vérifier le statut
sudo systemctl status docker
```

### 2. Limiter les ressources Docker (optionnel)

```bash
# Créer un fichier de configuration pour limiter les ressources
sudo nano /etc/docker/daemon.json
```

Ajouter les limites :

```json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
```

### 3. Sécuriser le socket Docker

```bash
# Par défaut, seuls root et les membres du groupe docker peuvent accéder au socket
ls -l /var/run/docker.sock

# Devrait afficher :
# srw-rw---- 1 root docker 0 Nov 22 19:00 /var/run/docker.sock
```

### 4. Configurer fail2ban pour Docker (optionnel)

```bash
# Installer fail2ban
sudo apt install -y fail2ban

# Créer une jail Docker
sudo nano /etc/fail2ban/jail.d/docker.conf
```

```ini
[docker-ssh]
enabled = true
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

```bash
# Redémarrer fail2ban
sudo systemctl restart fail2ban
```

---

## Vérification

### Checklist complète

```bash
# 1. Vérifier que Docker fonctionne
docker --version
docker compose version

# 2. Tester Docker sans sudo
docker ps

# 3. Vérifier que l'utilisateur est dans le bon groupe
groups

# Devrait afficher : deploy sudo docker

# 4. Tester avec un conteneur
docker run --rm hello-world

# 5. Vérifier le démarrage automatique
sudo systemctl is-enabled docker

# 6. Vérifier le firewall
sudo ufw status

# 7. Vérifier l'espace disque
df -h

# 8. Vérifier les logs Docker
sudo journalctl -u docker --no-pager | tail -20
```

### Test complet avec PostgreSQL

```bash
# Lancer un conteneur PostgreSQL
docker run -d \
  --name test-postgres \
  -e POSTGRES_PASSWORD=test123 \
  -p 5432:5432 \
  postgres:15-alpine

# Vérifier qu'il tourne
docker ps

# Voir les logs
docker logs test-postgres

# Se connecter au conteneur
docker exec -it test-postgres psql -U postgres

# Dans psql :
\l
\q

# Arrêter et supprimer
docker stop test-postgres
docker rm test-postgres
```

---

## Structure Recommandée pour les Applications

### Organisation des fichiers

```bash
# Créer une structure propre
cd ~
mkdir -p apps/contact-service
mkdir -p apps/logs
mkdir -p apps/backups

# Structure :
# ~/apps/
#   ├── contact-service/       # Votre application
#   │   ├── .env
#   │   ├── docker-compose.yml
#   │   └── ...
#   ├── logs/                  # Logs centralisés
#   └── backups/               # Sauvegardes
```

### Permissions

```bash
# S'assurer que l'utilisateur possède les dossiers
sudo chown -R $USER:$USER ~/apps

# Vérifier
ls -la ~/apps
```

---

## Déploiement de l'Application

### Étape 1 : Cloner le projet

```bash
# Se connecter au VPS
ssh -p 2222 deploy@votre-ip-vps

# Aller dans le dossier apps
cd ~/apps

# Cloner votre projet
git clone https://github.com/username/contact-service-springboot.git
cd contact-service-springboot
```

### Étape 2 : Configurer les variables

```bash
# Créer le fichier .env
nano .env
```

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
CONTACT_NOTIFICATION_EMAIL=notifications@yourdomain.com
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

### Étape 3 : Lancer l'application

```bash
# Lancer avec Docker Compose
docker compose up -d

# Vérifier les logs
docker compose logs -f

# Vérifier que ça tourne
docker compose ps

# Tester l'API
curl http://localhost:8080/api/health
```

### Étape 4 : Autoriser le port dans le firewall

```bash
# Autoriser le port 8080 (temporaire pour test)
sudo ufw allow 8080/tcp

# Tester depuis l'extérieur
curl http://votre-ip-vps:8080/api/health

# Une fois Nginx configuré, fermer le port 8080
sudo ufw delete allow 8080/tcp
```

---

## Maintenance

### Mises à jour

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Mettre à jour Docker
sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io

# Nettoyer Docker
docker system prune -a --volumes
```

### Logs

```bash
# Voir les logs de l'application
docker compose logs -f app

# Voir les logs de PostgreSQL
docker compose logs -f postgres

# Voir les logs système Docker
sudo journalctl -u docker -f
```

### Sauvegardes

```bash
# Sauvegarder la base de données
docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +%Y%m%d).sql

# Automatiser avec cron
crontab -e

# Ajouter (sauvegarde quotidienne à 2h du matin)
0 2 * * * docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +\%Y\%m\%d).sql
```

---

## Résumé des Bonnes Pratiques

### ✅ Sécurité

- [ ] Utiliser un utilisateur non-root
- [ ] Désactiver la connexion root SSH
- [ ] Utiliser des clés SSH
- [ ] Changer le port SSH par défaut
- [ ] Configurer le firewall (UFW)
- [ ] Limiter les logs Docker
- [ ] Mettre à jour régulièrement

### ✅ Organisation

- [ ] Structure de dossiers claire
- [ ] Fichier .env pour les secrets
- [ ] Sauvegardes automatisées
- [ ] Logs centralisés

### ✅ Docker

- [ ] Utilisateur dans le groupe docker
- [ ] Docker Compose pour l'orchestration
- [ ] Limites de ressources configurées
- [ ] Redémarrage automatique des conteneurs

### ✅ Monitoring

- [ ] Vérifier les logs régulièrement
- [ ] Surveiller l'espace disque
- [ ] Monitoring des conteneurs
- [ ] Alertes en cas de problème

---

## Commandes de Référence Rapide

```bash
# Connexion SSH
ssh -p 2222 deploy@votre-ip-vps

# Démarrer l'application
cd ~/apps/contact-service-springboot
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter l'application
docker compose down

# Rebuild après modifications
docker compose up -d --build

# Nettoyer Docker
docker system prune -a

# Vérifier le firewall
sudo ufw status

# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Redémarrer Docker
sudo systemctl restart docker
```

---

## Dépannage

### Docker ne démarre pas

```bash
# Vérifier le statut
sudo systemctl status docker

# Voir les logs
sudo journalctl -u docker --no-pager | tail -50

# Redémarrer
sudo systemctl restart docker
```

### Permission denied sur docker.sock

```bash
# Vérifier les permissions
ls -l /var/run/docker.sock

# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Ou se déconnecter/reconnecter
```

### Espace disque plein

```bash
# Vérifier l'espace
df -h

# Nettoyer Docker
docker system prune -a --volumes

# Nettoyer les logs
sudo journalctl --vacuum-time=7d
```

---

**Résumé** : TOUJOURS utiliser un utilisateur non-root avec sudo et droits Docker, JAMAIS root directement !

**Utilisateur recommandé** : `deploy` (ou `appuser`, `admin`, etc.)

**Version** : 1.0.0
**Dernière mise à jour** : 2024-11-22

