# 📘 Guide d'Installation pour Débutants

## Contact Service API - Installation Complète sur VM

Ce guide vous accompagne **pas à pas** pour installer l'application sur une machine virtuelle Ubuntu. Aucune connaissance avancée requise !

---

## 🎯 Prérequis

### 1. Machine Virtuelle (VM)
- **OS** : Ubuntu Server 24.04 LTS (fraîchement installé)
- **RAM** : Minimum 2 GB (4 GB recommandé)
- **Disque** : Minimum 20 GB
- **CPU** : 2 vCPUs minimum
- **Accès** : Accès root via SSH

### 2. Compte Gmail
- Un compte Gmail pour envoyer les emails
- **Important** : Vous aurez besoin d'un "Mot de passe d'application" (voir étape 3)

### 3. Informations Nécessaires
Préparez ces informations AVANT de commencer :
```
- IP de votre VM : _________________
- Mot de passe root : _________________
- Email Gmail : _________________
- Mot de passe d'application Gmail : _________________
- Email de notification : _________________
```

---

## 📋 Comment obtenir un Mot de Passe d'Application Gmail ?

### Étape par Étape :

1. **Activer la validation en 2 étapes sur Gmail**
   - Allez sur https://myaccount.google.com/security
   - Cherchez "Validation en deux étapes"
   - Activez-la si ce n'est pas déjà fait

2. **Générer un mot de passe d'application**
   - Allez sur https://myaccount.google.com/apppasswords
   - Sélectionnez "Autre (nom personnalisé)"
   - Tapez : `Contact Service`
   - Cliquez sur "Générer"
   - **IMPORTANT** : Copiez le mot de passe de 16 caractères (exemple : `abcd efgh ijkl mnop`)
   - Conservez-le précieusement !

---

## 🚀 Installation Automatique (Recommandée pour débutants)

### Étape 1 : Se connecter à la VM

```bash
# Remplacez XXX.XXX.XXX.XXX par l'IP de votre VM
ssh root@XXX.XXX.XXX.XXX
```

**Exemple** :
```bash
ssh root@192.168.1.100
```

Entrez le mot de passe root quand demandé.

---

### Étape 2 : Télécharger les scripts

```bash
# Télécharger le projet
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git

# Entrer dans le dossier des scripts
cd contact-service-springboot/scripts

# Rendre les scripts exécutables
chmod +x *.sh
```

---

### Étape 3 : Lancer l'installation complète

```bash
sudo bash 00-installation-complete.sh
```

**Ce script va** :
- ✅ Installer Docker
- ✅ Créer l'utilisateur `deploy`
- ✅ Configurer le firewall
- ✅ Installer Nginx

**Durée** : 5-10 minutes

**Questions qui seront posées** :
1. "Continuer ? (o/n)" → Tapez `o` puis Entrée
2. "Définissez un mot de passe pour deploy" → Créez un mot de passe fort
3. "Copier les clés SSH ? (o/n)" → Tapez `o`
4. "Déployer l'application maintenant ? (o/n)" → Tapez `o`

---

### Étape 4 : Configuration SMTP

Quand le script demande les informations SMTP :

```
SMTP_HOST [smtp.gmail.com] : 
→ Appuyez sur Entrée (valeur par défaut)

SMTP_PORT [587] : 
→ Appuyez sur Entrée (valeur par défaut)

SMTP_USER (email complet) : 
→ Tapez votre email Gmail complet (exemple : votremail@gmail.com)

SMTP_PASS (mot de passe d'application) : 
→ Collez le mot de passe de 16 caractères généré précédemment
→ ATTENTION : le texte ne s'affichera pas (c'est normal)

CONTACT_NOTIFICATION_EMAIL : 
→ Email où vous voulez recevoir les notifications (peut être le même)

CORS_ALLOWED_ORIGINS (séparés par virgules) : 
→ Exemple : http://localhost:3000,http://votresite.com
```

---

### Étape 5 : Vérification

Une fois terminé, testez :

```bash
# Vérifier que l'application fonctionne
curl http://localhost:8080/api/health
```

**Résultat attendu** : Un JSON avec `"status":"ok"`

---

## 🧪 Test de l'API

