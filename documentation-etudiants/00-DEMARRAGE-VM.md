# DEMARRAGE RAPIDE - Installation sur VM Ubuntu

## Vous êtes sur votre VM Ubuntu Desktop en tant que root

### Commandes à Exécuter (Copier-Coller)

```bash
# 1. Aller dans le Bureau
cd /home/eleve/Bureau

# 2. Cloner le projet
git clone https://github.com/hrhouma2/microservice-contact-service-spring-boot-1.git

# 3. Entrer dans le dossier
cd microservice-contact-service-spring-boot-1/scripts

# 4. Rendre les scripts exécutables
chmod +x *.sh

# 5. Vérifier les prérequis
bash 00-verifier-prerequis.sh

# 6. Lancer l'installation complète
sudo bash 00-installation-complete.sh
```

---

## Ce qui va vous être demandé pendant l'installation

### 1. Continuer ? (o/n)
→ Tapez `o` puis Entrée

### 2. Mot de passe pour l'utilisateur deploy
→ Créez un mot de passe (ex: `deploy123`)
→ Retapez-le pour confirmer
→ **NOTEZ-LE !**

### 3. Copier les clés SSH ? (o/n)
→ Tapez `o` puis Entrée

### 4. Déployer l'application maintenant ? (o/n)
→ Tapez `o` puis Entrée

### 5. URL du repository GitHub
→ Tapez exactement :
```
https://github.com/hrhouma2/microservice-contact-service-spring-boot-1.git
```

### 6. Configuration SMTP

**SMTP_HOST [smtp.gmail.com] :**
→ Appuyez sur Entrée (utilise la valeur par défaut)

**SMTP_PORT [587] :**
→ Appuyez sur Entrée (utilise la valeur par défaut)

**SMTP_USER (email complet) :**
→ Tapez votre email Gmail complet
→ Exemple : `votreemail@gmail.com`

**SMTP_PASS (mot de passe d'application) :**
→ Collez votre mot de passe d'application Gmail (16 caractères)
→ Format : `abcd efgh ijkl mnop`
→ **Le texte ne s'affiche pas, c'est normal !**
→ Appuyez sur Entrée après avoir collé

**CONTACT_NOTIFICATION_EMAIL :**
→ Email où recevoir les notifications
→ Peut être le même que SMTP_USER

**CORS_ALLOWED_ORIGINS :**
→ Tapez : `http://localhost:3000,http://localhost:4321`

---

## Après l'Installation

### Vérifier que tout fonctionne

```bash
# Test rapide
curl http://localhost:8080/api/health

# Test complet
bash 06-tester-api.sh

# Voir le statut du système
bash 10-check-status.sh
```

### Accéder à Swagger (Documentation API)

Ouvrez un navigateur et allez sur :
```
http://localhost:8080/swagger-ui.html
```

---

## Commandes Utiles

```bash
# Voir les logs en temps réel
cd ~/apps/microservice-contact-service-spring-boot-1
docker compose logs -f app

# Arrêter l'affichage des logs
Ctrl + C

# Redémarrer l'application
docker compose restart

# Voir le statut des conteneurs
docker compose ps

# Arrêter l'application
docker compose down

# Démarrer l'application
docker compose up -d
```

---

## En cas de Problème

### Problème : "bash: git: command not found"
```bash
sudo apt update
sudo apt install git -y
```

### Problème : "Permission denied"
```bash
chmod +x *.sh
```

### Problème : Le script demande sh au lieu de bash
**Solution :** Utilisez toujours `bash` et non `sh`
```bash
# CORRECT
sudo bash 00-installation-complete.sh

# INCORRECT
sh 00-installation-complete.sh
```

### Problème : "Docker command not found" après installation
**Solution :** Reconnectez-vous
```bash
exit
# Reconnectez-vous en SSH ou ouvrez un nouveau terminal
```

---

## Support

- **Documentation complète** : Voir fichiers 01 à 05 dans ce dossier
- **FAQ** : Voir `03-faq.md` pour 28 questions/réponses
- **Checklist** : Voir `04-checklist.md` à imprimer

---

**Durée estimée** : 15-20 minutes  
**Version** : 1.0.0  
**Date** : Novembre 2025

