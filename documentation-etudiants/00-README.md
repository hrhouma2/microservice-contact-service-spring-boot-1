# Documentation pour Étudiants

## Contact Service API - Guides d'Installation et d'Utilisation

Ce dossier contient toute la documentation nécessaire pour installer et utiliser le Contact Service API sur une machine virtuelle Ubuntu.

---

## Liste des Documents (dans l'ordre)

### Pour les Étudiants

| N° | Document | Description | Durée | Quand l'utiliser |
|----|----------|-------------|-------|------------------|
| **00** | [README.md](README.md) | Ce fichier - index de la documentation | 2 min | Début |
| **01** | [01-guide-installation.md](01-guide-installation.md) | Guide complet d'installation avec prérequis | 10 min | **Avant le TP** - Lecture préparatoire |
| **02** | [02-tutoriel-video.md](02-tutoriel-video.md) | Tutoriel pas-à-pas chronométré (15 min) | 15 min | **Pendant le TP** - À suivre en temps réel |
| **03** | [03-faq.md](03-faq.md) | 28 questions/réponses fréquentes | Variable | **En cas de problème** - Référence |
| **04** | [04-checklist.md](04-checklist.md) | Checklist à imprimer et cocher | 1 min | **Pendant le TP** - Suivre progression |
| **05** | [05-aide-memoire.md](05-aide-memoire.md) | Résumé 1 page - commandes essentielles | 2 min | **Après le TP** - Référence rapide |
| **06** | [06-acces-et-utilisation.md](06-acces-et-utilisation.md) | Guide d'accès et d'utilisation de l'API | 15 min | **Après installation** - Comment accéder à l'API |
| **07** | [07-tests-et-cors.md](07-tests-et-cors.md) | Tests API et configuration CORS complète | 20 min | **Développement** - Tests et accès réseau |
| **08** | [08-base-de-donnees.md](08-base-de-donnees.md) | Guide complet de la base de données PostgreSQL | 25 min | **Administration** - Gérer et consulter les données |
| **09** | [09-guide-swagger.md](09-guide-swagger.md) | Guide Swagger UI avec tests et diagrammes | 30 min | **Tests** - Tester l'API et vérifier PostgreSQL |
| **10** | [10-troubleshooting-commun.md](10-troubleshooting-commun.md) | Guide de dépannage - Problèmes courants | Variable | **SOS** - Solutions aux erreurs fréquentes |

### Pour les Formateurs

| N° | Document | Description | Durée |
|----|----------|-------------|-------|
| **90** | [90-resume-enseignant.md](90-resume-enseignant.md) | Guide pour préparer et animer le TP | 15 min |
| **99** | [99-rapport-analyse.md](99-rapport-analyse.md) | Analyse technique complète du projet | 20 min |

---

## Parcours Recommandé

### Avant le TP (1 semaine avant)

**Pour les étudiants** :
1. Lire **01-guide-installation.md** (10 min)
2. Créer un mot de passe d'application Gmail
3. Noter ses informations (IP VM, mots de passe)
4. Imprimer **04-checklist.md**

**Pour le formateur** :
1. Lire **90-resume-enseignant.md** (15 min)
2. Préparer les VMs
3. Imprimer les checklists
4. Tester l'installation soi-même

---

### Pendant le TP (1h30)

**Phase 1 : Introduction** (15 min)
- Présentation du projet
- Objectifs pédagogiques
- Distribution **04-checklist.md**

**Phase 2 : Installation** (45 min)
- Les étudiants suivent **02-tutoriel-video.md**
- Ils cochent **04-checklist.md** au fur et à mesure
- Le formateur circule et aide

**Phase 3 : Validation** (15 min)
- Tests automatiques
- Vérification du dashboard
- Email de test

**Phase 4 : Exploration** (15 min)
- Commandes Docker
- Logs, base de données
- Q&A

---

### Après le TP