### Test automatique

```bash
bash ~/scripts/06-tester-api.sh
```

### Test manuel avec un navigateur

Ouvrez dans votre navigateur :
- **Health Check** : `http://VOTRE_IP_VM:8080/api/health`
- **Swagger** : `http://VOTRE_IP_VM:8080/swagger-ui.html`

---

## 📊 Commandes Utiles

### Voir les logs de l'application
```bash
docker compose logs -f app
```

### Voir les logs de la base de données
```bash
docker compose logs -f postgres
```

### Arrêter l'application
```bash
cd ~/apps/contact-service-springboot
docker compose down
```

### Redémarrer l'application
```bash
cd ~/apps/contact-service-springboot
docker compose restart
```

### Vérifier le statut
```bash
docker compose ps
```

---

## 🐛 Dépannage

### Problème : "Permission denied"
**Solution** :
```bash
chmod +x nom-du-script.sh
```

### Problème : "Docker command not found"
**Solution** : Reconnectez-vous pour que les groupes soient pris en compte
```bash
exit
ssh deploy@VOTRE_IP_VM
```

### Problème : L'application ne démarre pas
**Solution** : Vérifiez les logs
```bash
cd ~/apps/contact-service-springboot
docker compose logs app
```

### Problème : Erreur SMTP lors de l'envoi d'email
**Causes possibles** :
1. Mauvais mot de passe d'application Gmail
2. Validation en 2 étapes non activée
3. Email Gmail incorrect

**Solution** : Re-créer le fichier .env
```bash
cd ~/apps/contact-service-springboot
nano .env
# Corrigez les valeurs SMTP_USER et SMTP_PASS
# Ctrl+X puis Y pour sauvegarder

# Redémarrer
docker compose restart
```

### Problème : Port 8080 non accessible depuis l'extérieur
**Solution** : C'est normal ! Par sécurité, le port 8080 n'est accessible que depuis la VM.
Pour un accès externe, utilisez Nginx (voir étape avancée).

---

## 🔄 Mise à Jour de l'Application

```bash
cd ~/apps/contact-service-springboot
git pull
docker compose down
docker compose up -d --build
```

---

## 💾 Sauvegarde de la Base de Données

```bash
bash ~/scripts/07-sauvegarder-db.sh
```

Les sauvegardes sont stockées dans `~/apps/backups/`

---

## 🆘 Besoin d'Aide ?

### Vérifier l'état du système
```bash
# Docker
systemctl status docker

# Application
cd ~/apps/contact-service-springboot
docker compose ps

# Firewall
sudo ufw status
```

### Consulter les logs système
```bash
# Logs Docker
sudo journalctl -u docker -n 50

# Logs application
docker compose logs --tail=50
```

---

## 📝 Résumé des Commandes

```bash
# Installation complète
sudo bash 00-installation-complete.sh

# Voir les logs
docker compose logs -f

# Redémarrer
docker compose restart

# Tester l'API
bash ~/scripts/06-tester-api.sh

# Sauvegarder la DB
bash ~/scripts/07-sauvegarder-db.sh

# Vérifier le statut
docker compose ps
```

---

## ✅ Checklist Post-Installation

- [ ] Application démarrée (`docker compose ps`)
- [ ] Health check OK (`curl http://localhost:8080/api/health`)
- [ ] Swagger accessible (navigateur)
- [ ] Test POST fonctionnel
- [ ] Email de notification reçu
- [ ] Firewall configuré (`sudo ufw status`)

---

## 📚 Prochaines Étapes (Optionnel)

1. **Installer Nginx** pour un accès externe propre
2. **Configurer SSL** avec Let's Encrypt
3. **Mettre en place des sauvegardes automatiques**
4. **Configurer un nom de domaine**

---

## 🎓 Pour Aller Plus Loin

- **Documentation API** : Voir `documentation/00-cahier-des-charges.md`
- **Déploiement avancé** : Voir `documentation/02-deploiement-ubuntu-24-04.md`
- **Scripts de maintenance** : Voir `scripts/07-maintenance.sh`

---

**Version** : 1.0.0  
**Dernière mise à jour** : Novembre 2025  
**Support** : Ouvrir une issue sur GitHub

