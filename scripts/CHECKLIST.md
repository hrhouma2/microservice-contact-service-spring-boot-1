# ✅ Checklist d'Installation - Contact Service API

## À imprimer et cocher au fur et à mesure

---

## 📋 AVANT L'INSTALLATION

### Informations Nécessaires

- [ ] J'ai l'IP de ma VM : `___________________`
- [ ] J'ai le mot de passe root : `___________________`
- [ ] J'ai un compte Gmail : `___________________`
- [ ] J'ai activé la validation en 2 étapes sur Gmail
- [ ] J'ai généré un mot de passe d'application Gmail (16 caractères)
- [ ] J'ai noté mon mot de passe d'application : `___________________`
- [ ] J'ai choisi l'email de notification : `___________________`

### Matériel

- [ ] VM Ubuntu 24.04 LTS installée et démarrée
- [ ] Au moins 2 GB de RAM (4 GB recommandé)
- [ ] Au moins 20 GB d'espace disque
- [ ] Connexion SSH fonctionnelle
- [ ] Connexion Internet active sur la VM

---

## 🚀 INSTALLATION

### Étape 1 : Connexion SSH

- [ ] Terminal ouvert sur mon PC
- [ ] Connexion SSH réussie : `ssh root@MON_IP_VM`
- [ ] Je vois l'invite de commande : `root@ubuntu:~#`

### Étape 2 : Téléchargement

```bash
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git
cd contact-service-springboot/scripts
chmod +x *.sh
```

- [ ] Projet cloné avec succès
- [ ] Je suis dans le dossier `scripts/`
- [ ] Scripts rendus exécutables

### Étape 3 : Vérification Prérequis

```bash
bash 00-verifier-prerequis.sh
```

- [ ] Script exécuté sans erreur
- [ ] Tous les checks sont ✓ verts
- [ ] Aucune erreur critique

### Étape 4 : Installation Complète

```bash
sudo bash 00-installation-complete.sh
```

- [ ] Script lancé
- [ ] Étape 1/5 : Docker installé ✓
- [ ] Étape 2/5 : Utilisateur `deploy` créé ✓
  - [ ] Mot de passe `deploy` défini et noté
  - [ ] Clés SSH copiées (si demandé)
- [ ] Étape 3/5 : Firewall configuré ✓
- [ ] Étape 4/5 : Nginx installé ✓
- [ ] Étape 5/5 : Application déployée ✓

### Étape 5 : Configuration SMTP

- [ ] `SMTP_HOST` : Entrée appuyée (défaut : smtp.gmail.com)
- [ ] `SMTP_PORT` : Entrée appuyée (défaut : 587)
- [ ] `SMTP_USER` : Mon email Gmail saisi
- [ ] `SMTP_PASS` : Mot de passe d'application collé (invisible = normal)
- [ ] `CONTACT_NOTIFICATION_EMAIL` : Email de notification saisi
- [ ] `CORS_ALLOWED_ORIGINS` : Origines saisies

### Étape 6 : Attente Démarrage

- [ ] Attente de 30 secondes terminée
- [ ] Message "✓ INSTALLATION COMPLÈTE TERMINÉE !" affiché

---

## 🧪 TESTS

### Test 1 : Health Check

```bash
curl http://localhost:8080/api/health
```

- [ ] Commande exécutée
- [ ] Réponse JSON reçue avec `"status":"ok"`

### Test 2 : Tests Automatiques

```bash
bash 06-tester-api.sh
```

- [ ] Test 1/3 : Health Check ✓
- [ ] Test 2/3 : Swagger ✓
- [ ] Test 3/3 : POST /api/contact ✓

### Test 3 : Swagger dans Navigateur

Ouvrir : `http://MON_IP_VM:8080/swagger-ui.html`

- [ ] Page Swagger affichée
- [ ] Documentation API visible

### Test 4 : Envoi Email Réel

