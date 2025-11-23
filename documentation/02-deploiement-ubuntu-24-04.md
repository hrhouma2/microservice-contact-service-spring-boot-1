# Guide Complet de Déploiement sur Ubuntu 24.04 LTS

Guide pas à pas pour déployer le Contact Service API sur une VM Ubuntu 24.04.

---

## Table des Matières

1. [Préparation de la VM](#préparation-de-la-vm)
2. [Installation de Docker et Docker Compose](#installation-de-docker-et-docker-compose)
3. [Configuration de l'utilisateur](#configuration-de-lutilisateur)
4. [Déploiement de l'application](#déploiement-de-lapplication)
5. [Configuration Nginx](#configuration-nginx)
6. [Monitoring et Logs](#monitoring-et-logs)
7. [Maintenance](#maintenance)

---

## Préparation de la VM

### Connexion initiale à la VM

```bash
# Connexion SSH à votre VM Ubuntu 24.04
ssh root@VOTRE_IP_VM

# Si vous avez déjà un utilisateur non-root fourni par l'hébergeur
ssh ubuntu@VOTRE_IP_VM
```

### Mise à jour du système

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Mettre à jour tous les paquets
sudo apt upgrade -y

# Installer les outils de base
sudo apt install -y curl wget git vim nano ufw net-tools htop

# Redémarrer si kernel mis à jour (optionnel)
# sudo reboot
```

### Vérifier la version Ubuntu

```bash
lsb_release -a

# Devrait afficher :
# Distributor ID: Ubuntu
# Description:    Ubuntu 24.04 LTS
# Release:        24.04
# Codename:       noble
```

---

## Installation de Docker et Docker Compose

### Méthode 1 : Script Automatique (Recommandé)

```bash
# Télécharger le script officiel Docker
curl -fsSL https://get.docker.com -o get-docker.sh

# Vérifier le contenu (optionnel mais recommandé)
less get-docker.sh

# Exécuter le script
sudo sh get-docker.sh

# Nettoyer
rm get-docker.sh
```

### Méthode 2 : Installation Manuelle (Ubuntu 24.04 spécifique)

```bash
# 1. Supprimer les anciennes versions (si existantes)
sudo apt remove -y docker docker-engine docker.io containerd runc

# 2. Installer les prérequis
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. Ajouter la clé GPG officielle de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Ajouter le repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Mettre à jour les paquets
sudo apt update

# 6. Installer Docker Engine, CLI et plugins
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
```

### Vérifier l'installation Docker

```bash
# Vérifier la version de Docker
docker --version
# Devrait afficher : Docker version 24.x.x, build...

# Vérifier Docker Compose
docker compose version
# Devrait afficher : Docker Compose version v2.x.x

# Vérifier que Docker tourne
sudo systemctl status docker
# Devrait afficher : active (running)
```

### Activer le démarrage automatique

```bash
# Activer Docker au démarrage de la VM
sudo systemctl enable docker

# Démarrer Docker maintenant
sudo systemctl start docker
```

### Tester Docker

```bash
# Tester avec un conteneur hello-world (en root/sudo)
sudo docker run hello-world

# Si vous voyez "Hello from Docker!" → Succès !
```

---

## Configuration de l'Utilisateur

### Étape 1 : Créer un utilisateur dédié

```bash
# Créer un utilisateur pour gérer les applications
sudo adduser deploy

# Remplir les informations demandées :
# - Mot de passe : CHOISIR UN MOT DE PASSE FORT
# - Full Name : Deploy User (ou laisser vide)
# - Autres champs : Appuyer sur Entrée
```

**Nom d'utilisateur recommandé** : `deploy`, `appuser`, `devops`

### Étape 2 : Donner les droits sudo

```bash
# Ajouter au groupe sudo
sudo usermod -aG sudo deploy

# Vérifier
groups deploy
# Devrait afficher : deploy : deploy sudo
```

### Étape 3 : Ajouter au groupe Docker

```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker deploy

# Vérifier
groups deploy
# Devrait afficher : deploy : deploy sudo docker
```

### Étape 4 : Tester avec le nouvel utilisateur

```bash
# Basculer vers l'utilisateur deploy
su - deploy

# Tester Docker SANS sudo
docker ps

# Si ça fonctionne → Parfait !
# Si "permission denied" → Se déconnecter et reconnecter
exit
```

### Étape 5 : Configurer l'accès SSH pour cet utilisateur

**Option A : Copier les clés SSH de root (si vous utilisez des clés)**

```bash
# En tant que root
sudo cp -r /root/.ssh /home/deploy/
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
```

**Option B : Ajouter votre clé SSH publique**

```bash
# Se connecter en tant que deploy
su - deploy

# Créer le dossier .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Créer le fichier authorized_keys
nano ~/.ssh/authorized_keys

# Coller votre clé publique (de votre PC local : ~/.ssh/id_ed25519.pub ou id_rsa.pub)
# Sauvegarder : Ctrl+X, Y, Entrée

# Permissions correctes
chmod 600 ~/.ssh/authorized_keys

# Quitter
exit
```

### Étape 6 : Tester la connexion SSH avec deploy

**Ouvrir un NOUVEAU terminal** (ne pas fermer l'ancien) :

```bash
# Tester la connexion
ssh deploy@VOTRE_IP_VM

# Si ça fonctionne → Vous pouvez fermer l'autre session
# Si ça ne fonctionne pas → Débugger dans la session root
```

### Étape 7 : Sécuriser SSH (optionnel mais recommandé)

```bash
# En tant que root ou avec sudo
sudo nano /etc/ssh/sshd_config

# Modifier ces lignes :
PermitRootLogin no                    # Désactiver root
PasswordAuthentication no             # Seulement clés SSH
PubkeyAuthentication yes              # Activer clés
Port 2222                            # Changer le port (optionnel)

# Sauvegarder et quitter

# Redémarrer SSH
sudo systemctl restart sshd

# ⚠️ Tester dans un nouveau terminal avant de fermer la session actuelle !
```

---

## Déploiement de l'Application

### Étape 1 : Configurer le firewall

```bash
# Se connecter en tant que deploy
ssh deploy@VOTRE_IP_VM

# Configurer UFW (firewall)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (adapter le port si modifié)
sudo ufw allow 22/tcp
# OU si vous avez changé le port :
# sudo ufw allow 2222/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer le firewall
sudo ufw enable

# Vérifier
sudo ufw status verbose
```

### Étape 2 : Créer la structure de dossiers

```bash
# Créer les dossiers nécessaires
mkdir -p ~/apps
mkdir -p ~/apps/logs
mkdir -p ~/apps/backups

# Vérifier
ls -la ~/apps
```

### Étape 3 : Cloner le projet depuis GitHub

```bash
# Aller dans le dossier apps
cd ~/apps

# Cloner votre repository
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git

# OU si repository privé (avec authentification)
# git clone https://VOTRE_TOKEN@github.com/VOTRE_USERNAME/contact-service-springboot.git

# Entrer dans le projet
cd contact-service-springboot

# Vérifier les fichiers
ls -la
```

### Étape 4 : Configurer les variables d'environnement

```bash
# Copier le fichier exemple
cp .env.example .env

# Éditer avec vos valeurs
nano .env
```

**Contenu du fichier .env** :

```env
# SMTP Configuration (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASS=xxxx xxxx xxxx xxxx

# Email de notification
CONTACT_NOTIFICATION_EMAIL=notifications@votredomaine.com

# CORS - Vos domaines en production
CORS_ALLOWED_ORIGINS=https://votresite.com,https://www.votresite.com,https://autresite.com
```

**Important** :
- Utilisez un **mot de passe d'application Gmail** (pas votre mot de passe principal)
- Générer sur : https://myaccount.google.com/apppasswords
- Pas d'espaces dans les URLs CORS

Sauvegarder : **Ctrl+X**, **Y**, **Entrée**

### Étape 5 : Lancer l'application

```bash
# Lancer avec Docker Compose
docker compose up -d

# Voir les logs en temps réel
docker compose logs -f

# Appuyer sur Ctrl+C pour arrêter de suivre les logs (les conteneurs continuent de tourner)
```

### Étape 6 : Vérifier que l'application tourne

```bash
# Voir les conteneurs actifs
docker compose ps

# Devrait afficher :
# NAME                      STATUS          PORTS
# contact-service-app       Up 2 minutes    0.0.0.0:8080->8080/tcp
# contact-service-db        Up 2 minutes    0.0.0.0:5432->5432/tcp

# Tester le health check
curl http://localhost:8080/api/health

# Si vous voyez "status":"ok" → Succès !
```

### Étape 7 : Tester l'API

```bash
# Test POST depuis la VM
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test-vm",
    "email": "test@example.com",
    "name": "Test VM",
    "message": "Test depuis la VM Ubuntu 24.04"
  }'

# Devrait retourner :
# {"ok":true,"message":"Votre message a été envoyé avec succès","submissionId":"..."}
```

### Étape 8 : Vérifier dans PostgreSQL

```bash
# Se connecter au conteneur PostgreSQL
docker exec -it contact-service-db psql -U postgres -d contact_service

# Dans psql, voir les soumissions :
SELECT * FROM form_submissions ORDER BY created_at DESC LIMIT 5;

# Quitter psql
\q
```

---

## Configuration Nginx

### Étape 1 : Installer Nginx

```bash
# Installer Nginx
sudo apt install -y nginx

# Vérifier que Nginx tourne
sudo systemctl status nginx

# Démarrer si ce n'est pas le cas
sudo systemctl start nginx

# Activer au démarrage
sudo systemctl enable nginx
```

### Étape 2 : Configurer le reverse proxy

```bash
# Créer un fichier de configuration
sudo nano /etc/nginx/sites-available/contact-api
```

**Contenu du fichier** :

```nginx
server {
    listen 80;
    server_name VOTRE_IP_VM;
    # Ou si vous avez un domaine : server_name contact-api.votredomaine.com;

    # Logs
    access_log /var/log/nginx/contact-api-access.log;
    error_log /var/log/nginx/contact-api-error.log;

    location / {
        # Proxy vers l'application Spring Boot
        proxy_pass http://localhost:8080;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint (optionnel)
    location /api/health {
        proxy_pass http://localhost:8080/api/health;
        access_log off;
    }
}
```

Sauvegarder : **Ctrl+X**, **Y**, **Entrée**

### Étape 3 : Activer le site

```bash
# Créer un lien symbolique
sudo ln -s /etc/nginx/sites-available/contact-api /etc/nginx/sites-enabled/

# Supprimer le site par défaut (optionnel)
sudo rm /etc/nginx/sites-enabled/default

# Tester la configuration
sudo nginx -t

# Devrait afficher : syntax is ok, test is successful

# Recharger Nginx
sudo systemctl reload nginx
```

### Étape 4 : Tester l'accès externe

```bash
# Depuis votre PC local (pas la VM)
curl http://VOTRE_IP_VM/api/health

# Ou dans un navigateur :
http://VOTRE_IP_VM/swagger-ui.html
```

### Étape 5 : Configurer SSL avec Certbot (si vous avez un domaine)

**Prérequis** : Avoir un nom de domaine pointant vers votre IP

```bash
# Installer Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtenir un certificat SSL automatiquement
sudo certbot --nginx -d contact-api.votredomaine.com

# Suivre les instructions :
# - Entrez votre email
# - Acceptez les termes
# - Redirection HTTP vers HTTPS : Oui (recommandé)

# Certbot modifiera automatiquement votre config Nginx
```

**Renouvellement automatique** :

```bash
# Tester le renouvellement
sudo certbot renew --dry-run

# Un cron job est automatiquement créé pour le renouvellement
```

---

## Déploiement de l'Application en Détail

### Structure complète

```bash
# Se connecter à la VM
ssh deploy@VOTRE_IP_VM

# Vérifier la structure
cd ~/apps/contact-service-springboot
tree -L 2

# Structure attendue :
# contact-service-springboot/
# ├── docker-compose.yml
# ├── Dockerfile
# ├── pom.xml
# ├── .env
# ├── docker/
# │   └── init.sql
# ├── src/
# └── ...
```

### Fichier docker-compose.yml (Vérifier)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: contact-service-db
    environment:
      POSTGRES_DB: contact_service
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  app:
    build: .
    container_name: contact-service-app
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_PORT=${SMTP_PORT}
      - SMTP_USER=${SMTP_USER}
      - SMTP_PASS=${SMTP_PASS}
      - CONTACT_NOTIFICATION_EMAIL=${CONTACT_NOTIFICATION_EMAIL}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  postgres_data:
```

### Démarrage complet

```bash
# Être dans le dossier du projet
cd ~/apps/contact-service-springboot

# Vérifier que .env existe et est rempli
cat .env

# Lancer l'application (build + start)
docker compose up -d

# Le premier lancement peut prendre 3-5 minutes (Maven build)
# Suivre les logs :
docker compose logs -f app

# Quand vous voyez "Started ContactServiceApplication" → Succès !
# Ctrl+C pour arrêter de suivre (les conteneurs continuent)
```

### Vérifications

```bash
# 1. Vérifier que les conteneurs tournent
docker compose ps

# 2. Vérifier les logs
docker compose logs app | tail -30

# 3. Vérifier PostgreSQL
docker exec -it contact-service-db psql -U postgres -c "\l"

# 4. Tester l'API localement
curl http://localhost:8080/api/health

# 5. Tester l'API via Nginx
curl http://VOTRE_IP_VM/api/health

# 6. Tester depuis votre PC
curl http://VOTRE_IP_VM/api/health
```

---

## Monitoring et Logs

### Logs en temps réel

```bash
# Logs de l'application
docker compose logs -f app

# Logs de PostgreSQL
docker compose logs -f postgres

# Tous les logs
docker compose logs -f

# Dernières 100 lignes
docker compose logs --tail=100 app
```

### Logs système

```bash
# Logs Docker système
sudo journalctl -u docker -f

# Logs Nginx
sudo tail -f /var/log/nginx/contact-api-access.log
sudo tail -f /var/log/nginx/contact-api-error.log
```

### Surveillance des ressources

```bash
# Utilisation CPU/Mémoire des conteneurs
docker stats

# Espace disque
df -h

# Mémoire système
free -h

# Processus
htop
```

---

## Maintenance

### Redémarrage de l'application

```bash
# Redémarrer tous les services
docker compose restart

# Redémarrer seulement l'app
docker compose restart app

# Redémarrer seulement PostgreSQL
docker compose restart postgres
```

### Mise à jour de l'application

```bash
# 1. Aller dans le projet
cd ~/apps/contact-service-springboot

# 2. Récupérer les dernières modifications
git pull origin main

# 3. Rebuild et redémarrer
docker compose up -d --build

# 4. Vérifier
docker compose logs -f app
```

### Sauvegarde de la base de données

```bash
# Créer une sauvegarde manuelle
docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +%Y%m%d_%H%M%S).sql

# Vérifier
ls -lh ~/apps/backups/
```

**Automatiser avec cron** :

```bash
# Éditer le crontab
crontab -e

# Ajouter (sauvegarde quotidienne à 2h du matin)
0 2 * * * docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +\%Y\%m\%d).sql

# Ajouter (nettoyer les sauvegardes de plus de 30 jours)
0 3 * * * find ~/apps/backups/ -name "db_*.sql" -mtime +30 -delete
```

### Restauration de la base de données

```bash
# Arrêter l'application
docker compose stop app

# Restaurer depuis une sauvegarde
docker exec -i contact-service-db psql -U postgres contact_service < ~/apps/backups/db_20241122.sql

# Redémarrer
docker compose start app
```

### Nettoyer Docker

```bash
# Supprimer les images inutilisées
docker image prune -a

# Supprimer tout ce qui n'est pas utilisé
docker system prune -a --volumes

# ⚠️ Attention : supprime les volumes non utilisés !
```

---

## Arrêt et Redémarrage

### Arrêter l'application

```bash
# Arrêter tous les services
docker compose down

# Arrêter ET supprimer les volumes (⚠️ perte de données)
docker compose down -v
```

### Redémarrer après arrêt

```bash
# Démarrer
docker compose up -d

# Vérifier
docker compose ps
curl http://localhost:8080/api/health
```

### Redémarrage de la VM

```bash
# Redémarrer la VM
sudo reboot

# Après redémarrage, se reconnecter
ssh deploy@VOTRE_IP_VM

# Vérifier que Docker a redémarré automatiquement
docker ps

# Si les conteneurs ne sont pas là, les relancer
cd ~/apps/contact-service-springboot
docker compose up -d
```

---

## Commandes de Dépannage

### Application ne démarre pas

```bash
# 1. Voir les logs
docker compose logs app

# 2. Vérifier que PostgreSQL est prêt
docker compose ps postgres

# 3. Redémarrer proprement
docker compose down
docker compose up -d

# 4. Reconstruire si nécessaire
docker compose up -d --build
```

### Problème de connexion PostgreSQL

```bash
# Vérifier que PostgreSQL écoute
docker compose ps postgres

# Tester la connexion
docker exec -it contact-service-db psql -U postgres -c "SELECT version();"

# Voir les logs PostgreSQL
docker compose logs postgres
```

### Erreur de permissions

```bash
# Vérifier que deploy est dans le groupe docker
groups

# Si pas de groupe docker visible
sudo usermod -aG docker deploy
newgrp docker

# OU se déconnecter et reconnecter
exit
ssh deploy@VOTRE_IP_VM
```

### Port déjà utilisé

```bash
# Vérifier qui utilise le port 8080
sudo lsof -i :8080

# OU
sudo netstat -tulpn | grep 8080

# Arrêter le service qui utilise le port
# OU changer le port dans docker-compose.yml
```

---

## Checklist de Déploiement

### Avant déploiement

- [ ] VM Ubuntu 24.04 prête
- [ ] Accès SSH configuré
- [ ] Nom d'utilisateur non-root créé
- [ ] Repository GitHub prêt
- [ ] Credentials SMTP disponibles

### Installation

- [ ] Système mis à jour (apt update && upgrade)
- [ ] Docker installé
- [ ] Docker Compose installé
- [ ] Utilisateur ajouté au groupe docker
- [ ] Firewall configuré (UFW)

### Déploiement

- [ ] Projet cloné dans ~/apps
- [ ] Fichier .env créé et rempli
- [ ] docker compose up -d exécuté
- [ ] Conteneurs démarrés correctement
- [ ] Health check OK (curl localhost:8080/api/health)

### Configuration externe

- [ ] Nginx installé et configuré
- [ ] Site activé dans sites-enabled
- [ ] Accès externe fonctionnel (curl IP_VM/api/health)
- [ ] SSL configuré (si domaine)
- [ ] DNS configuré (si domaine)

### Tests

- [ ] POST /api/contact fonctionne
- [ ] Email reçu
- [ ] Soumission visible dans PostgreSQL
- [ ] Documentation Swagger accessible

---

## Résumé des Commandes Essentielles

```bash
# Connexion
ssh deploy@VOTRE_IP_VM

# Démarrer l'application
cd ~/apps/contact-service-springboot
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down

# Mettre à jour
git pull origin main
docker compose up -d --build

# Sauvegarder la DB
docker exec contact-service-db pg_dump -U postgres contact_service > ~/apps/backups/db_$(date +%Y%m%d).sql

# Vérifier
docker compose ps
curl http://localhost:8080/api/health
```

---

## Architecture Finale sur la VM

```
Internet
    ↓
Firewall UFW (ports 80, 443, 22 ouverts)
    ↓
Nginx (reverse proxy sur port 80/443)
    ↓
Application Spring Boot (conteneur sur port 8080)
    ↓
PostgreSQL (conteneur sur port 5432)
    ↓
Volume Docker (persistence des données)
```

---

**Version** : 1.0.0
**Ubuntu** : 24.04 LTS
**Docker** : 24.x
**Docker Compose** : v2.x

Guide complet pour déploiement local sur VM Ubuntu 24.04.

