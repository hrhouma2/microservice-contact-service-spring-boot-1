# ❓ FAQ - Questions Fréquentes

## Questions fréquentes des étudiants lors de l'installation

---

## 🔐 Questions sur la Configuration

### Q1 : Qu'est-ce qu'un "mot de passe d'application" Gmail ?

**R :** C'est un mot de passe spécial de 16 caractères généré par Google pour permettre à des applications tierces d'envoyer des emails via votre compte Gmail.

**Comment l'obtenir ?**
1. Activez la validation en 2 étapes : https://myaccount.google.com/security
2. Générez un mot de passe d'application : https://myaccount.google.com/apppasswords
3. Sélectionnez "Autre" et nommez-le "Contact Service"
4. Copiez le mot de passe de 16 caractères (format : `abcd efgh ijkl mnop`)

---

### Q2 : Je ne peux pas activer la validation en 2 étapes sur Gmail

**R :** Vous avez plusieurs options :

**Option 1 : Utiliser un autre service d'email** (recommandé)
- Mailtrap.io (gratuit pour les tests)
- SendGrid (gratuit jusqu'à 100 emails/jour)
- Mailgun (gratuit jusqu'à 5000 emails/mois)

**Option 2 : Créer un nouveau compte Gmail**
- Créez un compte Gmail spécifiquement pour ce projet
- Activez la validation en 2 étapes sur ce nouveau compte

---

### Q3 : Où trouver l'IP de ma VM ?

**R :** Plusieurs méthodes :

**Méthode 1 : Depuis votre hébergeur**
- Le tableau de bord de votre hébergeur (OVH, AWS, DigitalOcean, etc.) affiche l'IP publique

**Méthode 2 : Depuis la VM (si vous y avez accès)**
```bash
ip addr show
# OU
curl ifconfig.me
```

**Format** : L'IP ressemble à `192.168.1.100` (réseau local) ou `45.123.45.67` (IP publique)

---

### Q4 : C'est quoi CORS et que mettre dans CORS_ALLOWED_ORIGINS ?

**R :** CORS (Cross-Origin Resource Sharing) contrôle quels sites web peuvent utiliser votre API.

**Pour les tests en local** :
```
http://localhost:3000,http://localhost:4321,http://localhost:8080
```

**Pour un site en production** :
```
https://monsite.com,https://www.monsite.com
```

**Pour autoriser tout le monde (NON RECOMMANDÉ en production)** :
```
*
```

---

## 🐛 Problèmes d'Installation

### Q5 : "bash: git: command not found"

**R :** Git n'est pas installé. Installez-le :
```bash
sudo apt update
sudo apt install git -y
```

---

### Q6 : "Permission denied" lors de l'exécution d'un script

**R :** Le script n'est pas exécutable. Deux solutions :

**Solution 1 : Rendre exécutable**
```bash
chmod +x nom-du-script.sh
bash nom-du-script.sh
```

**Solution 2 : Exécuter directement avec bash**
```bash
bash nom-du-script.sh
```

---

### Q7 : "You must be root to perform this command"

**R :** Le script nécessite les droits administrateur :
```bash
sudo bash nom-du-script.sh
```

---

### Q8 : L'installation s'arrête avec "Error: Cannot connect to Docker daemon"

**R :** Le service Docker n'est pas démarré :
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Puis relancez votre script.

---

### Q9 : "Port 8080 already in use"

**R :** Un autre service utilise le port 8080. Plusieurs solutions :

**Solution 1 : Trouver et arrêter le service**
```bash
sudo lsof -i :8080
# Notez le PID
sudo kill -9 PID
```

**Solution 2 : Changer le port dans docker-compose.yml**
```yaml
ports:
  - "8081:8080"  # Au lieu de 8080:8080
```

---

## 📧 Problèmes d'Email

### Q10 : "Failed to send email" dans les logs

**R :** Plusieurs causes possibles :

**Cause 1 : Mauvais mot de passe d'application**
- Vérifiez que vous avez copié le bon mot de passe (16 caractères)
- Pas d'espaces avant/après

**Cause 2 : Validation en 2 étapes non activée**
- Vérifiez sur https://myaccount.google.com/security

**Cause 3 : Email Gmail incorrect**
- Vérifiez l'email dans le fichier `.env`

**Comment corriger** :
```bash
cd ~/apps/contact-service-springboot
nano .env
# Corrigez les valeurs SMTP_USER et SMTP_PASS
# Ctrl+X, Y, Entrée pour sauvegarder

docker compose restart
```

---

### Q11 : Je ne reçois pas l'email de notification

**R :** Vérifiez dans cet ordre :

1. **Vérifier les logs** :
```bash
docker compose logs app | grep -i email
```

2. **Vérifier le dossier Spam/Indésirables**

3. **Tester l'envoi manuellement** :
```bash
docker exec -it contact-service-app bash
# Dans le conteneur, vérifier la config SMTP
env | grep SMTP
```

4. **Vérifier que CONTACT_NOTIFICATION_EMAIL est correct** :
```bash
cat ~/apps/contact-service-springboot/.env | grep NOTIFICATION
```

---

## 🌐 Problèmes de Connexion

### Q12 : Je ne peux pas accéder à http://IP_VM:8080

**R :** C'est **NORMAL** et **VOULU** pour la sécurité !

Le port 8080 n'est accessible que **depuis la VM elle-même**.

**Solutions** :

**Solution 1 : Tester depuis la VM (recommandé)**
```bash
curl http://localhost:8080/api/health
```

**Solution 2 : Utiliser Nginx comme reverse proxy**
- Exécutez le script `05-installer-nginx.sh`
- Configurez un nom de domaine
- L'API sera accessible via HTTP/HTTPS sur port 80/443

**Solution 3 : Ouvrir le port 8080 (NON RECOMMANDÉ)**
```bash
sudo ufw allow 8080/tcp
```
⚠️ Cela expose votre API sans protection !

---

### Q13 : "Connection refused" lors du test avec curl

**R :** L'application n'est pas démarrée ou a crashé.

**Vérifications** :
```bash
# 1. Vérifier que les conteneurs tournent
docker compose ps

# 2. Vérifier les logs
docker compose logs app

# 3. Redémarrer si nécessaire
docker compose restart
```

---

### Q14 : Swagger ne s'affiche pas

**R :** Attendez 1-2 minutes que l'application démarre complètement, puis :

**Vérification** :
```bash
curl http://localhost:8080/api/health
```

Si ça retourne du JSON, Swagger devrait fonctionner : `http://localhost:8080/swagger-ui.html`

Si ça ne marche toujours pas :
```bash
docker compose logs app | grep -i swagger
```

---

## 💾 Problèmes de Base de Données

### Q15 : "Connection to database failed"

**R :** PostgreSQL n'est pas démarré ou pas prêt.

**Vérifications** :
```bash
# 1. Vérifier que PostgreSQL tourne
docker compose ps postgres

# 2. Vérifier les logs PostgreSQL
docker compose logs postgres

# 3. Redémarrer PostgreSQL
docker compose restart postgres

# 4. Attendre 10 secondes puis redémarrer l'app
sleep 10
docker compose restart app
```

---

### Q16 : Comment voir les données dans la base ?

**R :** Connectez-vous à PostgreSQL :

```bash
docker exec -it contact-service-db psql -U postgres -d contact_service
```

**Commandes SQL utiles** :
```sql
-- Voir toutes les soumissions
SELECT * FROM form_submissions ORDER BY created_at DESC LIMIT 10;

-- Compter les soumissions
SELECT COUNT(*) FROM form_submissions;

-- Rechercher par email
SELECT * FROM form_submissions WHERE email = 'test@example.com';

-- Quitter
\q
```

---

## 🔧 Questions Techniques

### Q17 : Comment arrêter l'application ?

```bash
cd ~/apps/contact-service-springboot
docker compose down
```

---

### Q18 : Comment redémarrer après un redémarrage de la VM ?

**R :** Docker démarre automatiquement l'application au boot !

Si ce n'est pas le cas :
```bash
cd ~/apps/contact-service-springboot
docker compose up -d
```

---

### Q19 : Comment voir les logs en temps réel ?

```bash
cd ~/apps/contact-service-springboot
docker compose logs -f app
```

Appuyez sur `Ctrl+C` pour arrêter l'affichage.

---

### Q20 : Comment sauvegarder mes données ?

**R :** Utilisez le script fourni :
```bash
bash ~/scripts/07-sauvegarder-db.sh
```

Les sauvegardes sont dans `~/apps/backups/`

---

### Q21 : Comment mettre à jour l'application après avoir modifié le code ?

```bash
cd ~/apps/contact-service-springboot
git pull
docker compose down
docker compose up -d --build
```

---

### Q22 : Où sont stockées les données ?

**R :** Les données sont dans un **volume Docker** qui persiste même si vous supprimez les conteneurs.

**Localisation** :
```bash
docker volume ls | grep postgres
```

**Pour voir l'emplacement physique** :
```bash
docker volume inspect contact-service-springboot_postgres_data
```

---

## 🚀 Questions sur l'Utilisation

### Q23 : Comment intégrer cette API dans mon site web ?

**R :** Exemple avec JavaScript :

```javascript
// Dans votre formulaire HTML
async function envoyerFormulaire(event) {
  event.preventDefault();
  
  const data = {
    formId: "mon-formulaire-contact",
    email: document.getElementById('email').value,
    name: document.getElementById('name').value,
    message: document.getElementById('message').value
  };
  
  const response = await fetch('http://VOTRE_IP:8080/api/contact', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
  
  const result = await response.json();
  
  if (result.ok) {
    alert('Message envoyé avec succès !');
  } else {
    alert('Erreur : ' + result.message);
  }
}
```

---

### Q24 : Est-ce que cette API est sécurisée ?

**R :** **Oui** pour un usage de base, mais il faut :

✅ **Sécurités incluses** :
- Firewall UFW configuré
- Port 8080 non exposé publiquement
- Validation des données
- Protection CORS

⚠️ **À ajouter pour la production** :
- HTTPS avec SSL (Let's Encrypt)
- Rate limiting (protection anti-spam)
- Authentification API (API key ou JWT)
- Monitoring et alertes

---

### Q25 : Combien de requêtes l'API peut-elle gérer ?

**R :** Dépend de votre VM :

**VM de base (2GB RAM, 2 vCPUs)** :
- ~100 requêtes/seconde
- ~10 000 soumissions/jour

**VM moyenne (4GB RAM, 4 vCPUs)** :
- ~500 requêtes/seconde
- ~50 000 soumissions/jour

Pour plus, ajoutez un reverse proxy (Nginx) et du load balancing.

---

## 📚 Ressources Supplémentaires

### Q26 : Où trouver plus de documentation ?

- **Guide débutant** : `scripts/GUIDE-INSTALLATION-DEBUTANTS.md`
- **Tutoriel vidéo** : `scripts/TUTORIEL-VIDEO.md`
- **Cahier des charges** : `documentation/00-cahier-des-charges.md`
- **Swagger** : `http://localhost:8080/swagger-ui.html`

---

### Q27 : Je veux désinstaller complètement

```bash
bash ~/scripts/10-desinstaller.sh
```

⚠️ **ATTENTION** : Cela supprime TOUT (application + base de données) !

Faites une sauvegarde avant :
```bash
bash ~/scripts/07-sauvegarder-db.sh
```

---

## 🆘 Aide Supplémentaire

### Q28 : Mon problème n'est pas dans la FAQ

**Étapes de dépannage** :

1. **Vérifier les logs** :
```bash
docker compose logs app
docker compose logs postgres
```

2. **Vérifier le statut** :
```bash
docker compose ps
docker --version
systemctl status docker
```

3. **Redémarrer tout** :
```bash
docker compose down
docker compose up -d
```

4. **Vérifier la configuration** :
```bash
cat ~/apps/contact-service-springboot/.env
```

5. **Contacter votre formateur avec** :
   - Le message d'erreur exact
   - Les logs (`docker compose logs app`)
   - Votre système (`uname -a`)

---

**Dernière mise à jour** : Novembre 2025  
**Version** : 1.0.0