Dans Swagger :
- [ ] POST /api/contact ouvert
- [ ] "Try it out" cliqué
- [ ] JSON modifié avec mes données
- [ ] "Execute" cliqué
- [ ] Code de réponse 201
- [ ] Email de notification reçu ✓

---

## 📊 VÉRIFICATIONS POST-INSTALLATION

### Docker

```bash
docker --version
systemctl status docker
docker compose ps
```

- [ ] Docker version affichée (20.10+)
- [ ] Service Docker actif et en cours d'exécution
- [ ] Conteneurs `contact-service-app` et `contact-service-db` : Up

### Firewall

```bash
sudo ufw status
```

- [ ] UFW actif
- [ ] Port 22 (SSH) autorisé
- [ ] Port 80 (HTTP) autorisé
- [ ] Port 443 (HTTPS) autorisé

### Base de Données

```bash
docker exec -it contact-service-db psql -U postgres -d contact_service -c "SELECT COUNT(*) FROM form_submissions;"
```

- [ ] Connexion PostgreSQL OK
- [ ] Requête exécutée avec succès
- [ ] Au moins 1 enregistrement (test) présent

### Logs

```bash
docker compose logs app | tail -20
```

- [ ] Logs affichés sans erreur majeure
- [ ] Message "Started ContactServiceApplication" visible

---

## 📚 COMMANDES ESSENTIELLES APPRISES

### Copier ces commandes pour référence future

```bash
# Voir les logs en temps réel
cd ~/apps/contact-service-springboot
docker compose logs -f app

# Redémarrer l'application
docker compose restart

# Arrêter l'application
docker compose down

# Démarrer l'application
docker compose up -d

# Vérifier le statut
docker compose ps

# Sauvegarder la base de données
bash ~/scripts/07-sauvegarder-db.sh

# Tester l'API
bash ~/scripts/06-tester-api.sh
```

- [ ] Commandes testées et comprises

---

## 🎯 OBJECTIFS ATTEINTS

### Formation

- [ ] Je sais me connecter en SSH
- [ ] Je sais utiliser Git
- [ ] Je sais exécuter des scripts bash
- [ ] Je sais utiliser Docker Compose
- [ ] Je sais lire des logs
- [ ] Je sais tester une API REST

### Projet

- [ ] Application Spring Boot déployée
- [ ] Base de données PostgreSQL fonctionnelle
- [ ] Envoi d'emails configuré et testé
- [ ] API REST accessible et documentée (Swagger)
- [ ] Firewall configuré correctement

---

## 📸 CAPTURES D'ÉCRAN À FAIRE (Optionnel)

Pour votre portfolio ou rapport :

- [ ] Terminal avec `docker compose ps` (statut des conteneurs)
- [ ] Navigateur avec Swagger UI
- [ ] Email de notification reçu
- [ ] Réponse JSON d'un test POST
- [ ] Logs de l'application

---

## 🐛 EN CAS DE PROBLÈME

### Ressources d'aide

- [ ] J'ai lu la [FAQ.md](FAQ.md)
- [ ] J'ai consulté les logs : `docker compose logs app`
- [ ] J'ai vérifié le statut : `docker compose ps`
- [ ] J'ai redémarré : `docker compose restart`

### Notes de dépannage

Problème rencontré : `_____________________________________________`

Solution appliquée : `_____________________________________________`

---

## ✨ FÉLICITATIONS !

Si toutes les cases sont cochées, vous avez réussi l'installation !

**Prochaines étapes possibles :**
- [ ] Intégrer l'API dans un site web
- [ ] Configurer un nom de domaine
- [ ] Installer SSL avec Let's Encrypt
- [ ] Mettre en place des sauvegardes automatiques
- [ ] Explorer la base de données PostgreSQL

---

**Date d'installation** : `____/____/2025`  
**Temps total** : `____` minutes  
**Nom de l'étudiant** : `_______________________`  
**Validé par** : `_______________________`

---

**Version** : 1.0.0  
**Document** : Checklist d'Installation Contact Service API

