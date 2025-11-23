# 🚀 AIDE-MÉMOIRE - Installation Contact Service API

## Installation en 5 Minutes

### 1️⃣ Connexion SSH
```bash
ssh root@VOTRE_IP_VM
```

### 2️⃣ Télécharger le Projet
```bash
git clone https://github.com/VOTRE_USERNAME/contact-service-springboot.git
cd contact-service-springboot
chmod +x START-HERE.sh scripts/*.sh
```

### 3️⃣ Lancer l'Installation
```bash
bash START-HERE.sh
```
Suivez les instructions à l'écran.

**OU** Installation directe :
```bash
sudo bash scripts/00-installation-complete.sh
```

### 4️⃣ Tester
```bash
bash scripts/06-tester-api.sh
```

---

## 📋 Prérequis

- [ ] VM Ubuntu 24.04 (2GB RAM, 20GB disque)
- [ ] Mot de passe d'application Gmail
- [ ] IP de la VM notée : `_______________`

**Comment obtenir le mot de passe Gmail ?**
1. https://myaccount.google.com/security → Activer validation 2 étapes
2. https://myaccount.google.com/apppasswords → Générer (16 caractères)

---

## ⌨️ Commandes Essentielles

### État du Système
```bash
bash scripts/10-check-status.sh
```

### Voir les Logs
```bash
cd ~/apps/contact-service-springboot
docker compose logs -f app
# Ctrl+C pour quitter
```

### Redémarrer
```bash
docker compose restart
```

### Arrêter/Démarrer
```bash
docker compose down    # Arrêter
docker compose up -d   # Démarrer
```

### Sauvegarder
```bash
bash scripts/07-sauvegarder-db.sh
```

---

## 🌐 Accès

Une fois installé :

- **API** : http://localhost:8080/api/contact
- **Swagger** : http://localhost:8080/swagger-ui.html
- **Health** : http://localhost:8080/api/health

⚠️ Depuis la VM uniquement (pas depuis votre PC)

---

## 🐛 Problèmes Fréquents

| Problème | Solution |
|----------|----------|
| `git: command not found` | `sudo apt install git -y` |
| `Permission denied` | `chmod +x nom-script.sh` |
| `Docker not accessible` | Reconnectez-vous après install |
| Email non reçu | Vérifiez mot de passe Gmail (16 car.) |
| Port 8080 fermé | Normal ! Accessible que depuis la VM |

**Plus de solutions** : `cat scripts/FAQ.md | less`

---

## 📚 Documentation Complète

| Document | Contenu |
|----------|---------|
| `scripts/TUTORIEL-VIDEO.md` | Guide pas-à-pas (15 min) |
| `scripts/FAQ.md` | 28 questions/réponses |
| `scripts/CHECKLIST.md` | À imprimer et cocher |

**Ouvrir un document** :
```bash
cat scripts/NOM_FICHIER.md | less
# Flèches pour naviguer, 'q' pour quitter
```

---

## ✅ Validation Finale

Exécutez et vérifiez :

```bash
bash scripts/10-check-status.sh
```

Vous devez voir :
- ✅ Service Docker actif
- ✅ Conteneurs Running
- ✅ API accessible
- ✅ PostgreSQL opérationnel

---

## 🆘 Aide

**En cas de blocage** :
1. Vérifiez les logs : `docker compose logs app`
2. Consultez la FAQ : `cat scripts/FAQ.md | less`
3. Redémarrez : `docker compose restart`
4. Contactez le formateur

---

**Version 1.0.0** | Contact Service API | Spring Boot 3

