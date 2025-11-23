package com.contactservice.api.controller;

import com.contactservice.api.dto.HealthResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.info.BuildProperties;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;

/**
 * Controller pour les health checks
 */
@RestController
@RequestMapping("/api/health")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Health", description = "Health check et monitoring")
public class HealthController {

    private final DataSource dataSource;
    private final JavaMailSender mailSender;
    
    @Value("${contact.notification.email:}")
    private String notificationEmail;

    @GetMapping
    @Operation(summary = "Health check du service",
               description = "Vérifie l'état du service et de ses dépendances")
    public ResponseEntity<HealthResponse> healthCheck() {
        long startTime = System.currentTimeMillis();

        // Vérifier la connexion à la base de données
        boolean dbHealthy = checkDatabase();

        // Vérifier la configuration SMTP (simplifié)
        boolean smtpConfigured = mailSender != null;

        // Vérifier l'email de notification
        boolean emailConfigured = notificationEmail != null && !notificationEmail.isEmpty();

        // Informations système
        Runtime runtime = Runtime.getRuntime();
        HealthResponse.SystemInfo systemInfo = HealthResponse.SystemInfo.builder()
                .javaVersion(System.getProperty("java.version"))
                .springBootVersion("3.2.0")
                .maxMemory(runtime.maxMemory() / 1024 / 1024)
                .freeMemory(runtime.freeMemory() / 1024 / 1024)
                .availableProcessors(runtime.availableProcessors())
                .build();

        // Environnement
        HealthResponse.EnvironmentCheck envCheck = HealthResponse.EnvironmentCheck.builder()
                .database(dbHealthy)
                .smtp(smtpConfigured)
                .notificationEmail(emailConfigured)
                .build();

        // Service info
        HealthResponse.ServiceInfo serviceInfo = HealthResponse.ServiceInfo.builder()
                .name("contact-service")
                .version("1.0.0")
                .description("Microservice API pour formulaires de contact")
                .build();

        // Temps de réponse
        long responseTime = System.currentTimeMillis() - startTime;

        // Statut global
        String status = (dbHealthy && smtpConfigured && emailConfigured) ? "ok" : "degraded";

        HealthResponse response = HealthResponse.builder()
                .status(status)
                .timestamp(LocalDateTime.now())
                .responseTime(responseTime + "ms")
                .service(serviceInfo)
                .environment(envCheck)
                .system(systemInfo)
                .build();

        return ResponseEntity.ok(response);
    }

    private boolean checkDatabase() {
        try (Connection connection = dataSource.getConnection()) {
            return connection.isValid(1);
        } catch (Exception e) {
            log.error("Erreur lors de la vérification de la base de données", e);
            return false;
        }
    }
}