**Pour les étudiants** :
- Garder **05-aide-memoire.md** comme référence
- Consulter **03-faq.md** en cas de problème
- Compléter les exercices supplémentaires

**Pour le formateur** :
- Collecter feedback
- Mettre à jour la FAQ si nécessaire
- Noter le taux de réussite

---

## Démarrage Rapide

### Option 1 : Script Interactif (Recommandé)

```bash
bash START-HERE.sh
```

Ce script vous guide selon votre niveau.

### Option 2 : Installation Directe

```bash
# Vérifier les prérequis
bash scripts/00-verifier-prerequis.sh

# Installer tout automatiquement
sudo bash scripts/00-installation-complete.sh

# Tester
bash scripts/06-tester-api.sh
```

---

## Comment Utiliser Cette Documentation

### Vous êtes Étudiant Débutant ?

**Parcours recommandé** :
1. Commencez par **01-guide-installation.md**
2. Suivez **02-tutoriel-video.md** pendant l'installation
3. Imprimez **04-checklist.md** pour cocher au fur et à mesure
4. En cas de problème, consultez **03-faq.md**

### Vous êtes Étudiant Avancé ?

**Parcours rapide** :
1. Lisez **05-aide-memoire.md** (2 min)
2. Lancez `bash START-HERE.sh` et choisissez "Intermédiaire"
3. Consultez **03-faq.md** si besoin

### Vous êtes Formateur ?

**Préparation du TP** :
1. Lisez **90-resume-enseignant.md** pour le déroulement
2. Consultez **99-rapport-analyse.md** pour l'analyse technique
3. Distribuez **01-guide-installation.md** aux étudiants 1 semaine avant
4. Imprimez **04-checklist.md** (1 par étudiant)

---

## Structure Technique

### Technologies Utilisées

- **Backend** : Spring Boot 3.2.0 (Java 17)
- **Base de données** : PostgreSQL 15
- **Conteneurisation** : Docker + Docker Compose
- **Documentation API** : Swagger/OpenAPI
- **Serveur web** : Nginx (optionnel)

### Architecture

```
┌─────────────────┐
│   Navigateur    │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│   Nginx (80)    │ (Optionnel)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Spring Boot    │
│   (port 8080)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PostgreSQL     │
│   (port 5432)   │
└─────────────────┘
```

---

## Compétences Acquises

### Techniques
- Linux (SSH, commandes de base, droits)
- Git (clone, pull, branches)
- Docker (compose, logs, restart)
- API REST (JSON, endpoints, tests)
- Base de données (PostgreSQL, SQL)
- Réseau (ports, firewall, CORS)

### Transversales
- Lecture documentation technique
- Résolution de problèmes
- Autonomie
- Rigueur

---

## Support et Aide

### Problème Courant ?

Consultez **03-faq.md** qui contient 28 Q&A sur :
- Configuration Gmail
- Problèmes d'installation
- Erreurs Docker
- Problèmes réseau
- Base de données

### Besoin d'Aide Personnalisée ?

1. Vérifiez les logs : `docker compose logs app`
2. Consultez la FAQ : **03-faq.md**
3. Demandez au formateur
4. Ouvrez une issue sur GitHub

---

## Statistiques

### Temps d'Installation

- **Avec guide** : 15-20 minutes
- **En autonomie** : 25-30 minutes
- **Avec aide formateur** : 10-15 minutes

### Taux de Réussite Attendu

- **Débutants** : 90%
- **Intermédiaires** : 98%
- **Avancés** : 100%

---

## Mises à Jour

Ce dossier est régulièrement mis à jour. Vérifiez la version :

**Version actuelle** : 1.0.0  
**Dernière mise à jour** : Novembre 2025

---

## Contact

**Questions techniques** : Ouvrir une issue sur GitHub  
**Feedback** : Contactez votre formateur  
**Contributions** : Pull requests bienvenues

---

## Licence

Ce projet est fourni à des fins pédagogiques.

---

**Bon apprentissage !**

