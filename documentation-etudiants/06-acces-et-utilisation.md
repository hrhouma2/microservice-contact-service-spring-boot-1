# Guide d'Acces et d'Utilisation de l'Application

## Table des Matieres

1. [Installation de Nginx](#1-installation-de-nginx)
2. [Comment Acceder a l'API](#2-comment-acceder-a-lapi)
3. [URLs Disponibles](#3-urls-disponibles)
4. [Tests de l'API](#4-tests-de-lapi)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Installation de Nginx

### Pourquoi Nginx ?

Nginx agit comme un **reverse proxy** et vous permet :
- D'acceder via le port 80 (HTTP standard, sans `:8080`)
- D'ajouter un nom de domaine
- D'ajouter HTTPS plus tard
- De meilleures performances et securite

### Qui peut installer Nginx ?

**IMPORTANT** : Nginx necessite des privileges `root` ou `sudo` car il doit :
- Installer des packages systeme
- Modifier la configuration dans `/etc/nginx/`
- Ouvrir les ports 80 et 443 (ports privilegies < 1024)

### Installation

```bash
# Option 1 : En tant qu'utilisateur normal avec sudo
sudo bash /home/deploy/05-installer-nginx.sh

# Option 2 : Si vous etes deja root
bash /home/deploy/05-installer-nginx.sh
```

### Questions Posees par le Script

Le script vous demandera :

1. **Nom de domaine** :
   - Pour un test local : `localhost`
   - Pour un vrai domaine : `api.mondomaine.com`

2. **Configuration HTTPS** :
   - Pour l'instant, repondez `n` (non)
   - Vous pourrez l'activer plus tard avec Let's Encrypt

---

## 2. Comment Acceder a l'API

### A. Acces LOCAL (depuis la VM Ubuntu Desktop)

Si vous etes directement sur la VM avec une interface graphique :

```bash
# Ouvrir Swagger dans Firefox
firefox http://localhost:8080/swagger-ui.html

# Ou le endpoint health
firefox http://localhost:8080/api/health

# Ou l'API complete
firefox http://localhost:8080
```

#### Apres Installation de Nginx

```bash
# Plus besoin du :8080
firefox http://localhost/swagger-ui.html
firefox http://localhost/api/health
```

---

### B. Acces DEPUIS UN AUTRE PC (Windows, Mac, etc.)

Pour acceder depuis votre PC principal, vous devez connaitre **l'adresse IP de la VM**.

#### Etape 1 : Trouver l'IP de la VM

Sur la VM, executez :

```bash
# Methode 1 : Simple
hostname -I

# Methode 2 : Detaillee
ip addr show | grep inet

# Methode 3 : Avec ifconfig (si disponible)
ifconfig
```

Vous obtiendrez une IP comme :
- `192.168.1.50`
- `192.168.56.101`
- `10.0.2.15`

#### Etape 2 : Acceder depuis votre PC

Ouvrez un navigateur (Chrome, Firefox, Edge) sur votre PC et allez a :

**SANS Nginx (avec port 8080)** :
```
http://192.168.1.50:8080/swagger-ui.html
http://192.168.1.50:8080/api/health
http://192.168.1.50:8080/api/contact
```

**AVEC Nginx (port 80)** :
```
http://192.168.1.50/swagger-ui.html
http://192.168.1.50/api/health
http://192.168.1.50/api/contact
```

**IMPORTANT** : Remplacez `192.168.1.50` par l'IP reelle de votre VM !

---

### C. Acces via Nom de Domaine (Avance)

Si vous avez configure un nom de domaine (ex: `api.mondomaine.com`) :

```
http://api.mondomaine.com/swagger-ui.html
http://api.mondomaine.com/api/health
http://api.mondomaine.com/api/contact
```

---

## 3. URLs Disponibles

### Tableau Complet des Endpoints

| Endpoint | Description | URL (sans Nginx) | URL (avec Nginx) |
|----------|-------------|------------------|------------------|
| **Swagger UI** | Interface interactive de l'API | `http://localhost:8080/swagger-ui.html` | `http://localhost/swagger-ui.html` |
| **API Docs JSON** | Documentation JSON OpenAPI | `http://localhost:8080/v3/api-docs` | `http://localhost/v3/api-docs` |
| **Health Check** | Verifier l'etat de l'API | `http://localhost:8080/api/health` | `http://localhost/api/health` |
| **Submit Contact** | Envoyer un message (POST) | `http://localhost:8080/api/contact` | `http://localhost/api/contact` |
| **List Contacts** | Lister tous les messages (GET) | `http://localhost:8080/api/contact` | `http://localhost/api/contact` |
| **Get Contact by ID** | Obtenir un message specifique | `http://localhost:8080/api/contact/{id}` | `http://localhost/api/contact/{id}` |
| **Update Contact** | Mettre a jour un message (PUT) | `http://localhost:8080/api/contact/{id}` | `http://localhost/api/contact/{id}` |
| **Delete Contact** | Supprimer un message (DELETE) | `http://localhost:8080/api/contact/{id}` | `http://localhost/api/contact/{id}` |

---

## 4. Tests de l'API

### A. Test Simple avec curl (Ligne de Commande)

#### 1. Verifier l'Etat de l'API

```bash
curl http://localhost:8080/api/health
```

**Reponse attendue** :
```json
{
  "status": "UP",
  "timestamp": "2024-11-23T10:30:00.000+00:00",
  "database": "Connected",
  "version": "1.0.0"
}
```

#### 2. Envoyer un Message de Contact

```bash
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "John Doe",
    "email": "john@example.com",
    "telephone": "0612345678",
    "sujet": "Test depuis VM",
    "message": "Ceci est un test de l API Contact Service"
  }'
```

**Reponse attendue** :
```json
{
  "id": 1,
  "nom": "John Doe",
  "email": "john@example.com",
  "telephone": "0612345678",
  "sujet": "Test depuis VM",
  "message": "Ceci est un test de l API Contact Service",
  "dateSoumission": "2024-11-23T10:35:00.000+00:00",
  "statut": "NOUVEAU",
  "lu": false
}
```

#### 3. Lister Tous les Messages

```bash
curl http://localhost:8080/api/contact | jq .
```

**Note** : `jq` permet de formater le JSON. Si non installe :
```bash
sudo apt install jq -y
```

#### 4. Obtenir un Message Specifique

```bash
# Remplacer {id} par l'ID du message (ex: 1)
curl http://localhost:8080/api/contact/1
```

#### 5. Mettre a Jour un Message

```bash
curl -X PUT http://localhost:8080/api/contact/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "John Doe",
    "email": "john.updated@example.com",
    "telephone": "0698765432",
    "sujet": "Sujet modifie",
    "message": "Message mis a jour",
    "statut": "TRAITE",
    "lu": true
  }'
```

#### 6. Supprimer un Message

```bash
curl -X DELETE http://localhost:8080/api/contact/1
```

---

### B. Test avec Swagger UI (Interface Graphique)

Swagger UI est l'outil le plus simple pour tester l'API sans ligne de commande.

#### Etape 1 : Ouvrir Swagger UI

```bash
# Sur la VM
firefox http://localhost:8080/swagger-ui.html &

# Ou depuis votre PC (avec l'IP de la VM)
# http://192.168.1.50:8080/swagger-ui.html
```

#### Etape 2 : Explorer l'API

1. Vous verrez tous les endpoints disponibles
2. Cliquez sur un endpoint (ex: `POST /api/contact`)
3. Cliquez sur **"Try it out"**
4. Remplissez les champs
5. Cliquez sur **"Execute"**
6. Consultez la reponse

#### Etape 3 : Tester l'Envoi d'un Message

1. Cliquez sur `POST /api/contact`
2. Cliquez sur **"Try it out"**
3. Modifiez le JSON :

```json
{
  "nom": "Marie Dupont",
  "email": "marie@example.com",
  "telephone": "0623456789",
  "sujet": "Demande d'information",
  "message": "Bonjour, je souhaite avoir plus d'informations sur vos services."
}
```

4. Cliquez sur **"Execute"**
5. Verifiez le **Response Code** : `201 Created`
6. Consultez le **Response Body** avec l'ID genere

---

### C. Test avec Postman (Avance)

Si vous preferez Postman :

1. **Telecharger Postman** : https://www.postman.com/downloads/
2. **Creer une nouvelle requete** :
   - Method : `POST`
   - URL : `http://192.168.1.50:8080/api/contact`
   - Headers : `Content-Type: application/json`
   - Body (raw, JSON) :
   ```json
   {
     "nom": "Test User",
     "email": "test@example.com",
     "telephone": "0612345678",
     "sujet": "Test Postman",
     "message": "Message de test depuis Postman"
   }
   ```
3. **Cliquer sur Send**

---

## 5. Troubleshooting

### Probleme 1 : "Connection refused" ou "Unable to connect"

**Symptome** :
```
curl: (7) Failed to connect to localhost port 8080: Connection refused
```

**Solutions** :

```bash
# 1. Verifier que Docker tourne
docker ps

# Vous devez voir 2 conteneurs : contact-service-app et contact-service-db

# 2. Si rien ne s'affiche, relancer l'application
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy docker compose up -d

# 3. Attendre 30 secondes
sleep 30

# 4. Retester
curl http://localhost:8080/api/health
```

---

### Probleme 2 : "404 Not Found" sur Swagger

**Symptome** :
```
404 Not Found : /swagger-ui.html
```

**Solution** :

Essayez ces URLs alternatives :

```bash
# URL moderne (Spring Boot 3.x)
http://localhost:8080/swagger-ui/index.html

# Ou directement
http://localhost:8080/swagger-ui.html
```

---

### Probleme 3 : Impossible d'acceder depuis Windows

**Symptome** : L'API fonctionne sur la VM mais pas depuis votre PC Windows.

**Solutions** :

#### A. Verifier le Pare-feu de la VM

```bash
# Autoriser le port 8080
sudo ufw allow 8080/tcp

# Ou desactiver temporairement le pare-feu (pour tester)
sudo ufw disable

# Retester depuis Windows
```

#### B. Verifier le Mode Reseau de VirtualBox

1. Ouvrir VirtualBox
2. Clic droit sur votre VM > **Configuration**
3. Aller dans **Reseau**
4. Verifier que l'adaptateur est en :
   - **"Acces par pont" (Bridged)** : Recommande, la VM aura sa propre IP
   - Ou **"NAT avec redirection de ports"** : Plus complexe

**Si en mode NAT, configurer la redirection** :
1. Cliquez sur **Avance** > **Redirection de ports**
2. Ajoutez une regle :
   - Nom : `API`
   - Protocole : `TCP`
   - IP hote : `127.0.0.1`
   - Port hote : `8080`
   - IP invite : (vide)
   - Port invite : `8080`
3. Cliquez sur **OK**
4. Redemarrez la VM
5. Depuis Windows, accedez a : `http://localhost:8080/swagger-ui.html`

---

### Probleme 4 : "502 Bad Gateway" avec Nginx

**Symptome** : Nginx est installe mais renvoie une erreur 502.

**Solutions** :

```bash
# 1. Verifier que l'application Spring Boot tourne
docker ps | grep contact-service-app

# 2. Verifier les logs Nginx
sudo tail -f /var/log/nginx/error.log

# 3. Verifier la configuration Nginx
sudo nginx -t

# 4. Redemarrer Nginx
sudo systemctl restart nginx

# 5. Tester directement le port 8080 (sans Nginx)
curl http://localhost:8080/api/health

# Si ca fonctionne, le probleme vient de Nginx
```

---

### Probleme 5 : Verifier les Logs de l'Application

Si l'API ne repond pas correctement :

```bash
# Aller dans le dossier de l'application
cd /home/deploy/apps/microservice-contact-service-spring-boot-2

# Voir les logs en temps reel
docker compose logs -f

# Ou seulement l'application Spring Boot
docker compose logs -f app

# Ou seulement PostgreSQL
docker compose logs -f postgres
```

---

## 6. Commandes Utiles

### Gestion de l'Application

```bash
# Voir l'etat des conteneurs
docker compose ps

# Demarrer l'application
sudo -u deploy docker compose up -d

# Arreter l'application
sudo -u deploy docker compose down

# Redemarrer l'application
sudo -u deploy docker compose restart

# Voir les logs
docker compose logs -f

# Voir les logs des 100 dernieres lignes
docker compose logs --tail=100

# Rebuild et redemarrer (apres modification du code)
sudo -u deploy docker compose up -d --build
```

---

### Gestion de Nginx

```bash
# Verifier la configuration Nginx
sudo nginx -t

# Demarrer Nginx
sudo systemctl start nginx

# Arreter Nginx
sudo systemctl stop nginx

# Redemarrer Nginx
sudo systemctl restart nginx

# Voir l'etat de Nginx
sudo systemctl status nginx

# Voir les logs Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

### Verification Rapide du Systeme

Utilisez le script de verification :

```bash
sudo bash /home/deploy/10-check-status.sh
```

Cela vous donnera :
- Etat des services (Docker, Nginx, UFW)
- Etat des conteneurs
- Utilisation des ressources (CPU, RAM, Disque)
- Verification des endpoints

---

## 7. Acces Rapide - Recapitulatif

### Sur la VM (local)

```bash
# Swagger UI
firefox http://localhost:8080/swagger-ui.html

# Health Check
curl http://localhost:8080/api/health

# Logs
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
docker compose logs -f
```

### Depuis Windows (avec IP de la VM)

1. Trouver l'IP : `hostname -I` sur la VM
2. Ouvrir dans le navigateur :
   - Swagger : `http://192.168.x.x:8080/swagger-ui.html`
   - Health : `http://192.168.x.x:8080/api/health`

### Avec Nginx (apres installation)

Plus besoin du `:8080` :
- `http://localhost/swagger-ui.html`
- `http://192.168.x.x/swagger-ui.html`

---

## 8. Prochaines Etapes

1. Installer Nginx (si pas encore fait)
2. Configurer un nom de domaine (optionnel)
3. Activer HTTPS avec Let's Encrypt (optionnel)
4. Configurer les emails SMTP pour recevoir les notifications
5. Tester tous les endpoints via Swagger UI

---

## Besoin d'Aide ?

- Consultez la FAQ : `documentation-etudiants/03-faq.md`
- Consultez le guide d'installation : `documentation-etudiants/01-guide-installation.md`
- Verifiez le statut du systeme : `sudo bash /home/deploy/10-check-status.sh`
- Voir les logs : `docker compose logs -f`

Bon courage et bonnes API !

