# Guide de Depannage - Problemes Courants

## Table des Matieres

1. [Problemes Docker et Docker Compose](#1-problemes-docker-et-docker-compose)
2. [Problemes PostgreSQL](#2-problemes-postgresql)
3. [Problemes de Variables d'Environnement](#3-problemes-de-variables-denvironnement)
4. [Problemes d'Acces et Reseau](#4-problemes-dacces-et-reseau)
5. [Problemes Swagger UI](#5-problemes-swagger-ui)
6. [Problemes de Compilation et Demarrage](#6-problemes-de-compilation-et-demarrage)
7. [Problemes de Donnees](#7-problemes-de-donnees)
8. [Commandes de Diagnostic](#8-commandes-de-diagnostic)

---

## 1. Problemes Docker et Docker Compose

### Probleme 1.1 : Variables d'environnement non definies

**Symptomes** :
```
WARN[0000] The "SMTP_USER" variable is not set. Defaulting to a blank string.
WARN[0000] The "SMTP_PASS" variable is not set. Defaulting to a blank string.
WARN[0000] The "CONTACT_NOTIFICATION_EMAIL" variable is not set. Defaulting to a blank string.
```

**Cause** : Le fichier `.env` n'existe pas ou est mal configure.

**Solution** :

```bash
# Aller dans le dossier de l'application
cd /home/eleve/Bureau/microservice-contact-service-spring-boot-1
# Ou si deploye avec le script :
cd /home/deploy/apps/microservice-contact-service-spring-boot-2

# Verifier si le fichier .env existe
ls -la .env

# Si le fichier n'existe pas, le creer
nano .env
```

Contenu du fichier `.env` :
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASS=votre-mot-de-passe-application-16-caracteres
CONTACT_NOTIFICATION_EMAIL=votre-email@gmail.com
CORS_ALLOWED_ORIGINS=*
```

Sauvegarder : `Ctrl+X`, `Y`, `Entree`

Redemarrer l'application :
```bash
docker compose down
docker compose up -d
```

---

### Probleme 1.2 : "version is obsolete"

**Symptome** :
```
WARN[0000] /path/docker-compose.yml: the attribute `version` is obsolete
```

**Cause** : Docker Compose v2 n'utilise plus l'attribut `version`.

**Solution** : Ce n'est qu'un avertissement, pas une erreur. L'application fonctionne normalement.

Pour supprimer l'avertissement (optionnel) :
```bash
nano docker-compose.yml

# Supprimer ou commenter la premiere ligne :
# version: '3.8'
```

---

### Probleme 1.3 : Conteneurs ne demarrent pas

**Symptomes** :
```bash
docker compose ps
# Montre des conteneurs "Exited" ou absents
```

**Diagnostic** :
```bash
# Voir les logs
docker compose logs

# Logs specifiques
docker compose logs app
docker compose logs postgres
```

**Solutions** :

#### Solution A : Redemarrage complet
```bash
docker compose down
docker compose up -d
```

#### Solution B : Rebuild si code modifie
```bash
docker compose down
docker compose up -d --build
```

#### Solution C : Nettoyer tout
```bash
# ATTENTION : Supprime les donnees !
docker compose down -v
docker compose up -d
```

---

## 2. Problemes PostgreSQL

### Probleme 2.1 : "role root does not exist"

**Symptome** :
```
psql: error: FATAL: role "root" does not exist
```

**Cause** : Vous avez tape `psql` sans specifier l'utilisateur.

**Solution** :

```bash
# MAUVAIS (ce qui cause l'erreur)
docker exec -it contact-service-db bash
psql

# CORRECT (specifier l'utilisateur)
docker exec -it contact-service-db bash
psql -U postgres -d contact_service

# Ou directement (RECOMMANDE)
docker exec -it contact-service-db psql -U postgres -d contact_service
```

---

### Probleme 2.2 : Erreur SQL "syntax error at or near SELECT"

**Symptome** :
```sql
contact_service=# SELECT * FROM contact_submissions
contact_service-# SELECT * FROM contact_submissions
ERROR:  syntax error at or near "SELECT"
```

**Cause** : Vous avez oublie le point-virgule (`;`) a la fin de la premiere requete.

**Explication** :
- `contact_service=#` → Pret a recevoir une commande
- `contact_service-#` → Attend la fin de la commande (point-virgule manquant)

**Solution** :

```sql
-- Si vous etes bloque avec contact_service-#
-- Tapez simplement un point-virgule pour terminer :
;

-- Puis retapez la requete CORRECTEMENT :
SELECT * FROM contact_submissions 
WHERE email = 'test@example.com' 
ORDER BY date_soumission DESC 
LIMIT 1;

-- IMPORTANT : Le ; a la fin est OBLIGATOIRE !
```

**Regles PostgreSQL** :
- ✅ **Toujours terminer une requete par `;`**
- ✅ Les requetes peuvent s'etendre sur plusieurs lignes
- ✅ psql n'execute rien tant qu'il ne voit pas le `;`

**Exemples CORRECTS** :

```sql
-- Une seule ligne
SELECT * FROM contact_submissions;

-- Plusieurs lignes (plus lisible)
SELECT * FROM contact_submissions 
WHERE email = 'test@example.com';

-- Requete complexe
SELECT 
    id,
    nom,
    email,
    date_soumission
FROM contact_submissions 
WHERE statut = 'NOUVEAU'
ORDER BY date_soumission DESC
LIMIT 10;
```

---

### Probleme 2.3 : "database does not exist"

**Symptome** :
```
FATAL: database "xxx" does not exist
```

**Solution** :

```bash
# Lister les bases disponibles
docker exec -it contact-service-db psql -U postgres -l

# Se connecter a la bonne base
docker exec -it contact-service-db psql -U postgres -d contact_service
```

---

### Probleme 2.4 : Table vide apres insertion

**Symptomes** :
- Vous avez envoye des messages via Swagger
- `SELECT COUNT(*) FROM contact_submissions;` retourne `0`
- La table existe mais est vide

**Diagnostic** :

```sql
-- Verifier que la table existe
\dt

-- Compter les lignes
SELECT COUNT(*) FROM contact_submissions;

-- Voir toutes les lignes
SELECT * FROM contact_submissions;
```

**Causes possibles** :

#### Cause A : Erreur lors de l'insertion

**Verification** :
```bash
# Voir les logs de l'application
docker compose logs app | tail -50

# Chercher des erreurs
docker compose logs app | grep -i error
```

#### Cause B : Mauvaise base de donnees

**Verification** :
```sql
-- Verifier dans quelle base vous etes
SELECT current_database();

-- Doit retourner : contact_service
```

#### Cause C : Donnees inserees puis perdues (redemarrage)

Si les donnees apparaissent puis disparaissent apres redemarrage :

**Verification** :
```bash
# Verifier que le volume PostgreSQL existe
docker volume ls | grep postgres

# Voir les details du volume
docker volume inspect microservice-contact-service-spring-boot-1_postgres_data
```

**Solution** : Reinserer les donnees via l'API

```bash
# Envoyer un message de test
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test-verification",
    "email": "test@example.com",
    "name": "Test User",
    "message": "Message de test pour verification"
  }'

# Verifier immediatement dans PostgreSQL
docker exec -it contact-service-db psql -U postgres -d contact_service -c \
  "SELECT COUNT(*) FROM contact_submissions;"
```

---

### Probleme 2.5 : "too many connections"

**Symptome** :
```
FATAL: too many connections
```

**Solution** :

```bash
# Voir les connexions actives
docker exec -it contact-service-db psql -U postgres -d contact_service -c \
  "SELECT COUNT(*) FROM pg_stat_activity;"

# Tuer les connexions inactives
docker exec -it contact-service-db psql -U postgres -d contact_service -c "
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'contact_service' 
  AND pid <> pg_backend_pid() 
  AND state = 'idle';"

# Redemarrer PostgreSQL
docker compose restart postgres
```

---

## 3. Problemes de Variables d'Environnement

### Probleme 3.1 : Fichier .env non pris en compte

**Symptomes** :
- Le fichier `.env` existe
- Les warnings persistent

**Verification** :
```bash
# Verifier que le fichier .env est au bon endroit
ls -la .env

# Voir le contenu
cat .env

# Verifier les permissions
ls -l .env
```

**Solutions** :

#### Solution A : Fichier .env mal place
```bash
# Le fichier .env doit etre dans le MEME dossier que docker-compose.yml
ls -la
# Doit montrer :
# - docker-compose.yml
# - .env
# - Dockerfile
# - src/
```

#### Solution B : Format incorrect
```bash
# Le fichier .env ne doit PAS avoir :
# - D'espaces autour du =
# - De guillemets autour des valeurs (sauf si necessaire)

# CORRECT
SMTP_USER=test@gmail.com
CORS_ALLOWED_ORIGINS=*

# INCORRECT
SMTP_USER = test@gmail.com
CORS_ALLOWED_ORIGINS = "*"
```

#### Solution C : Redemarrage necessaire
```bash
# Apres modification du .env, TOUJOURS redemarrer
docker compose down
docker compose up -d
```

---

## 4. Problemes d'Acces et Reseau

### Probleme 4.1 : "Connection refused" depuis un autre PC

**Symptomes** :
- L'API fonctionne sur la VM (`curl http://localhost:8080/api/health` OK)
- Impossible d'acceder depuis Windows (`http://192.168.x.x:8080`)

**Diagnostic** :
```bash
# Sur la VM, verifier l'IP
hostname -I

# Verifier que le port 8080 est ouvert
docker compose ps

# Verifier le pare-feu
sudo ufw status
```

**Solutions** :

#### Solution A : Ouvrir le pare-feu
```bash
# Autoriser le port 8080
sudo ufw allow 8080/tcp

# Recharger
sudo ufw reload

# Verifier
sudo ufw status
```

#### Solution B : Verifier le mode reseau VirtualBox

Si vous utilisez VirtualBox :

1. Ouvrir VirtualBox
2. Clic droit sur votre VM → **Configuration**
3. **Reseau** → **Adaptateur 1**
4. **Mode d'acces reseau** : Choisir **"Acces par pont" (Bridged)**
5. Redemarrer la VM

#### Solution C : Tester avec curl
```bash
# Sur la VM
curl http://localhost:8080/api/health

# Depuis Windows (PowerShell)
Invoke-WebRequest -Uri "http://IP-DE-LA-VM:8080/api/health"
```

---

### Probleme 4.2 : Erreur CORS dans le navigateur

**Symptome** :
```
Access to fetch at 'http://192.168.x.x:8080/api/contact' from origin 'http://localhost:3000' 
has been blocked by CORS policy
```

**Solution** :

```bash
# Editer le .env
nano .env

# Modifier/Ajouter
CORS_ALLOWED_ORIGINS=*

# Sauvegarder et redemarrer
docker compose restart
```

---

## 5. Problemes Swagger UI

### Probleme 5.1 : Swagger UI ne s'affiche pas (404)

**Symptomes** :
- `http://localhost:8080/swagger-ui.html` → 404 Not Found

**Solutions** :

#### Solution A : Essayer les URLs alternatives
```bash
# URL alternative 1
http://localhost:8080/swagger-ui/index.html

# URL alternative 2
http://localhost:8080/swagger-ui.html

# Verifier l'API Docs
curl http://localhost:8080/v3/api-docs
```

#### Solution B : Verifier que l'application tourne
```bash
# Verifier les conteneurs
docker compose ps

# Voir les logs
docker compose logs app | grep -i swagger

# Redemarrer
docker compose restart app
```

---

### Probleme 5.2 : Swagger UI affiche une page blanche

**Cause** : Probleme de chargement JavaScript

**Solutions** :

```bash
# Vider le cache du navigateur
# Ctrl+Shift+R (Firefox/Chrome)

# Essayer en navigation privee

# Verifier les logs du navigateur
# F12 → Console → Chercher les erreurs
```

---

## 6. Problemes de Compilation et Demarrage

### Probleme 6.1 : Erreur "package does not exist"

**Symptome** :
```
error: package org.thymeleaf.context does not exist
```

**Cause** : Import inutilise ou dependance manquante

**Solution** : Verifier que le code est a jour

```bash
# Sur votre PC Windows, verifier que vous avez pousse le code
cd c:\00-projetsGA\contact-service-springboot
git status
git push origin main

# Sur la VM, re-cloner ou pull
cd /home/deploy/apps
sudo rm -rf microservice-contact-service-spring-boot-2
sudo -u deploy git clone https://github.com/USERNAME/REPO.git
cd microservice-contact-service-spring-boot-2
sudo -u deploy docker compose up -d --build
```

---

### Probleme 6.2 : Application demarre mais ne repond pas

**Symptomes** :
- `docker compose ps` montre le conteneur "Up"
- `curl http://localhost:8080/api/health` ne repond pas

**Diagnostic** :
```bash
# Voir les logs en temps reel
docker compose logs -f app

# Chercher des erreurs
docker compose logs app | grep -i error
docker compose logs app | grep -i exception
```

**Solutions courantes** :

#### A : PostgreSQL non accessible
```bash
# Verifier PostgreSQL
docker compose ps postgres

# Si down, redemarrer
docker compose restart postgres

# Attendre 30 secondes
sleep 30

# Redemarrer l'app
docker compose restart app
```

#### B : Port 8080 deja utilise
```bash
# Verifier si le port est utilise
sudo netstat -tulpn | grep 8080

# Ou
sudo lsof -i :8080

# Tuer le processus si necessaire
sudo kill -9 PID
```

---

## 7. Problemes de Donnees

### Probleme 7.1 : Messages envoyes mais non recus dans PostgreSQL

**Diagnostic complet** :

```bash
# 1. Verifier que l'API recoit bien la requete
docker compose logs app | tail -20

# 2. Chercher des erreurs
docker compose logs app | grep -i error

# 3. Verifier PostgreSQL
docker exec -it contact-service-db psql -U postgres -d contact_service

# Dans psql :
SELECT COUNT(*) FROM contact_submissions;
SELECT * FROM contact_submissions ORDER BY date_soumission DESC LIMIT 5;
\q
```

**Solution** : Tester manuellement

```bash
# Envoyer un message simple
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test-debug",
    "email": "debug@example.com",
    "name": "Debug Test",
    "message": "Test de debogage"
  }'

# Verifier immediatement
docker exec -it contact-service-db psql -U postgres -d contact_service -c \
  "SELECT * FROM contact_submissions WHERE email = 'debug@example.com';"
```

---

### Probleme 7.2 : Donnees perdues apres redemarrage

**Cause** : Volume Docker supprime ou non monte

**Verification** :
```bash
# Verifier les volumes
docker volume ls | grep postgres

# Voir les details
docker volume inspect VOLUME_NAME
```

**Solution** :
```bash
# Si le volume n'existe pas, il sera recree au prochain demarrage
# Mais les donnees seront perdues

# Pour eviter ca a l'avenir, NE PAS faire :
docker compose down -v  # Le -v supprime les volumes !

# Faire plutot :
docker compose down  # Sans -v
docker compose up -d
```

---

## 8. Commandes de Diagnostic

### Script de Diagnostic Complet

```bash
#!/bin/bash
echo "=== Diagnostic Contact Service ==="
echo ""

echo "1. Status Docker Compose"
docker compose ps
echo ""

echo "2. Logs recents de l'application"
docker compose logs --tail=20 app
echo ""

echo "3. Logs recents PostgreSQL"
docker compose logs --tail=10 postgres
echo ""

echo "4. Test Health Check"
curl -s http://localhost:8080/api/health | jq .
echo ""

echo "5. Nombre de messages dans PostgreSQL"
docker exec -it contact-service-db psql -U postgres -d contact_service -c \
  "SELECT COUNT(*) as total_messages FROM contact_submissions;"
echo ""

echo "6. Dernieres soumissions"
docker exec -it contact-service-db psql -U postgres -d contact_service -c \
  "SELECT id, nom, email, date_soumission FROM contact_submissions ORDER BY date_soumission DESC LIMIT 5;"
echo ""

echo "7. Utilisation ressources"
docker stats --no-stream
echo ""

echo "=== Fin du diagnostic ==="
```

Sauvegarder dans `diagnostic.sh` et executer :
```bash
chmod +x diagnostic.sh
./diagnostic.sh
```

---

### Commandes Rapides de Depannage

```bash
# Redemarrage complet
docker compose down && docker compose up -d && sleep 30 && curl http://localhost:8080/api/health

# Voir tous les logs
docker compose logs

# Logs en temps reel
docker compose logs -f

# Nettoyer et redemarrer (ATTENTION : perte de donnees)
docker compose down -v && docker compose up -d

# Rebuild complet
docker compose down && docker compose build --no-cache && docker compose up -d

# Verifier la configuration
docker compose config

# Verifier les variables d'environnement
docker compose exec app env | grep -E "SMTP|CORS"
```

---

## 9. Checklist de Depannage

Utilisez cette checklist quand quelque chose ne fonctionne pas :

### Etape 1 : Verifications de Base

- [ ] Docker est installe : `docker --version`
- [ ] Docker Compose est installe : `docker compose version`
- [ ] Les conteneurs tournent : `docker compose ps`
- [ ] Le fichier `.env` existe : `ls -la .env`
- [ ] Le fichier `.env` est correct : `cat .env`

### Etape 2 : Verifications Reseau

- [ ] Port 8080 accessible localement : `curl http://localhost:8080/api/health`
- [ ] Port ouvert dans le pare-feu : `sudo ufw status`
- [ ] IP de la VM correcte : `hostname -I`
- [ ] Acces depuis un autre PC fonctionne

### Etape 3 : Verifications PostgreSQL

- [ ] PostgreSQL tourne : `docker compose ps postgres`
- [ ] Connexion possible : `docker exec -it contact-service-db psql -U postgres -d contact_service`
- [ ] Table existe : `\dt` dans psql
- [ ] Table contient des donnees : `SELECT COUNT(*) FROM contact_submissions;`

### Etape 4 : Verifications Application

- [ ] Application demarre sans erreur : `docker compose logs app | grep -i error`
- [ ] Swagger accessible : `http://localhost:8080/swagger-ui.html`
- [ ] API repond : `curl http://localhost:8080/api/health`
- [ ] Insertion fonctionne : Test POST via Swagger

### Etape 5 : Si Tout Echoue

```bash
# Tout nettoyer et recommencer
docker compose down -v
docker system prune -a
git pull origin main
docker compose up -d --build
sleep 60
curl http://localhost:8080/api/health
```

---

## 10. Aide Supplementaire

### Ou Trouver de l'Aide ?

1. **Consulter les autres guides** :
   - `08-base-de-donnees.md` pour PostgreSQL
   - `07-tests-et-cors.md` pour les tests et CORS
   - `09-guide-swagger.md` pour Swagger UI

2. **Voir les logs** :
   ```bash
   docker compose logs -f
   ```

3. **Tester etape par etape** :
   - Suivre le guide `09-guide-swagger.md`

4. **Demander au formateur** avec ces informations :
   ```bash
   # Collecter les informations
   docker compose ps > status.txt
   docker compose logs app > logs_app.txt
   docker compose logs postgres > logs_postgres.txt
   cat .env > env.txt
   ```

---

## Recapitulatif des Erreurs Frequentes

| Erreur | Cause | Solution Rapide |
|--------|-------|-----------------|
| `role "root" does not exist` | Connexion psql sans `-U postgres` | `psql -U postgres -d contact_service` |
| `syntax error at or near SELECT` | Point-virgule manquant | Ajouter `;` a la fin |
| `SMTP_USER variable is not set` | Fichier `.env` manquant | Creer `.env` avec les variables |
| `Connection refused` | Pare-feu ou reseau | `sudo ufw allow 8080/tcp` |
| `CORS policy` | CORS mal configure | `CORS_ALLOWED_ORIGINS=*` dans `.env` |
| `404 Not Found` Swagger | URL incorrecte | Essayer `/swagger-ui/index.html` |
| Table vide | Donnees non inserees | Retester avec Swagger |
| Conteneur Exit | Erreur au demarrage | `docker compose logs app` |

---

Bon debogage !

