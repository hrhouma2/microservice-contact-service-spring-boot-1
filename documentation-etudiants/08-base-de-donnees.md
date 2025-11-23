# Guide de la Base de Donnees PostgreSQL

## Table des Matieres

1. [Acces a la Base de Donnees](#1-acces-a-la-base-de-donnees)
2. [Commandes PostgreSQL Essentielles](#2-commandes-postgresql-essentielles)
3. [Consultation des Donnees](#3-consultation-des-donnees)
4. [Modification des Donnees](#4-modification-des-donnees)
5. [Gestion et Maintenance](#5-gestion-et-maintenance)
6. [Sauvegarde et Restauration](#6-sauvegarde-et-restauration)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Acces a la Base de Donnees

### A. Verification que PostgreSQL fonctionne

```bash
# Verifier que le conteneur PostgreSQL tourne
docker ps | grep postgres

# Vous devriez voir :
# contact-service-db    postgres:15-alpine    (healthy)
```

### B. Methode 1 : Acces Direct avec psql (RECOMMANDE)

```bash
# Se connecter a PostgreSQL en tant qu'utilisateur postgres
docker exec -it contact-service-db psql -U postgres -d contact_service
```

**IMPORTANT** : Utilisez `-U postgres` pour specifier l'utilisateur !

**Vous verrez** :
```
psql (15.x)
Type "help" for help.

contact_service=#
```

### C. Methode 2 : Acces via bash puis psql

```bash
# Entrer dans le conteneur
docker exec -it contact-service-db bash

# Une fois dans le conteneur, se connecter a psql
psql -U postgres -d contact_service
```

### D. Erreur Commune et Solution

**ERREUR** :
```
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: 
FATAL:  role "root" does not exist
```

**CAUSE** : Vous avez tape `psql` sans specifier l'utilisateur. Par defaut, psql essaie de se connecter avec l'utilisateur actuel (`root`), mais cet utilisateur n'existe pas dans PostgreSQL.

**SOLUTION** : Toujours specifier `-U postgres` :
```bash
# CORRECT
psql -U postgres -d contact_service

# Ou directement depuis l'hote
docker exec -it contact-service-db psql -U postgres -d contact_service
```

---

## 2. Commandes PostgreSQL Essentielles

### A. Une fois connecte a psql

```sql
-- Lister toutes les bases de donnees
\l

-- Se connecter a une base de donnees
\c contact_service

-- Lister toutes les tables
\dt

-- Decrire la structure d'une table
\d contact_submissions

-- Lister les index
\di

-- Lister les fonctions
\df

-- Quitter psql
\q
```

### B. Commandes de Navigation

| Commande | Description | Exemple |
|----------|-------------|---------|
| `\l` | Lister les bases de donnees | `\l` |
| `\c nom_db` | Se connecter a une base | `\c contact_service` |
| `\dt` | Lister les tables | `\dt` |
| `\d table` | Decrire une table | `\d contact_submissions` |
| `\du` | Lister les utilisateurs | `\du` |
| `\di` | Lister les index | `\di` |
| `\df` | Lister les fonctions | `\df` |
| `\?` | Aide sur les commandes | `\?` |
| `\h` | Aide SQL | `\h SELECT` |
| `\q` | Quitter | `\q` |

---

## 3. Consultation des Donnees

### A. Voir Toutes les Soumissions

```sql
-- Voir tous les messages
SELECT * FROM contact_submissions;

-- Voir uniquement certains champs
SELECT id, nom, email, sujet, date_soumission 
FROM contact_submissions;

-- Voir les 10 dernieres soumissions
SELECT id, nom, email, sujet, date_soumission 
FROM contact_submissions 
ORDER BY date_soumission DESC 
LIMIT 10;
```

### B. Rechercher des Donnees

```sql
-- Trouver par email
SELECT * FROM contact_submissions 
WHERE email = 'test@example.com';

-- Trouver par nom (recherche partielle)
SELECT * FROM contact_submissions 
WHERE nom LIKE '%Dupont%';

-- Messages non lus
SELECT * FROM contact_submissions 
WHERE lu = false;

-- Messages d'aujourd'hui
SELECT * FROM contact_submissions 
WHERE date_soumission::date = CURRENT_DATE;

-- Messages de cette semaine
SELECT * FROM contact_submissions 
WHERE date_soumission >= CURRENT_DATE - INTERVAL '7 days';
```

### C. Statistiques

```sql
-- Compter le nombre total de messages
SELECT COUNT(*) FROM contact_submissions;

-- Compter les messages par statut
SELECT statut, COUNT(*) as nombre 
FROM contact_submissions 
GROUP BY statut;

-- Messages par jour
SELECT date_soumission::date as jour, COUNT(*) as nombre 
FROM contact_submissions 
GROUP BY jour 
ORDER BY jour DESC;

-- Top 10 des emails les plus frequents
SELECT email, COUNT(*) as nombre 
FROM contact_submissions 
GROUP BY email 
ORDER BY nombre DESC 
LIMIT 10;
```

### D. Affichage Formate

```sql
-- Affichage compact
\x off
SELECT id, nom, email FROM contact_submissions LIMIT 5;

-- Affichage etendu (vertical)
\x on
SELECT * FROM contact_submissions LIMIT 1;

-- Retour a l'affichage normal
\x auto
```

---

## 4. Modification des Donnees

### A. Marquer un Message comme Lu

```sql
-- Marquer le message ID 1 comme lu
UPDATE contact_submissions 
SET lu = true, 
    date_lecture = NOW() 
WHERE id = 1;

-- Verifier
SELECT id, nom, lu, date_lecture 
FROM contact_submissions 
WHERE id = 1;
```

### B. Changer le Statut

```sql
-- Changer le statut d'un message
UPDATE contact_submissions 
SET statut = 'TRAITE' 
WHERE id = 1;

-- Marquer plusieurs messages comme traites
UPDATE contact_submissions 
SET statut = 'TRAITE', 
    lu = true 
WHERE id IN (1, 2, 3);
```

### C. Ajouter des Notes Admin

```sql
-- Ajouter une note administrative
UPDATE contact_submissions 
SET notes_admin = 'Client contacte par telephone le 23/11/2025' 
WHERE id = 1;
```

### D. Supprimer des Donnees

```sql
-- Supprimer un message specifique
DELETE FROM contact_submissions 
WHERE id = 1;

-- Supprimer les messages de test
DELETE FROM contact_submissions 
WHERE email LIKE '%test%';

-- ATTENTION : Supprimer TOUTES les donnees (irreversible !)
DELETE FROM contact_submissions;

-- Supprimer et reinitialiser l'auto-increment
TRUNCATE TABLE contact_submissions RESTART IDENTITY;
```

---

## 5. Gestion et Maintenance

### A. Informations sur la Table

```sql
-- Voir la structure complete de la table
\d+ contact_submissions

-- Nombre de lignes
SELECT COUNT(*) FROM contact_submissions;

-- Taille de la table
SELECT 
    pg_size_pretty(pg_total_relation_size('contact_submissions')) as taille_totale,
    pg_size_pretty(pg_relation_size('contact_submissions')) as taille_table,
    pg_size_pretty(pg_indexes_size('contact_submissions')) as taille_index;

-- Voir les index
SELECT 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE tablename = 'contact_submissions';
```

### B. Verifier l'Integrite

```sql
-- Verifier les doublons d'email
SELECT email, COUNT(*) as nombre 
FROM contact_submissions 
GROUP BY email 
HAVING COUNT(*) > 1;

-- Verifier les valeurs nulles
SELECT COUNT(*) as messages_sans_nom 
FROM contact_submissions 
WHERE nom IS NULL OR nom = '';

SELECT COUNT(*) as messages_sans_message 
FROM contact_submissions 
WHERE message IS NULL OR message = '';
```

### C. Performance et Optimisation

```sql
-- Analyser la table pour optimiser les requetes
ANALYZE contact_submissions;

-- Nettoyer et analyser
VACUUM ANALYZE contact_submissions;

-- Voir les statistiques d'utilisation
SELECT 
    schemaname,
    tablename,
    n_tup_ins as insertions,
    n_tup_upd as mises_a_jour,
    n_tup_del as suppressions,
    n_live_tup as lignes_actives,
    n_dead_tup as lignes_mortes
FROM pg_stat_user_tables 
WHERE tablename = 'contact_submissions';
```

---

## 6. Sauvegarde et Restauration

### A. Sauvegarder la Base de Donnees

```bash
# Depuis l'hote (en dehors du conteneur)

# Sauvegarde complete
docker exec contact-service-db pg_dump -U postgres contact_service > backup_$(date +%Y%m%d_%H%M%S).sql

# Sauvegarde compresse
docker exec contact-service-db pg_dump -U postgres contact_service | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Sauvegarde seulement les donnees (pas la structure)
docker exec contact-service-db pg_dump -U postgres --data-only contact_service > backup_data_$(date +%Y%m%d_%H%M%S).sql
```

### B. Restaurer la Base de Donnees

```bash
# Restaurer depuis un fichier SQL
docker exec -i contact-service-db psql -U postgres -d contact_service < backup_20251123_103000.sql

# Restaurer depuis un fichier compresse
gunzip -c backup_20251123_103000.sql.gz | docker exec -i contact-service-db psql -U postgres -d contact_service

# Restaurer seulement une table
docker exec -i contact-service-db psql -U postgres -d contact_service -c "TRUNCATE TABLE contact_submissions;"
docker exec -i contact-service-db psql -U postgres -d contact_service < backup_table.sql
```

### C. Export en CSV

```bash
# Depuis psql
\copy (SELECT * FROM contact_submissions) TO '/tmp/export.csv' WITH CSV HEADER;

# Depuis l'hote
docker exec contact-service-db psql -U postgres -d contact_service -c "\COPY contact_submissions TO STDOUT WITH CSV HEADER" > export.csv
```

### D. Import depuis CSV

```sql
-- Depuis psql
\copy contact_submissions FROM '/tmp/import.csv' WITH CSV HEADER;

-- Ou avec COPY (necessite des privileges)
COPY contact_submissions FROM '/tmp/import.csv' WITH CSV HEADER;
```

---

## 7. Troubleshooting

### Probleme 1 : "role root does not exist"

**Erreur** :
```
psql: error: FATAL: role "root" does not exist
```

**Solution** :
```bash
# MAUVAIS
docker exec -it contact-service-db bash
psql

# CORRECT
docker exec -it contact-service-db bash
psql -U postgres -d contact_service

# Ou directement
docker exec -it contact-service-db psql -U postgres -d contact_service
```

---

### Probleme 2 : "database does not exist"

**Erreur** :
```
psql: error: FATAL: database "xxx" does not exist
```

**Solution** :
```bash
# Lister les bases disponibles
docker exec -it contact-service-db psql -U postgres -l

# Se connecter a la bonne base
docker exec -it contact-service-db psql -U postgres -d contact_service
```

---

### Probleme 3 : Table vide ou donnees manquantes

**Verification** :
```bash
# Verifier que l'application a bien demarre
docker compose logs app | grep "Started"

# Verifier les logs PostgreSQL
docker compose logs postgres

# Verifier la table
docker exec -it contact-service-db psql -U postgres -d contact_service -c "SELECT COUNT(*) FROM contact_submissions;"
```

**Solution** :
```bash
# Si la table n'existe pas, verifier init.sql
docker exec contact-service-db cat /docker-entrypoint-initdb.d/init.sql

# Recreer la table manuellement
docker exec -it contact-service-db psql -U postgres -d contact_service

# Puis executer le script init.sql
\i /docker-entrypoint-initdb.d/init.sql
```

---

### Probleme 4 : Connexion refusee

**Erreur** :
```
could not connect to server: Connection refused
```

**Solution** :
```bash
# Verifier que PostgreSQL tourne
docker ps | grep postgres

# Verifier les logs
docker compose logs postgres

# Verifier le port
docker port contact-service-db

# Redemarrer si necessaire
docker compose restart postgres
```

---

### Probleme 5 : Trop de connexions

**Erreur** :
```
FATAL: too many connections
```

**Solution** :
```bash
# Voir les connexions actives
docker exec -it contact-service-db psql -U postgres -d contact_service -c "SELECT COUNT(*) FROM pg_stat_activity;"

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

## 8. Exemples Pratiques

### A. Session Complete d'Administration

```bash
# 1. Se connecter
docker exec -it contact-service-db psql -U postgres -d contact_service

# 2. Voir les tables
\dt

# 3. Voir la structure de la table
\d contact_submissions

# 4. Compter les messages
SELECT COUNT(*) FROM contact_submissions;

# 5. Voir les derniers messages
SELECT id, nom, email, sujet, date_soumission 
FROM contact_submissions 
ORDER BY date_soumission DESC 
LIMIT 10;

# 6. Marquer comme lu
UPDATE contact_submissions 
SET lu = true, date_lecture = NOW() 
WHERE id = 1;

# 7. Quitter
\q
```

### B. Script de Nettoyage

```bash
# Creer un script cleanup.sh
cat > cleanup_old_messages.sh << 'EOF'
#!/bin/bash
# Supprimer les messages de plus de 90 jours

docker exec -it contact-service-db psql -U postgres -d contact_service -c "
DELETE FROM contact_submissions 
WHERE date_soumission < NOW() - INTERVAL '90 days';
"

echo "Nettoyage termine"
EOF

chmod +x cleanup_old_messages.sh

# Executer
./cleanup_old_messages.sh
```

### C. Script de Statistiques

```bash
# Creer un script stats.sh
cat > stats.sh << 'EOF'
#!/bin/bash

echo "=== Statistiques Contact Service ==="
echo ""

docker exec -it contact-service-db psql -U postgres -d contact_service -c "
SELECT 
    COUNT(*) as total_messages,
    COUNT(*) FILTER (WHERE lu = false) as non_lus,
    COUNT(*) FILTER (WHERE statut = 'NOUVEAU') as nouveaux,
    COUNT(*) FILTER (WHERE statut = 'TRAITE') as traites
FROM contact_submissions;
"

echo ""
echo "=== Messages par jour (7 derniers jours) ==="
echo ""

docker exec -it contact-service-db psql -U postgres -d contact_service -c "
SELECT 
    date_soumission::date as jour, 
    COUNT(*) as nombre 
FROM contact_submissions 
WHERE date_soumission >= NOW() - INTERVAL '7 days'
GROUP BY jour 
ORDER BY jour DESC;
"
EOF

chmod +x stats.sh

# Executer
./stats.sh
```

---

## 9. Commandes Rapides de Reference

### Acces

```bash
# Connexion directe (RECOMMANDE)
docker exec -it contact-service-db psql -U postgres -d contact_service

# Via bash
docker exec -it contact-service-db bash
psql -U postgres -d contact_service
```

### Consultation

```sql
-- Tout voir
SELECT * FROM contact_submissions ORDER BY date_soumission DESC LIMIT 10;

-- Statistiques
SELECT COUNT(*) FROM contact_submissions;
SELECT statut, COUNT(*) FROM contact_submissions GROUP BY statut;
```

### Modification

```sql
-- Marquer comme lu
UPDATE contact_submissions SET lu = true WHERE id = 1;

-- Changer statut
UPDATE contact_submissions SET statut = 'TRAITE' WHERE id = 1;
```

### Sauvegarde

```bash
# Backup
docker exec contact-service-db pg_dump -U postgres contact_service > backup.sql

# Restore
docker exec -i contact-service-db psql -U postgres -d contact_service < backup.sql
```

### Maintenance

```sql
-- Nettoyer
VACUUM ANALYZE contact_submissions;

-- Statistiques
SELECT COUNT(*) FROM contact_submissions;
```

---

## 10. Interface Graphique (Optionnel)

### A. Installer pgAdmin (Windows/Mac/Linux)

Si vous preferez une interface graphique :

1. **Telecharger pgAdmin** : https://www.pgadmin.org/download/
2. **Installer et ouvrir**
3. **Ajouter un serveur** :
   - Host : IP de votre VM (ex: `192.168.1.50`)
   - Port : `5432`
   - Database : `contact_service`
   - Username : `postgres`
   - Password : `postgres`

### B. DBeaver (Recommande)

DBeaver est plus leger et facile a utiliser :

1. **Telecharger** : https://dbeaver.io/download/
2. **Installer**
3. **Nouvelle connexion** :
   - Type : PostgreSQL
   - Host : IP de la VM
   - Port : 5432
   - Database : contact_service
   - Username : postgres
   - Password : postgres

---

## 11. Securite et Bonnes Pratiques

### A. En Production

**NE JAMAIS** :
- Utiliser `postgres/postgres` comme credentials
- Exposer le port 5432 sur Internet
- Donner l'acces root a la base

**TOUJOURS** :
- Changer le mot de passe par defaut
- Utiliser des connexions chiffrees (SSL)
- Limiter les IPs autorisees
- Faire des sauvegardes regulieres

### B. Changer le Mot de Passe

```bash
# Se connecter
docker exec -it contact-service-db psql -U postgres

# Changer le mot de passe
ALTER USER postgres WITH PASSWORD 'nouveau_mot_de_passe_securise';

# Quitter
\q

# Mettre a jour docker-compose.yml et .env
nano docker-compose.yml
# Modifier POSTGRES_PASSWORD

nano .env
# Modifier spring.datasource.password

# Redemarrer
docker compose down
docker compose up -d
```

---

## 12. Aide et Ressources

### Aide PostgreSQL

```sql
-- Aide generale
\?

-- Aide sur une commande SQL
\h SELECT
\h UPDATE
\h DELETE

-- Documentation psql
man psql
```

### Ressources en Ligne

- Documentation PostgreSQL : https://www.postgresql.org/docs/
- Tutoriels SQL : https://www.postgresqltutorial.com/
- Forum : https://stackoverflow.com/questions/tagged/postgresql

---

Bon travail avec PostgreSQL !

