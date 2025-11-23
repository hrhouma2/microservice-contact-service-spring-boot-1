# CAHIER DES CHARGES - Contact Service API Spring Boot 3

Documentation complète du projet pour développeurs et étudiants.

---

## 1. CONTEXTE ET OBJECTIF

### Objectif pédagogique

Créer un projet complet et professionnel pour enseigner :
- Architecture REST avec Spring Boot 3
- Persistence avec JPA/Hibernate et PostgreSQL
- Conteneurisation avec Docker
- CI/CD avec GitHub Actions
- Déploiement sur VM Ubuntu

### Objectif fonctionnel

Développer un **microservice REST** qui :
- Reçoit des soumissions de formulaires de contact depuis plusieurs sites web
- Valide les données entrantes
- Enregistre dans PostgreSQL
- Envoie des notifications par email
- Expose une API REST documentée (Swagger)

---

## 2. STACK TECHNIQUE IMPOSÉE

### Langage et Framework

- **Java 17** (LTS)
- **Spring Boot 3.2.0** (dernière version stable)
- **Maven 3.9+** (gestionnaire de dépendances)

### Dépendances Spring Boot requises

```xml
<!-- API REST -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Persistence JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- Email -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>

<!-- Tests -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- PostgreSQL -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Documentation Swagger -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>

<!-- Lombok (optionnel mais recommandé) -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

### Base de données

- **PostgreSQL 15** (pas de H2, pour habituer à une vraie DB)
- En développement : via Docker Compose
- En production : instance PostgreSQL sur VM ou cloud

### Conteneurisation

- **Docker** pour l'application
- **Docker Compose** pour orchestrer app + PostgreSQL
- Image légère Alpine pour la production

### CI/CD

- **GitHub Actions** pour :
  - Build automatique
  - Exécution des tests
  - Construction de l'image Docker
  - Déploiement automatique (optionnel)

---

## 3. ARCHITECTURE DU PROJET

### Structure Maven standard

```
src/
├── main/
│   ├── java/com/contactservice/api/
│   │   ├── ContactServiceApplication.java    # Classe principale
│   │   ├── config/                           # Configurations
│   │   │   ├── CorsConfig.java
│   │   │   └── OpenApiConfig.java
│   │   ├── controller/                       # Controllers REST
│   │   │   ├── ContactController.java
│   │   │   └── HealthController.java
│   │   ├── dto/                              # Data Transfer Objects
│   │   │   ├── ContactRequest.java
│   │   │   ├── ContactResponse.java
│   │   │   └── HealthResponse.java
│   │   ├── model/                            # Entités JPA
│   │   │   └── FormSubmission.java
│   │   ├── repository/                       # Repositories Spring Data
│   │   │   └── FormSubmissionRepository.java
│   │   └── service/                          # Services métier
│   │       ├── FormSubmissionService.java
│   │       └── EmailService.java
│   └── resources/
│       ├── application.properties            # Config locale
│       └── application-docker.properties     # Config Docker
└── test/
    └── java/com/contactservice/api/
        └── controller/
            └── ContactControllerTest.java    # Tests unitaires
```

### Architecture en couches

```
Client HTTP
    ↓
Controller (REST API)
    ↓
Service (Logique métier)
    ↓
Repository (Accès données)
    ↓
