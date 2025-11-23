# Guide d'Evolutivite et Scalabilite

## Table des Matieres

1. [Introduction - Faire Evoluer le Systeme](#1-introduction-faire-evoluer-le-systeme)
2. [Modifications sans Interruption](#2-modifications-sans-interruption)
3. [Modifications Necessitant un Arret](#3-modifications-necessitant-un-arret)
4. [Evolution du Schema de Base de Donnees](#4-evolution-du-schema-de-base-de-donnees)
5. [Migration de Donnees](#5-migration-de-donnees)
6. [Scalabilite Horizontale et Verticale](#6-scalabilite-horizontale-et-verticale)
7. [Strategies de Mise a Jour](#7-strategies-de-mise-a-jour)
8. [Checklist de Migration](#8-checklist-de-migration)

---

## 1. Introduction - Faire Evoluer le Systeme

### Question Principale

**"Si je dois changer le schema de base de donnees, je dois tout supprimer ?"**

**Reponse : NON ! Il existe plusieurs strategies selon le type de modification.**

### Principe Fondamental

```
Ne JAMAIS supprimer les donnees sans sauvegarde !
```

### Types de Modifications

| Type | Impact | Necessite Arret | Perte de Donnees | Complexite |
|------|--------|-----------------|------------------|------------|
| **Ajouter un champ** | Faible | Non | Non | Facile |
| **Ajouter une table** | Faible | Non | Non | Facile |
| **Modifier un champ** | Moyen | Oui | Possible | Moyen |
| **Supprimer un champ** | Eleve | Oui | Oui (champ) | Moyen |
| **Refonte complete** | Tres eleve | Oui | Non (avec migration) | Difficile |

---

## 2. Modifications sans Interruption

### Cas 1 : Ajouter un Nouveau Champ (Colonne)

**Scenario** : Vous voulez ajouter un champ `ville` dans la table `contact_submissions`.

#### Etape 1 : Ajouter le Champ

```sql
-- Se connecter a PostgreSQL
docker exec -it contact-service-db psql -U postgres -d contact_service

-- Ajouter la nouvelle colonne
ALTER TABLE contact_submissions 
ADD COLUMN ville VARCHAR(100);

-- Verifier
\d contact_submissions
```

#### Etape 2 : Modifier le Code Backend (Optionnel)

Si vous voulez que l'application Java utilise ce nouveau champ :

```java
// src/main/java/com/contactservice/api/dto/ContactRequest.java
@Data
public class ContactRequest {
    // Champs existants
    private String formId;
    private String email;
    private String name;
    private String message;
    
    // NOUVEAU CHAMP
    @Size(max = 100)
    private String ville;
    
    // data reste flexible pour tout le reste
    private Map<String, Object> data;
}
```

#### Etape 3 : Rebuild et Redeploy

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2

# Rebuild l'application
sudo -u deploy docker compose down
sudo -u deploy docker compose up -d --build

# Attendre 30 secondes
sleep 30

# Verifier
curl http://localhost:8080/api/health
```

**Avantage** : Les anciens messages restent intacts, le nouveau champ sera `NULL` pour eux.

---

### Cas 2 : Ajouter une Nouvelle Table

**Scenario** : Vous voulez ajouter une table `contact_attachments` pour les pieces jointes.

#### Etape 1 : Creer la Table

```sql
-- Se connecter a PostgreSQL
docker exec -it contact-service-db psql -U postgres -d contact_service

-- Creer la nouvelle table
CREATE TABLE IF NOT EXISTS contact_attachments (
    id BIGSERIAL PRIMARY KEY,
    submission_id BIGINT NOT NULL REFERENCES contact_submissions(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    mimetype VARCHAR(100),
    filesize BIGINT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creer les index
CREATE INDEX IF NOT EXISTS idx_attachments_submission ON contact_attachments(submission_id);

-- Verifier
\dt
```

#### Etape 2 : Creer l'Entite Java

```java
// src/main/java/com/contactservice/api/entity/ContactAttachment.java
@Entity
@Table(name = "contact_attachments")
@Data
public class ContactAttachment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "submission_id", nullable = false)
    private Long submissionId;
    
    @Column(nullable = false)
    private String filename;
    
    @Column(nullable = false)
    private String filepath;
    
    private String mimetype;
    
    private Long filesize;
    
    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt;
}
```

#### Etape 3 : Rebuild

```bash
sudo -u deploy docker compose up -d --build
```

**Avantage** : Aucun impact sur les donnees existantes.

---

## 3. Modifications Necessitant un Arret

### Cas 3 : Modifier un Champ Existant

**Scenario** : Vous voulez augmenter la taille du champ `email` de 255 a 500 caracteres.

#### Etape 1 : Sauvegarder

```bash
# TOUJOURS sauvegarder avant une modification !
docker exec contact-service-db pg_dump -U postgres contact_service > backup_avant_modif_$(date +%Y%m%d_%H%M%S).sql
```

#### Etape 2 : Arreter l'Application

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy docker compose down
```

#### Etape 3 : Modifier le Schema

```bash
# Se connecter a PostgreSQL (meme si l'app est arretee, PostgreSQL tourne)
docker exec -it contact-service-db psql -U postgres -d contact_service

# Modifier le type de colonne
ALTER TABLE contact_submissions 
ALTER COLUMN email TYPE VARCHAR(500);

# Verifier
\d contact_submissions

# Quitter
\q
```

#### Etape 4 : Modifier le Code Java

```java
// src/main/java/com/contactservice/api/dto/ContactRequest.java
@Email
@Size(max = 500)  // Etait 255 avant
private String email;
```

#### Etape 5 : Rebuild et Redemarrer

```bash
sudo -u deploy docker compose up -d --build
```

**Important** : Les donnees existantes sont preservees !

---

### Cas 4 : Supprimer un Champ

**Scenario** : Vous voulez supprimer le champ `user_agent` (inutilise).

#### Etape 1 : Sauvegarder (CRITIQUE !)

```bash
docker exec contact-service-db pg_dump -U postgres contact_service > backup_avant_suppression_$(date +%Y%m%d_%H%M%S).sql
```

#### Etape 2 : Arreter l'Application

```bash
sudo -u deploy docker compose down
```

#### Etape 3 : Supprimer le Champ

```sql
-- Se connecter
docker exec -it contact-service-db psql -U postgres -d contact_service

-- Supprimer la colonne
ALTER TABLE contact_submissions 
DROP COLUMN user_agent;

-- Verifier
\d contact_submissions
```

#### Etape 4 : Modifier le Code

Supprimer toute reference a `user_agent` dans le code Java.

#### Etape 5 : Rebuild

```bash
sudo -u deploy docker compose up -d --build
```

**Attention** : Les donnees dans ce champ sont PERDUES !

---

## 4. Evolution du Schema de Base de Donnees

### Strategy 1 : Migration Incrementale (RECOMMANDE)

**Principe** : Ajouter des tables/champs sans toucher a l'existant.

#### Exemple : Passer de 1 Table a 5 Tables

**Etape 1 : Garder la Table Actuelle**

```sql
-- contact_submissions RESTE INTACTE
-- Ne pas la modifier !
```

**Etape 2 : Ajouter les Nouvelles Tables**

```sql
-- Nouvelle table pour les pieces jointes
CREATE TABLE contact_attachments (...);

-- Nouvelle table pour les reponses
CREATE TABLE contact_responses (...);

-- Nouvelle table pour les categories
CREATE TABLE contact_categories (...);

-- Nouvelle table pour les utilisateurs
CREATE TABLE users (...);
```

**Etape 3 : Ajouter les Cles Etrangeres (Optionnel)**

```sql
-- Ajouter category_id a contact_submissions
ALTER TABLE contact_submissions 
ADD COLUMN category_id BIGINT REFERENCES contact_categories(id);

-- Ajouter user_id a contact_submissions
ALTER TABLE contact_submissions 
ADD COLUMN user_id BIGINT REFERENCES users(id);
```

**Avantage** : 
- ✅ Pas de perte de donnees
- ✅ Retour en arriere facile
- ✅ Migration progressive

---

### Strategy 2 : Migration avec Copie (Pour Refonte Majeure)

**Scenario** : Vous voulez completement reorganiser la structure.

#### Etape 1 : Creer les Nouvelles Tables

```sql
-- Nouvelles tables avec la nouvelle structure
CREATE TABLE contact_submissions_v2 (...);
CREATE TABLE contact_categories_v2 (...);
-- etc.
```

#### Etape 2 : Copier les Donnees

```sql
-- Copier les donnees de l'ancienne vers la nouvelle table
INSERT INTO contact_submissions_v2 (id, nom, email, ...)
SELECT id, nom, email, ...
FROM contact_submissions;
```

#### Etape 3 : Valider

```sql
-- Compter les lignes
SELECT COUNT(*) FROM contact_submissions;    -- Exemple: 1000
SELECT COUNT(*) FROM contact_submissions_v2; -- Doit etre: 1000

-- Comparer quelques lignes
SELECT * FROM contact_submissions WHERE id = 1;
SELECT * FROM contact_submissions_v2 WHERE id = 1;
```

#### Etape 4 : Basculer

```sql
-- Renommer l'ancienne table (backup)
ALTER TABLE contact_submissions RENAME TO contact_submissions_old;

-- Renommer la nouvelle table
ALTER TABLE contact_submissions_v2 RENAME TO contact_submissions;
```

#### Etape 5 : Tester

```bash
# Redemarrer l'application
sudo -u deploy docker compose restart

# Tester
curl http://localhost:8080/api/health
```

#### Etape 6 : Supprimer l'Ancienne (Apres Validation Complete)

```sql
-- SEULEMENT apres avoir valide que tout fonctionne pendant plusieurs jours
DROP TABLE contact_submissions_old;
```

---

## 5. Migration de Donnees

### Script de Migration Complet

```bash
#!/bin/bash
# migration.sh - Script de migration avec sauvegarde

echo "=== Migration de la Base de Donnees ==="
echo ""

# 1. Sauvegarde automatique
echo "[1/5] Sauvegarde de la base de donnees..."
BACKUP_FILE="backup_avant_migration_$(date +%Y%m%d_%H%M%S).sql"
docker exec contact-service-db pg_dump -U postgres contact_service > "$BACKUP_FILE"
echo "Sauvegarde creee : $BACKUP_FILE"
echo ""

# 2. Arreter l'application
echo "[2/5] Arret de l'application..."
docker compose down
echo ""

# 3. Executer le script de migration
echo "[3/5] Execution du script de migration..."
docker exec -i contact-service-db psql -U postgres -d contact_service < migration.sql
echo ""

# 4. Redemarrer l'application
echo "[4/5] Redemarrage de l'application..."
docker compose up -d --build
sleep 30
echo ""

# 5. Verifier
echo "[5/5] Verification..."
curl -s http://localhost:8080/api/health | jq .
echo ""

echo "=== Migration terminee ==="
echo "Backup disponible : $BACKUP_FILE"
```

### Fichier migration.sql

```sql
-- migration.sql
-- Migration de la base de donnees

BEGIN;

-- Ajouter de nouvelles colonnes
ALTER TABLE contact_submissions ADD COLUMN IF NOT EXISTS ville VARCHAR(100);
ALTER TABLE contact_submissions ADD COLUMN IF NOT EXISTS code_postal VARCHAR(20);

-- Creer de nouvelles tables
CREATE TABLE IF NOT EXISTS contact_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(20)
);

-- Inserer des donnees initiales
INSERT INTO contact_categories (name, description, color)
VALUES 
    ('General', 'Contact general', '#3B82F6'),
    ('Support', 'Support technique', '#EF4444'),
    ('Commercial', 'Questions commerciales', '#10B981')
ON CONFLICT (name) DO NOTHING;

-- Ajouter la relation
ALTER TABLE contact_submissions 
ADD COLUMN IF NOT EXISTS category_id BIGINT REFERENCES contact_categories(id);

-- Mettre a jour les donnees existantes
UPDATE contact_submissions 
SET category_id = (SELECT id FROM contact_categories WHERE name = 'General')
WHERE category_id IS NULL;

COMMIT;

-- Verifier
SELECT COUNT(*) as total_messages FROM contact_submissions;
SELECT COUNT(*) as total_categories FROM contact_categories;
```

### Executer la Migration

```bash
# Rendre le script executable
chmod +x migration.sh

# Executer
./migration.sh
```

---

## 6. Scalabilite Horizontale et Verticale

### Scalabilite Verticale (Augmenter les Ressources)

**Scenario** : L'application est lente, vous voulez plus de ressources.

#### Option 1 : Augmenter la RAM Docker

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:15-alpine
    deploy:
      resources:
        limits:
          memory: 2G      # Etait 512M
          cpus: '2.0'     # Etait 1.0
        reservations:
          memory: 1G
          cpus: '1.0'
  
  app:
    build: .
    deploy:
      resources:
        limits:
          memory: 1G      # Etait 512M
          cpus: '1.0'
        reservations:
          memory: 512M
```

```bash
# Redemarrer avec la nouvelle config
docker compose down
docker compose up -d
```

#### Option 2 : Augmenter les Connexions PostgreSQL

```sql
-- Se connecter a PostgreSQL
docker exec -it contact-service-db psql -U postgres

-- Voir la config actuelle
SHOW max_connections;  -- Par defaut: 100

-- Modifier (necessite redemarrage)
ALTER SYSTEM SET max_connections = 200;

-- Quitter et redemarrer
\q
```

```bash
docker compose restart postgres
```

---

### Scalabilite Horizontale (Plusieurs Instances)

**Scenario** : Vous voulez plusieurs instances de l'application.

#### Architecture avec Load Balancer

```
                    ┌──────────────┐
                    │ Load Balancer│
                    │   (Nginx)    │
                    └──────┬───────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  App        │   │  App        │   │  App        │
│  Instance 1 │   │  Instance 2 │   │  Instance 3 │
│  :8080      │   │  :8081      │   │  :8082      │
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                 │
       └─────────────────┼─────────────────┘
                         │
                         ▼
                 ┌───────────────┐
                 │  PostgreSQL   │
                 │   (Unique)    │
                 └───────────────┘
```

#### docker-compose.yml pour 3 Instances

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: contact-service-db
    # ... (config inchangee)
  
  app1:
    build: .
    container_name: contact-service-app-1
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      # ... autres variables
  
  app2:
    build: .
    container_name: contact-service-app-2
    ports:
      - "8081:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      # ... autres variables
  
  app3:
    build: .
    container_name: contact-service-app-3
    ports:
      - "8082:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      # ... autres variables
```

---

## 7. Strategies de Mise a Jour

### Strategy 1 : Mise a Jour Simple (Petite Modification)

**Pour** : Correction de bug, ajout de fonctionnalite mineure

```bash
# 1. Sauvegarder la base de donnees
docker exec contact-service-db pg_dump -U postgres contact_service > backup.sql

# 2. Pull les modifications
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy git pull origin main

# 3. Rebuild et redemarrer
sudo -u deploy docker compose up -d --build

# 4. Verifier
sleep 30
curl http://localhost:8080/api/health
```

**Downtime** : ~30 secondes

---

### Strategy 2 : Blue-Green Deployment (Zero Downtime)

**Pour** : Mise a jour majeure sans interruption

#### Etape 1 : Preparer l'Environnement "Green"

```bash
# Cloner l'application dans un nouveau dossier
cd /home/deploy/apps
sudo -u deploy git clone https://github.com/USER/REPO.git contact-service-green
cd contact-service-green
```

#### Etape 2 : Configurer sur un Port Differentiel

```yaml
# docker-compose.yml de "green"
services:
  app:
    ports:
      - "8081:8080"  # Port different !
```

#### Etape 3 : Demarrer "Green"

```bash
sudo -u deploy docker compose up -d --build
sleep 30
curl http://localhost:8081/api/health  # Tester sur le nouveau port
```

#### Etape 4 : Basculer le Traffic (Nginx)

```nginx
# /etc/nginx/sites-available/contact-service
upstream contact_service {
    # server localhost:8080;  # Blue (ancien)
    server localhost:8081;    # Green (nouveau)
}
```

```bash
sudo nginx -t
sudo systemctl reload nginx
```

#### Etape 5 : Arreter "Blue" (Ancien)

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy docker compose down
```

**Downtime** : 0 seconde !

---

### Strategy 3 : Rolling Update (Mise a Jour Progressive)

**Pour** : Systeme avec plusieurs instances

```bash
# Mettre a jour instance par instance
# Instance 1
docker compose stop app1
docker compose up -d app1 --build
sleep 30

# Instance 2
docker compose stop app2
docker compose up -d app2 --build
sleep 30

# Instance 3
docker compose stop app3
docker compose up -d app3 --build
```

**Avantage** : Le service reste toujours disponible.

---

## 8. Checklist de Migration

### Avant la Migration

- [ ] **Sauvegarder la base de donnees**
  ```bash
  docker exec contact-service-db pg_dump -U postgres contact_service > backup.sql
  ```

- [ ] **Tester sur un environnement de dev**
  ```bash
  # Restaurer le backup sur une VM de test
  # Executer la migration
  # Valider que tout fonctionne
  ```

- [ ] **Documenter les changements**
  ```
  - Que modifie-t-on ?
  - Pourquoi ?
  - Comment revenir en arriere ?
  ```

- [ ] **Planifier une fenetre de maintenance**
  ```
  - Prevenir les utilisateurs
  - Choisir un moment avec peu de traffic
  ```

### Pendant la Migration

- [ ] **Mettre le site en maintenance** (optionnel)
  ```html
  <!-- maintenance.html -->
  <h1>Maintenance en cours</h1>
  <p>Retour prevu dans 30 minutes</p>
  ```

- [ ] **Executer la migration**
  ```bash
  ./migration.sh
  ```

- [ ] **Verifier les logs**
  ```bash
  docker compose logs -f app
  ```

- [ ] **Tester les endpoints critiques**
  ```bash
  curl http://localhost:8080/api/health
  curl -X POST http://localhost:8080/api/contact -d '{...}'
  ```

### Apres la Migration

- [ ] **Verifier les donnees**
  ```sql
  SELECT COUNT(*) FROM contact_submissions;
  SELECT * FROM contact_submissions ORDER BY id DESC LIMIT 5;
  ```

- [ ] **Surveiller les performances**
  ```bash
  docker stats
  ```

- [ ] **Garder le backup pendant 7 jours minimum**

- [ ] **Documenter ce qui a ete fait**

---

## 9. Plan de Retour en Arriere (Rollback)

### Si la Migration Echoue

#### Etape 1 : Arreter l'Application

```bash
docker compose down
```

#### Etape 2 : Restaurer le Backup

```bash
# Supprimer la base actuelle (corrompue)
docker exec -it contact-service-db psql -U postgres -c "DROP DATABASE contact_service;"

# Recreer la base
docker exec -it contact-service-db psql -U postgres -c "CREATE DATABASE contact_service;"

# Restaurer le backup
docker exec -i contact-service-db psql -U postgres -d contact_service < backup.sql
```

#### Etape 3 : Revenir au Code Precedent

```bash
cd /home/deploy/apps/microservice-contact-service-spring-boot-2
sudo -u deploy git checkout HEAD~1  # Revenir au commit precedent
```

#### Etape 4 : Redemarrer

```bash
sudo -u deploy docker compose up -d
sleep 30
curl http://localhost:8080/api/health
```

---

## 10. Recapitulatif

### Regles d'Or

1. ✅ **TOUJOURS sauvegarder avant une modification**
2. ✅ **Tester sur un environnement de dev d'abord**
3. ✅ **Preferer les ajouts aux suppressions**
4. ✅ **Documenter chaque changement**
5. ✅ **Avoir un plan de rollback**

### Type de Modification vs Action

| Modification | Sauvegarde | Arret App | Rebuild | Risque |
|--------------|-----------|-----------|---------|--------|
| Ajouter champ | Recommande | Non | Non | Faible |
| Ajouter table | Recommande | Non | Oui | Faible |
| Modifier champ | **OBLIGATOIRE** | Oui | Oui | Moyen |
| Supprimer champ | **OBLIGATOIRE** | Oui | Oui | Eleve |
| Refonte schema | **OBLIGATOIRE** | Oui | Oui | Tres eleve |

### Architecture Evolutive

```
Version 1.0 (1 table)
    ↓ Migration incrementale
Version 2.0 (2 tables)
    ↓ Migration incrementale
Version 3.0 (5 tables)
    ↓ ...
```

**Avantage** : Evolution progressive sans perte de donnees.

---

Votre systeme est maintenant pret a evoluer ! 🚀

