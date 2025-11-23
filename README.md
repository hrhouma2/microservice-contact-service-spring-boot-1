# Contact Service API - Spring Boot 3

Microservice REST professionnel pour gérer des formulaires de contact.

## Pour les Débutants et Étudiants

**Nouveau !** Documentation complète pour l'installation sur VM :

### Point de Départ

```bash
bash START-HERE.sh
```

Ce script interactif vous guide selon votre niveau (débutant, intermédiaire, ou documentation).

### Documentation Complète (Numérotée)

Tous les guides sont dans le dossier **[documentation-etudiants/](documentation-etudiants/)** :

- **[00-README.md](documentation-etudiants/00-README.md)** - Index et parcours recommandé
- **[01-guide-installation.md](documentation-etudiants/01-guide-installation.md)** - Guide complet avec prérequis
- **[02-tutoriel-video.md](documentation-etudiants/02-tutoriel-video.md)** - Tutoriel pas-à-pas (15 min)
- **[03-faq.md](documentation-etudiants/03-faq.md)** - 28 questions/réponses
- **[04-checklist.md](documentation-etudiants/04-checklist.md)** - À imprimer et cocher
- **[05-aide-memoire.md](documentation-etudiants/05-aide-memoire.md)** - Résumé 1 page
- **[90-resume-enseignant.md](documentation-etudiants/90-resume-enseignant.md)** - Pour formateurs
- **[99-rapport-analyse.md](documentation-etudiants/99-rapport-analyse.md)** - Analyse technique

---

## Installation Rapide

```bash
# Avec Docker
docker-compose up -d

# Sans Docker
mvn spring-boot:run
```

## Documentation

- Swagger: http://localhost:8080/swagger-ui.html
- API Docs: Voir README complet dans le projet

## Stack

- Java 17
- Spring Boot 3.2.0
- PostgreSQL 15
- Maven
- Docker

## Endpoints

- POST /api/contact - Soumettre formulaire
- GET /api/health - Health check

Version: 1.0.0