PostgreSQL
```

**Séparation des responsabilités** :
- **Controller** : Gère les requêtes HTTP, validation des entrées
- **Service** : Logique métier, orchestration
- **Repository** : Accès aux données (Spring Data JPA)
- **Model** : Entités JPA mappées sur les tables PostgreSQL

---

## 4. FONCTIONNALITÉS DÉTAILLÉES

### 4.1. Endpoint POST /api/contact

**Route** : `POST /api/contact`

**Fonction** : Soumettre un formulaire de contact

**Payload JSON attendu** :

```json
{
  "formId": "string (obligatoire, 1-100 caractères, alphanumeric + _ -)",
  "email": "string (obligatoire, format email valide)",
  "name": "string (optionnel, max 500 caractères)",
  "message": "string (optionnel, max 5000 caractères)",
  "pageUrl": "string (optionnel, max 500 caractères)",
  "referrer": "string (optionnel, max 500 caractères)",
  "data": "object (optionnel, champs dynamiques JSON)"
}
```

**Validations à implémenter** :
- `formId` : obligatoire, format alphanumérique + tirets/underscores
- `email` : obligatoire, format email valide (@Email)
- `name`, `message`, etc. : limites de taille (@Size)
- Utiliser **Bean Validation** (`@Valid`, `@NotBlank`, `@Email`, `@Size`)

**Traitement** :
1. Validation du payload
2. Conversion des `data` (Map) en JSON (pour stockage en JSONB)
3. Sauvegarde en base via `FormSubmissionService`
4. Envoi email asynchrone via `EmailService` (@Async)
5. Retour de la réponse

**Réponse succès (201 Created)** :
```json
{
  "ok": true,
  "message": "Votre message a été envoyé avec succès",
  "submissionId": "uuid"
}
```

**Réponse erreur (400 Bad Request)** :
```json
{
  "ok": false,
  "message": "Les données fournies sont invalides"
}
```

### 4.2. Endpoint GET /api/health

**Route** : `GET /api/health`

**Fonction** : Health check du service

**Réponse (200 OK)** :
```json
{
  "status": "ok",
  "timestamp": "2024-11-22T19:00:00",
  "responseTime": "15ms",
  "service": {
    "name": "contact-service",
    "version": "1.0.0",
    "description": "Microservice API pour formulaires de contact"
  },
  "environment": {
    "database": true,
    "smtp": true,
    "notificationEmail": true
  },
  "system": {
    "javaVersion": "17.0.9",
    "springBootVersion": "3.2.0",
    "maxMemory": 512,
    "freeMemory": 256,
    "availableProcessors": 4
  }
}
```

**Vérifications** :
- Connexion PostgreSQL (DataSource.getConnection())
- Configuration SMTP (vérifier que JavaMailSender est configuré)
- Email de notification configuré
- Informations système (Runtime)

---

## 5. MODÈLE DE DONNÉES

### Table PostgreSQL : form_submissions

```sql
CREATE TABLE form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id VARCHAR(100) NOT NULL,
    email VARCHAR(500) NOT NULL,
    name VARCHAR(500),
    message TEXT,
    page_url VARCHAR(500),
    referrer VARCHAR(500),
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour performances
CREATE INDEX idx_form_submissions_form_id ON form_submissions(form_id);
CREATE INDEX idx_form_submissions_email ON form_submissions(email);
CREATE INDEX idx_form_submissions_created_at ON form_submissions(created_at DESC);
CREATE INDEX idx_form_submissions_data_gin ON form_submissions USING GIN (data);
```

### Entité JPA : FormSubmission.java

```java
@Entity
@Table(name = "form_submissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FormSubmission {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(name = "form_id", nullable = false, length = 100)
    private String formId;
    
    @Column(nullable = false, length = 500)
    private String email;
    
    @Column(length = 500)
    private String name;
    
    @Column(length = 5000)
    private String message;
    
    @Column(name = "page_url", length = 500)
    private String pageUrl;
    
    @Column(length = 500)
    private String referrer;
    
    @Column(columnDefinition = "jsonb")
    private String data;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
```

**Notes** :
- UUID auto-généré pour l'ID
- `data` stocké en String (JSON sérialisé) dans colonne JSONB PostgreSQL
- `createdAt` généré automatiquement par Hibernate (@CreationTimestamp)
- Utiliser Lombok (@Data, @Builder) pour réduire le boilerplate

---

## 6. CONFIGURATION

### application.properties (Développement local)

```properties
# Application
spring.application.name=contact-service
server.port=8080

# PostgreSQL
spring.datasource.url=jdbc:postgresql://localhost:5432/contact_service
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# SMTP (Gmail)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# Custom properties
contact.notification.email=notifications@yourdomain.com
cors.allowed-origins=http://localhost:3000,http://localhost:8080

# Swagger
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
```

### application-docker.properties (Docker)

```properties
# PostgreSQL (Docker service name)
spring.datasource.url=jdbc:postgresql://postgres:5432/contact_service

# Variables d'environnement
spring.mail.host=${SMTP_HOST:smtp.gmail.com}
spring.mail.port=${SMTP_PORT:587}
spring.mail.username=${SMTP_USER}
spring.mail.password=${SMTP_PASS}
contact.notification.email=${CONTACT_NOTIFICATION_EMAIL}
cors.allowed-origins=${CORS_ALLOWED_ORIGINS:http://localhost:3000}
```

### Variables d'environnement (.env)

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=xxxx-xxxx-xxxx-xxxx
CONTACT_NOTIFICATION_EMAIL=notifications@yourdomain.com
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

---

## 7. DOCKER

### Dockerfile (Multi-stage build)

```dockerfile
# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
```

**Avantages** :
- Build optimisé (cache des layers Maven)
- Image finale légère (Alpine + JRE uniquement)
- Pas de Maven dans l'image finale

### docker-compose.yml

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: contact-service-db
    environment:
      POSTGRES_DB: contact_service
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    build: .
    container_name: contact-service-app
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_PORT=${SMTP_PORT}
      - SMTP_USER=${SMTP_USER}
      - SMTP_PASS=${SMTP_PASS}
      - CONTACT_NOTIFICATION_EMAIL=${CONTACT_NOTIFICATION_EMAIL}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  postgres_data:
```

**Points clés** :
- PostgreSQL avec healthcheck (app attend que DB soit ready)
- Variables d'environnement passées depuis .env
- Volume pour persistence des données PostgreSQL
- Script d'init SQL exécuté au premier démarrage

---

## 8. CI/CD GITHUB ACTIONS

### Workflow (.github/workflows/ci-cd.yml)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_DB: contact_service_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    
    - name: Build with Maven
      run: mvn clean package -DskipTests
    
    - name: Run tests
      run: mvn test
    
    - name: Build Docker image
      if: github.ref == 'refs/heads/main'
      run: docker build -t contact-service:latest .
```

**Étapes** :
1. Checkout du code
2. Setup Java 17 avec cache Maven
3. Build Maven
4. Exécution des tests avec PostgreSQL (service container)
5. Build de l'image Docker (seulement sur main)

---

## 9. DÉPLOIEMENT SUR VM UBUNTU

### Prérequis VM

```bash
# Mise à jour système
sudo apt update && sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Installer Docker Compose
sudo apt install docker-compose -y

# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

### Déploiement

```bash
# 1. Cloner le projet
git clone https://github.com/username/contact-service-springboot.git
cd contact-service-springboot

# 2. Créer le fichier .env
nano .env
# Remplir avec les valeurs de production

# 3. Lancer
docker-compose up -d

# 4. Vérifier
curl http://localhost:8080/api/health

# 5. Voir les logs
docker-compose logs -f app
```

### Service systemd (optionnel)

```bash
# Créer le service
sudo nano /etc/systemd/system/contact-service.service
```

```ini
[Unit]
Description=Contact Service API
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/contact-service-springboot
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=ubuntu

[Install]
WantedBy=multi-user.target
```

```bash
# Activer et démarrer
sudo systemctl enable contact-service
sudo systemctl start contact-service
sudo systemctl status contact-service
```

### Nginx Reverse Proxy

```bash
# Installer Nginx
sudo apt install nginx -y

# Configurer
sudo nano /etc/nginx/sites-available/contact-api
```

```nginx
server {
    listen 80;
    server_name contact-api.votredomaine.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Activer
sudo ln -s /etc/nginx/sites-available/contact-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# SSL avec Certbot
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d contact-api.votredomaine.com
```

---

## 10. TESTS

### Tests unitaires

```java
@SpringBootTest
@AutoConfigureMockMvc
class ContactControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private FormSubmissionService submissionService;
    
    @Test
    void testSubmitContact_Success() throws Exception {
        // Arrange
        UUID mockId = UUID.randomUUID();
        when(submissionService.saveSubmission(any())).thenReturn(mockId);
        
        ContactRequest request = ContactRequest.builder()
                .formId("test")
                .email("test@example.com")
                .build();
        
        // Act & Assert
        mockMvc.perform(post("/api/contact")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.ok").value(true))
                .andExpect(jsonPath("$.submissionId").exists());
    }
    
    @Test
    void testSubmitContact_InvalidEmail() throws Exception {
        // Test avec email invalide
        // Doit retourner 400 Bad Request
    }
}
```

### Exécution

```bash
# Tous les tests
mvn test

# Tests spécifiques
mvn test -Dtest=ContactControllerTest

# Avec rapport de couverture
mvn test jacoco:report
```

---

## 11. DOCUMENTATION SWAGGER

### Configuration OpenAPI

```java
@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI contactServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Contact Service API")
                        .version("1.0.0")
                        .description("Microservice REST pour formulaires de contact")
                        .license(new License()
                                .name("MIT")
                                .url("https://opensource.org/licenses/MIT")));
    }
}
```

### Annotations sur les controllers

```java
@RestController
@RequestMapping("/api/contact")
@Tag(name = "Contact", description = "API de gestion des formulaires")
public class ContactController {
    
    @PostMapping
    @Operation(summary = "Soumettre un formulaire",
               description = "Enregistre et envoie une notification")
    @ApiResponse(responseCode = "201", description = "Succès")
    @ApiResponse(responseCode = "400", description = "Données invalides")
    public ResponseEntity<ContactResponse> submitContact(@Valid @RequestBody ContactRequest request) {
        // ...
    }
}
```

**Accès** : http://localhost:8080/swagger-ui.html

---

## 12. BONNES PRATIQUES IMPLÉMENTÉES

### Architecture
- Séparation claire des couches (Controller/Service/Repository)
- DTOs pour les transferts de données (pas d'entités dans les controllers)
- Utilisation de Builder pattern (Lombok)

### Validation
- Bean Validation (@Valid, @NotBlank, @Email, @Size)
- Validation métier dans les services
- Messages d'erreur explicites

### Persistence
- Spring Data JPA pour réduire le boilerplate
- Gestion des transactions (@Transactional)
- Index PostgreSQL pour les performances

### Email
- Envoi asynchrone (@Async) pour ne pas bloquer la réponse
- Template HTML pour les emails
- Gestion des erreurs (log mais ne bloque pas)

### Logging
- Logs structurés avec SLF4J/Logback
- Niveaux appropriés (INFO, DEBUG, ERROR)
- Logs des étapes importantes

### Sécurité
- Credentials en variables d'environnement
- CORS configuré explicitement
- Validation stricte des entrées
- HTTPS en production (Nginx + Certbot)

### Docker
- Multi-stage build pour optimiser la taille
- Health checks sur PostgreSQL
- Volumes pour la persistence
- Variables d'environnement

### CI/CD
- Tests automatiques sur chaque push
- Build Docker sur la branche main
- Service PostgreSQL pour les tests

---

## 13. COMMANDES UTILES

### Maven

```bash
# Compiler
mvn clean compile

# Tester
mvn test

# Packager (JAR)
mvn clean package

# Lancer l'application
mvn spring-boot:run

# Nettoyer
mvn clean
```

### Docker

```bash
# Build image
docker build -t contact-service:latest .

# Démarrer avec compose
docker-compose up -d

# Voir les logs
docker-compose logs -f app

# Arrêter
docker-compose down

# Rebuild
docker-compose up -d --build

# Supprimer volumes
docker-compose down -v
```

### PostgreSQL

```bash
# Se connecter au container
docker exec -it contact-service-db psql -U postgres -d contact_service

# Voir les tables
\dt

# Voir les soumissions
SELECT * FROM form_submissions ORDER BY created_at DESC LIMIT 10;

# Quitter
\q
```

---

## 14. CHECKLIST DE LIVRAISON

### Code
- [ ] Application principale SpringBootApplication
- [ ] Entité JPA FormSubmission
- [ ] Repository Spring Data
- [ ] Services (FormSubmission + Email)
- [ ] Controllers (Contact + Health)
- [ ] DTOs (Request + Response)
- [ ] Configuration (CORS + OpenAPI)
- [ ] Tests unitaires

### Configuration
- [ ] pom.xml avec toutes les dépendances
- [ ] application.properties (local)
- [ ] application-docker.properties
- [ ] .env.example

### Docker
- [ ] Dockerfile multi-stage
- [ ] docker-compose.yml
- [ ] Script init.sql

### CI/CD
- [ ] .github/workflows/ci-cd.yml
- [ ] Tests automatiques configurés

### Documentation
- [ ] README.md complet
- [ ] Commentaires JavaDoc dans le code
- [ ] Swagger configuré et fonctionnel
- [ ] Guide de déploiement

### Sécurité
- [ ] .gitignore (ne pas commit .env, target/, etc.)
- [ ] Variables d'environnement pour secrets
- [ ] CORS configuré
- [ ] Validation des entrées

---

## 15. POINTS D'APPRENTISSAGE POUR LES ÉTUDIANTS

### Spring Boot
- Architecture en couches
- Injection de dépendances
- Spring Data JPA
- Configuration avec properties
- Profiles Spring (dev, docker, prod)

### JPA/Hibernate
- Entités et annotations (@Entity, @Table, @Column)
- Relations (pas dans ce projet, mais extensible)
- JPQL queries
- Gestion des transactions

### REST API
- Controllers et mappings (@RestController, @RequestMapping)
- Validation des entrées (@Valid)
- Codes de statut HTTP appropriés
- Documentation avec OpenAPI/Swagger

### Docker
- Conteneurisation d'une app Java
- Docker Compose pour orchestration
- Multi-stage builds
- Gestion des volumes et networks

### CI/CD
- GitHub Actions
- Tests automatisés
- Build et déploiement continus

### Déploiement
- Configuration VM Ubuntu
- Nginx reverse proxy
- SSL/HTTPS avec Certbot
- Service systemd

---

## 16. ÉVOLUTIONS POSSIBLES

### Court terme
- [ ] Rate limiting (Bucket4j)
- [ ] Authentification API Key
- [ ] Pagination des résultats
- [ ] Export CSV des soumissions

### Moyen terme
- [ ] Dashboard admin (Spring MVC ou React)
- [ ] Statistiques et graphiques
- [ ] Webhooks
- [ ] Attachments (fichiers)

### Long terme
- [ ] Multi-tenant
- [ ] Internationalisation (i18n)
- [ ] Cache Redis
- [ ] Message Queue (RabbitMQ/Kafka)

---

**Version** : 1.0.0
**Date** : 2024-11-22
**Public cible** : Étudiants en développement Java/Spring Boot
**Niveau** : Intermédiaire à Avancé

---

Ce cahier des charges complet vous permet de reproduire le projet de A à Z ou de l'utiliser comme référence pédagogique.

