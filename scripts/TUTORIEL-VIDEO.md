# 🎬 Tutoriel Vidéo (Format Texte)
## Installation Contact Service API - Étape par Étape

Ce guide est conçu comme un **tutoriel vidéo** au format texte.  
Suivez **EXACTEMENT** chaque commande dans l'ordre.

---

## 🎯 Avant de Commencer

### Ce dont vous avez besoin :
- [ ] Une VM Ubuntu 24.04 avec accès SSH
- [ ] Le mot de passe root de votre VM
- [ ] Un compte Gmail avec validation 2 étapes activée
- [ ] Un mot de passe d'application Gmail (voir guide)

### Temps estimé : **15 minutes**

---

## 📹 PARTIE 1 : Connexion à la VM (2 min)

### Étape 1.1 : Ouvrir un terminal

**Windows** :
- Ouvrir "PowerShell" ou "Windows Terminal"
- OU installer "PuTTY" : https://www.putty.org/

**Mac/Linux** :
- Ouvrir l'application "Terminal"

---

### Étape 1.2 : Se connecter en SSH

```bash
ssh root@VOTRE_IP_VM
```

**Exemple concret** :
```bash
ssh root@192.168.1.100
```

**Ce qui va se passer** :
1. Message : `Are you sure you want to continue connecting?`
   → Tapez `yes` puis Entrée
2. Message : `Password:`
   → Tapez le mot de passe root (ne s'affiche pas, c'est normal)
   → Appuyez sur Entrée

**Résultat attendu** :
```
Welcome to Ubuntu 24.04 LTS
root@ubuntu:~#
```

✅ **Checkpoint** : Vous voyez `root@` dans le terminal ? Continuez !

---

## 📹 PARTIE 2 : Vérification des Prérequis (2 min)

### Étape 2.1 : Télécharger le projet

```bash
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git
```

> ⚠️ **IMPORTANT** : Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub

**Exemple** :
```bash
git clone https://github.com/jdupont/contact-service-springboot.git
```

---

### Étape 2.2 : Entrer dans le dossier

```bash
cd contact-service-springboot/scripts
```

**Résultat attendu** :
```
root@ubuntu:~/contact-service-springboot/scripts#
```

---

### Étape 2.3 : Rendre les scripts exécutables

```bash
chmod +x *.sh
```

Pas de message = OK !

---

### Étape 2.4 : Vérifier les prérequis

```bash
bash 00-verifier-prerequis.sh
```

**Attendez 10-15 secondes...**

**Résultat attendu** :
```
✓ Ubuntu 24.04 LTS détecté
✓ Connexion Internet OK
✓ Espace disque suffisant
...
✓ Tous les prérequis sont remplis !
```

✅ **Checkpoint** : Vous voyez des ✓ verts ? Continuez !

---

## 📹 PARTIE 3 : Installation Automatique (10 min)

### Étape 3.1 : Lancer l'installation complète

```bash
sudo bash 00-installation-complete.sh
```

**Ce qui va se passer** :

---

#### ⏱️ Minute 0-2 : Installation de Docker

Vous allez voir :
```
==========================================
ÉTAPE 1/5 : Installation de Docker
==========================================
[1/8] Mise à jour du système...
[2/8] Installation des outils de base...
...
```

⏳ **Attendez patiemment** : Cela peut prendre 2-3 minutes.

---

#### ⏱️ Minute 2-3 : Création de l'utilisateur

```
==========================================
ÉTAPE 2/5 : Création de l'utilisateur deploy
==========================================
Définissez un MOT DE PASSE FORT pour deploy :
```

**Action requise** :
1. Tapez un mot de passe (minimum 8 caractères)
2. Appuyez sur Entrée
3. Retapez le même mot de passe
4. Appuyez sur Entrée

> 💡 **Astuce** : Notez ce mot de passe quelque part !

---

Puis :
```
Voulez-vous copier les clés SSH de root vers deploy ? (o/n)
```

**Action requise** :
- Tapez `o` puis Entrée

---

#### ⏱️ Minute 3-4 : Configuration du firewall

```
==========================================
ÉTAPE 3/5 : Configuration du firewall
==========================================
...
```

✅ Rien à faire, attendez simplement.

---

#### ⏱️ Minute 4-5 : Installation de Nginx

```
==========================================
ÉTAPE 4/5 : Installation de Nginx
==========================================
...
```

✅ Rien à faire, attendez simplement.

---

#### ⏱️ Minute 5 : Déploiement de l'application

```
==========================================
✓ INSTALLATION SYSTÈME TERMINÉE
==========================================

Déployer l'application maintenant ? (o/n)
```

**Action requise** :
- Tapez `o` puis Entrée

---

### Étape 3.2 : Configuration SMTP (IMPORTANT !)

Vous allez maintenant configurer l'envoi d'emails.

---

**Question 1 :**
```
SMTP_HOST [smtp.gmail.com] :
```

**Action** : Appuyez sur Entrée (valeur par défaut OK)

---

**Question 2 :**
```
SMTP_PORT [587] :
```

**Action** : Appuyez sur Entrée (valeur par défaut OK)

---

**Question 3 :**
```
SMTP_USER (email complet) :
```

