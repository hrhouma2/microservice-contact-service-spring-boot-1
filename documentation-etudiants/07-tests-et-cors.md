# Guide de Test et Configuration CORS

## Table des Matieres

1. [Format JSON Correct pour l'API](#1-format-json-correct-pour-lapi)
2. [Exemples de Requetes](#2-exemples-de-requetes)
3. [Configuration CORS](#3-configuration-cors)
4. [URLs d'Acces](#4-urls-dacces)
5. [Troubleshooting CORS](#5-troubleshooting-cors)

---

## 1. Format JSON Correct pour l'API

### A. Structure Complete

```json
{
  "formId": "contact-form-1",
  "email": "utilisateur@example.com",
  "name": "Nom de l'utilisateur",
  "message": "Le message complet",
  "pageUrl": "http://localhost:3000/contact",
  "referrer": "http://localhost:3000",
  "data": {
    "telephone": "0612345678",
    "sujet": "Demande d'information",
    "autreChamp": "valeur personnalisee"
  }
}
```

### B. Champs Obligatoires (Minimum)

```json
{
  "formId": "test-form",
  "email": "test@example.com"
}
```

**Important** : Seuls `formId` et `email` sont obligatoires. Tous les autres champs sont optionnels.

### C. Description des Champs

| Champ | Type | Obligatoire | Description | Exemple |
|-------|------|-------------|-------------|---------|
| `formId` | String | Oui | Identifiant du formulaire (lettres, chiffres, `-`, `_`) | `"contact-form-1"` |
| `email` | String | Oui | Email valide | `"user@example.com"` |
| `name` | String | Non | Nom de l'utilisateur | `"Jean Dupont"` |
| `message` | String | Non | Message complet | `"Votre message ici"` |
| `pageUrl` | String | Non | URL de la page du formulaire | `"http://localhost:3000/contact"` |
| `referrer` | String | Non | URL de provenance | `"http://localhost:3000"` |
| `data` | Object | Non | Donnees supplementaires (cles/valeurs libres) | `{"telephone": "0612345678"}` |

### D. Regles de Validation

**formId** :
- Entre 1 et 100 caracteres
- Uniquement lettres, chiffres, tirets (-) et underscores (_)
- Exemples valides : `contact-form`, `form_1`, `contact-2024`
- Exemples invalides : `form@1`, `form 1`, `form#test`

**email** :
- Format email valide
- Maximum 500 caracteres
- Exemples valides : `user@example.com`, `jean.dupont@gmail.com`

**Autres champs** :
- `name`, `pageUrl`, `referrer` : Maximum 500 caracteres
- `message` : Maximum 5000 caracteres
- `data` : Objet JSON libre (cles et valeurs personnalisees)

---

## 2. Exemples de Requetes

### A. Exemple Minimal (curl)

```bash
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test",
    "email": "test@example.com"
  }'
```

**Reponse attendue (201 Created)** :
```json
{
  "success": true,
  "submissionId": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Votre message a ete envoye avec succes",
  "timestamp": "2025-11-23T10:30:00.000+00:00"
}
```

### B. Exemple Complet (curl)

```bash
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "contact-form-1",
    "email": "jean.dupont@example.com",
    "name": "Jean Dupont",
    "message": "Bonjour, je souhaite obtenir plus d informations sur vos services.",
    "pageUrl": "http://localhost:3000/contact",
    "referrer": "http://localhost:3000/home",
    "data": {
      "telephone": "0612345678",
      "sujet": "Demande d information",
      "entreprise": "Ma Societe SARL",
      "consentement": true
    }
  }'
```

### C. Exemple avec Telephone et Sujet (curl)

```bash
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "form-support",
    "email": "support@example.com",
    "name": "Marie Martin",
    "message": "J ai un probleme avec mon compte",
    "data": {
      "telephone": "0623456789",
      "sujet": "Support technique"
    }
  }'
```

### D. Exemple dans Swagger UI

1. Ouvrir Swagger : `http://localhost:8080/swagger-ui.html`
2. Cliquer sur **POST /api/contact**
3. Cliquer sur **"Try it out"**
4. Remplacer le JSON par :

```json
{
  "formId": "swagger-test",
  "email": "test@swagger.com",
  "name": "Test Swagger",
  "message": "Message de test depuis Swagger UI",
  "data": {
    "telephone": "0698765432",
    "sujet": "Test"
  }
}
```

5. Cliquer sur **"Execute"**

### E. Exemple JavaScript (Frontend)

```javascript
// Exemple avec fetch API
const submitContact = async () => {
  const response = await fetch('http://localhost:8080/api/contact', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      formId: 'contact-form-web',
      email: 'user@example.com',
      name: 'Utilisateur Web',
      message: 'Message depuis le site web',
      pageUrl: window.location.href,
      referrer: document.referrer,
      data: {
        telephone: '0612345678',
        sujet: 'Contact depuis le site'
      }
    })
  });
  
  const data = await response.json();
  console.log(data);
};
```

### F. Exemple Python (requests)

```python
import requests
import json

url = "http://localhost:8080/api/contact"
payload = {
    "formId": "python-test",
    "email": "test@python.com",
    "name": "Test Python",
    "message": "Message de test depuis Python",
    "data": {
        "telephone": "0612345678",
        "sujet": "Test API"
    }
}

headers = {
    "Content-Type": "application/json"
}

response = requests.post(url, json=payload, headers=headers)
print(response.status_code)
print(response.json())
```

---

## 3. Configuration CORS

### A. Qu'est-ce que CORS ?

**CORS** (Cross-Origin Resource Sharing) est un mecanisme de securite qui controle quels sites web peuvent acceder a votre API.

**Exemple** :
- Votre API est sur : `http://192.168.1.50:8080`
- Votre site web est sur : `http://192.168.1.100:3000`
- Sans CORS, le navigateur **bloque** les requetes du site vers l'API

### B. Configuration Actuelle (Par Defaut)

Par defaut, l'application autorise :
```
http://localhost:3000
http://localhost:4321
```

Cette configuration se trouve dans le fichier `.env` :
```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4321
```

### C. Autoriser TOUTES les Origines (Development)

**ATTENTION** : A utiliser UNIQUEMENT en developpement, JAMAIS en production !

#### Methode : Via Variable d'Environnement

```bash
# Aller dans le dossier de l'application
cd /home/deploy/apps/microservice-contact-service-spring-boot-2

# Editer le fichier .env
sudo -u deploy nano .env
```

Modifier la ligne `CORS_ALLOWED_ORIGINS` :

```env
# AVANT (restrictif)
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4321

# APRES (autoriser TOUT - DEVELOPPEMENT UNIQUEMENT)
CORS_ALLOWED_ORIGINS=*
```

Sauvegarder (`Ctrl+X`, `Y`, `Entree`) et redemarrer :

```bash
sudo -u deploy docker compose restart

# Attendre 30 secondes
sleep 30

# Verifier
curl http://localhost:8080/api/health
```

### D. Autoriser des IPs Specifiques

Si vous voulez autoriser seulement certaines adresses :

```env
CORS_ALLOWED_ORIGINS=http://192.168.1.50:8080,http://192.168.1.100:3000,http://localhost:3000,http://localhost:4321
```

### E. Exemples de Configuration CORS

#### Exemple 1 : Developpement Local

```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4321,http://localhost:8080
```

#### Exemple 2 : Reseau Local (VM + PC Windows)

```env
# IP de la VM : 192.168.1.50
# IP du PC Windows : 192.168.1.100
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.50:8080,http://192.168.1.100:3000,http://192.168.1.100:8080
```

#### Exemple 3 : Autoriser Tout (Developpement)

```env
CORS_ALLOWED_ORIGINS=*
```

#### Exemple 4 : Production (HTTPS uniquement)

```env
CORS_ALLOWED_ORIGINS=https://monsite.com,https://www.monsite.com,https://app.monsite.com
```

### F. Verification de la Configuration CORS

```bash
# Test avec curl (simule une requete depuis un navigateur)
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -H "Origin: http://192.168.1.100:3000" \
  -v \
  -d '{
    "formId": "test",
    "email": "test@example.com"
  }'
```

Cherchez dans la reponse :
```
< Access-Control-Allow-Origin: *
```

Ou si vous avez configure une origine specifique :
```
< Access-Control-Allow-Origin: http://192.168.1.100:3000
```

Si vous voyez cette ligne, CORS est correctement configure.

---

## 4. URLs d'Acces

### A. Acces Local (sur la VM)

| Description | URL |
|-------------|-----|
| API (port 8080) | `http://localhost:8080/api/contact` |
| Swagger UI | `http://localhost:8080/swagger-ui.html` |
| Health Check | `http://localhost:8080/api/health` |
| API Docs JSON | `http://localhost:8080/v3/api-docs` |

### B. Acces depuis Reseau Local (autres PC)

**Etape 1** : Trouver l'IP de la VM

```bash
# Sur la VM, executez :
hostname -I
```

Exemple de resultat : `192.168.1.50` ou `192.168.177.5` ou `10.0.2.15`

**Etape 2** : Utiliser cette IP depuis n'importe quel appareil sur le meme reseau

| Description | URL (exemple avec IP 192.168.1.50) |
|-------------|-------------------------------------|
| API | `http://192.168.1.50:8080/api/contact` |
| Swagger UI | `http://192.168.1.50:8080/swagger-ui.html` |
| Health Check | `http://192.168.1.50:8080/api/health` |

**IMPORTANT** : Remplacez `192.168.1.50` par l'IP reelle de votre VM !

### C. Exemples d'URLs avec Differentes IPs

#### Exemple 1 : IP 192.168.1.50

```bash
# API
http://192.168.1.50:8080/api/contact

# Swagger
http://192.168.1.50:8080/swagger-ui.html

# Health
http://192.168.1.50:8080/api/health

# Test curl depuis n'importe quel PC du reseau
curl -X POST http://192.168.1.50:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{"formId": "test", "email": "test@example.com"}'
```

#### Exemple 2 : IP 192.168.177.5

```bash
# API
http://192.168.177.5:8080/api/contact

# Swagger
http://192.168.177.5:8080/swagger-ui.html

# Health
http://192.168.177.5:8080/api/health

# Test curl
curl http://192.168.177.5:8080/api/health
```

#### Exemple 3 : IP 10.0.2.15

```bash
# API
http://10.0.2.15:8080/api/contact

# Swagger
http://10.0.2.15:8080/swagger-ui.html

# Health
http://10.0.2.15:8080/api/health
```

### D. Avec Nginx (port 80)

Si vous avez installe Nginx, plus besoin du `:8080` :

```bash
# API
http://192.168.1.50/api/contact

# Swagger
http://192.168.1.50/swagger-ui.html

# Health
http://192.168.1.50/api/health
```

### E. Depuis un Frontend Web

#### Exemple avec React (localhost)

```javascript
// Frontend sur http://localhost:3000
// API sur http://192.168.1.50:8080

const API_URL = 'http://192.168.1.50:8080/api/contact';

const handleSubmit = async (formData) => {
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        formId: 'react-contact-form',
        email: formData.email,
        name: formData.name,
        message: formData.message,
        pageUrl: window.location.href,
        data: {
          telephone: formData.telephone,
          sujet: formData.sujet
        }
      }),
    });
    
    const data = await response.json();
    console.log('Succes:', data);
  } catch (error) {
    console.error('Erreur:', error);
  }
};
```

#### Exemple avec Vue.js

```javascript
// Frontend sur http://192.168.1.100:8080
// API sur http://192.168.1.50:8080

export default {
  data() {
    return {
      apiUrl: 'http://192.168.1.50:8080/api/contact',
      formData: {
        formId: 'vue-form',
        email: '',
        name: '',
        message: ''
      }
    }
  },
  methods: {
    async submitForm() {
      try {
        const response = await fetch(this.apiUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(this.formData)
        });
        const result = await response.json();
        console.log(result);
      } catch (error) {
        console.error(error);
      }
    }
  }
}
```

### F. Configuration CORS pour ces URLs

Dans le fichier `.env`, ajoutez toutes les origines necessaires :

```env
# Pour reseau local avec plusieurs IPs
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4321,http://192.168.1.50:8080,http://192.168.1.100:3000,http://192.168.1.100:8080,http://192.168.177.5:3000
```

Ou simplement (pour le developpement) :

```env
# Autoriser TOUT
CORS_ALLOWED_ORIGINS=*
```

---

## 5. Troubleshooting CORS

### Erreur : "has been blocked by CORS policy"

**Message complet** :
```
Access to fetch at 'http://192.168.1.50:8080/api/contact' from origin 'http://localhost:3000' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present.
```

**Solution 1** : Autoriser toutes les origines (developpement)

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy nano .env
```

Modifier :
```env
CORS_ALLOWED_ORIGINS=*
```

Redemarrer :
```bash
sudo -u deploy docker compose restart
```

**Solution 2** : Ajouter l'origine specifique

```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.100:3000
```

### Erreur : "Network request failed"

**Causes possibles** :

1. **Pare-feu bloque le port 8080**

```bash
# Autoriser le port
sudo ufw allow 8080/tcp
sudo ufw reload

# Verifier
sudo ufw status
```

2. **Application Docker non demarree**

```bash
# Verifier
docker compose ps

# Doit afficher 2 conteneurs running

# Redemarrer si necessaire
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy docker compose up -d
```

3. **Mauvaise IP**

```bash
# Verifier l'IP correcte de la VM
hostname -I

# Ou
ip addr show
```

4. **Mode reseau VirtualBox incorrect**

Si vous utilisez VirtualBox, verifiez que la VM est en mode "Acces par pont" (Bridged) :
1. Ouvrir VirtualBox
2. Clic droit sur votre VM > Configuration
3. Reseau > Adaptateur 1
4. Mode d'acces reseau : **Acces par pont**
5. Redemarrer la VM

### Erreur 400 Bad Request

**Cause** : Format JSON invalide ou champs manquants.

**Solution** : Verifier que vous avez au minimum :

```json
{
  "formId": "valide-form-id",
  "email": "email@valide.com"
}
```

**Exemple d'erreur** :
```json
{
  "timestamp": "2025-11-23T10:30:00.000+00:00",
  "status": 400,
  "error": "Bad Request",
  "path": "/api/contact"
}
```

Verifiez :
- Le `formId` contient uniquement des lettres, chiffres, `-` et `_`
- L'`email` est au format valide
- Le JSON est bien forme (pas de virgule manquante, guillemets corrects)

### Erreur 500 Internal Server Error

**Cause** : Probleme serveur (base de donnees, email, etc.)

**Solution** :

```bash
# Voir les logs
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
docker compose logs -f app

# Verifier PostgreSQL
docker compose logs postgres

# Verifier que la base de donnees fonctionne
docker exec -it contact-service-db psql -U postgres -d contact_service -c "\dt"
```

---

## 6. Commandes Rapides de Test

### Test Complet depuis la VM

```bash
# 1. Health check
curl http://localhost:8080/api/health

# 2. Envoyer un message minimal
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test",
    "email": "test@example.com"
  }'

# 3. Envoyer un message complet
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "formId": "test-complet",
    "email": "test@example.com",
    "name": "Test User",
    "message": "Message de test complet",
    "data": {
      "telephone": "0612345678",
      "sujet": "Test"
    }
  }'

# 4. Verifier les logs
docker compose logs --tail=50 app
```

### Test depuis Windows (PowerShell)

```powershell
# Remplacer 192.168.1.50 par l'IP de votre VM

# Health check
Invoke-WebRequest -Uri "http://192.168.1.50:8080/api/health"

# Envoyer un message
$body = @{
    formId = "test-windows"
    email = "test@example.com"
    name = "Test Windows"
    message = "Test depuis Windows"
    data = @{
        telephone = "0612345678"
        sujet = "Test PowerShell"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://192.168.1.50:8080/api/contact" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

### Test depuis Windows (curl dans Git Bash)

```bash
# Health check
curl http://192.168.1.50:8080/api/health

# Envoyer un message
curl -X POST http://192.168.1.50:8080/api/contact \
  -H "Content-Type: application/json" \
  -d "{\"formId\": \"test\", \"email\": \"test@example.com\"}"
```

---

## 7. Recapitulatif : Configuration Complete pour Reseau Local

### Etape 1 : Trouver l'IP de la VM

```bash
hostname -I
```

Resultat exemple : `192.168.1.50`

### Etape 2 : Configurer CORS pour Autoriser Tout

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy nano .env
```

Modifier :
```env
CORS_ALLOWED_ORIGINS=*
```

Sauvegarder (`Ctrl+X`, `Y`, `Entree`)

### Etape 3 : Ouvrir le Pare-feu

```bash
sudo ufw allow 8080/tcp
sudo ufw reload
sudo ufw status
```

### Etape 4 : Redemarrer l'Application

```bash
sudo -u deploy docker compose restart

# Attendre 30 secondes
sleep 30
```

### Etape 5 : Tester depuis la VM

```bash
curl http://localhost:8080/api/health
```

### Etape 6 : Tester depuis Windows

Dans un navigateur sur votre PC Windows :
```
http://192.168.1.50:8080/swagger-ui.html
http://192.168.1.50:8080/api/health
```

Ou avec curl/PowerShell (voir section precedente)

### Etape 7 : Utiliser dans votre Application Frontend

```javascript
// Dans votre code JavaScript/React/Vue
const API_URL = 'http://192.168.1.50:8080/api/contact';

fetch(API_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    formId: 'mon-formulaire',
    email: 'user@example.com',
    name: 'Nom Utilisateur',
    message: 'Mon message'
  })
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error(error));
```

---

## 8. Securite : Configuration Production

**IMPORTANT** : En production, JAMAIS `CORS_ALLOWED_ORIGINS=*` !

### Configuration Recommandee pour Production

```env
# Autoriser uniquement vos domaines
CORS_ALLOWED_ORIGINS=https://monsite.com,https://www.monsite.com,https://app.monsite.com
```

### Bonnes Pratiques

1. **HTTPS uniquement** en production
2. **Domaines specifiques** (pas de `*`)
3. **Pas d'IPs publiques** dans CORS
4. **Firewall** : Limiter l'acces au port 8080

### Exemple Production Complete

```env
# .env en production
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASS=votre-mot-de-passe-app
CONTACT_NOTIFICATION_EMAIL=notifications@monsite.com
CORS_ALLOWED_ORIGINS=https://monsite.com,https://www.monsite.com
```

---

## 9. Aide Rapide

### Je veux tester rapidement l'API

```bash
curl -X POST http://localhost:8080/api/contact \
  -H "Content-Type: application/json" \
  -d '{"formId": "test", "email": "test@example.com"}'
```

### Je veux autoriser toutes les origines (dev)

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy nano .env
# Changer: CORS_ALLOWED_ORIGINS=*
sudo -u deploy docker compose restart
```

### Je veux voir les logs

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
docker compose logs -f app
```

### Je veux connaitre l'IP de ma VM

```bash
hostname -I
```

### Je veux ouvrir Swagger depuis Windows

```
http://IP-DE-LA-VM:8080/swagger-ui.html
```

Exemple : `http://192.168.1.50:8080/swagger-ui.html`

---

Bon developpement !