**Action** : Tapez votre email Gmail complet
**Exemple** : `jean.dupont@gmail.com`

---

**Question 4 :**
```
SMTP_PASS (mot de passe d'application) :
```

**Action** : 
1. Collez le mot de passe de 16 caractères généré sur Gmail
2. **ATTENTION** : Le texte ne s'affiche PAS (c'est normal pour la sécurité)
3. Appuyez sur Entrée

**Format du mot de passe** : `abcd efgh ijkl mnop`

---

**Question 5 :**
```
CONTACT_NOTIFICATION_EMAIL :
```

**Action** : Tapez l'email où recevoir les notifications
**Exemple** : `notifications@votredomaine.com` OU le même que SMTP_USER

---

**Question 6 :**
```
CORS_ALLOWED_ORIGINS (séparés par virgules) :
```

**Action** : Tapez les domaines autorisés
**Exemple pour tests** : `http://localhost:3000,http://localhost:4321`

---

#### ⏱️ Minute 6-10 : Construction et démarrage

```
[5/6] Démarrage de l'application avec Docker Compose...
[6/6] Attente du démarrage (30 secondes)...
```

⏳ **Attendez 30-60 secondes** pendant que Docker télécharge et démarre l'application.

---

### Étape 3.3 : Vérification

À la fin, vous devriez voir :
```
==========================================
✓ INSTALLATION COMPLÈTE TERMINÉE !
==========================================

✓ Health check OK : http://localhost:8080/api/health
```

✅ **Checkpoint** : Vous voyez ce message ? **Bravo, c'est installé !**

---

## 📹 PARTIE 4 : Tests (2 min)

### Étape 4.1 : Tester le health check

```bash
curl http://localhost:8080/api/health
```

**Résultat attendu** : Un gros texte JSON avec `"status":"ok"`

---

### Étape 4.2 : Test automatique complet

```bash
bash 06-tester-api.sh
```

Appuyez sur Entrée quand demandé (pour utiliser http://localhost:8080)

**Résultat attendu** :
```
[Test 1/3] Health Check...
✓ Health check OK

[Test 2/3] Documentation Swagger...
✓ Swagger accessible

[Test 3/3] POST /api/contact...
✓ POST /api/contact OK
```

---

### Étape 4.3 : Tester dans un navigateur

1. Ouvrez votre navigateur web
2. Allez sur : `http://VOTRE_IP_VM:8080/swagger-ui.html`

**Exemple** : `http://192.168.1.100:8080/swagger-ui.html`

**Résultat attendu** : Vous voyez l'interface Swagger avec la documentation de l'API

---

### Étape 4.4 : Tester l'envoi d'email

Dans Swagger :

1. Cliquez sur **POST /api/contact**
2. Cliquez sur **Try it out**
3. Modifiez le JSON :
```json
{
  "formId": "test-etudiant",
  "email": "votre-email@example.com",
  "name": "Votre Nom",
  "message": "Test depuis Swagger"
}
```
4. Cliquez sur **Execute**
5. Vérifiez que vous avez reçu l'email de notification !

---

## 🎉 Félicitations !

Vous avez installé avec succès le Contact Service API !

---

## 📚 Commandes à Retenir

### Voir les logs en temps réel
```bash
cd ~/apps/contact-service-springboot
docker compose logs -f app
```

Appuyez sur `Ctrl+C` pour arrêter l'affichage des logs.

---

### Redémarrer l'application
```bash
cd ~/apps/contact-service-springboot
docker compose restart
```

---

### Arrêter l'application
```bash
cd ~/apps/contact-service-springboot
docker compose down
```

---

### Redémarrer l'application
```bash
cd ~/apps/contact-service-springboot
docker compose up -d
```

---

### Vérifier le statut
```bash
docker compose ps
```

---

## 🐛 Problèmes Fréquents

### Problème 1 : "bash: command not found"

**Solution** :
```bash
chmod +x *.sh
```

---

### Problème 2 : "Permission denied"

**Solution** : Utilisez `sudo`
```bash
sudo bash nom-du-script.sh
```

---

### Problème 3 : Pas d'email reçu

**Causes possibles** :
1. Mauvais mot de passe d'application Gmail
2. Email Gmail incorrect

**Solution** : Re-configurer
```bash
cd ~/apps/contact-service-springboot
nano .env
```

Modifiez les lignes `SMTP_USER` et `SMTP_PASS`
- Appuyez sur `Ctrl+X`
- Tapez `Y`
- Appuyez sur Entrée

Puis redémarrez :
```bash
docker compose restart
```

---

### Problème 4 : Port 8080 non accessible depuis mon PC

**C'est normal !** Par sécurité, le port 8080 n'est accessible que depuis la VM.

**Solution** : Utilisez Nginx comme reverse proxy (voir documentation avancée)

---

## 📞 Aide

Si vous êtes bloqué :

1. Vérifiez les logs :
```bash
docker compose logs app
```

2. Vérifiez que Docker tourne :
```bash
systemctl status docker
```

3. Vérifiez que les conteneurs sont lancés :
```bash
docker compose ps
```

---

**Version** : 1.0.0  
**Durée totale** : ~15 minutes  
**Niveau** : Débutant

