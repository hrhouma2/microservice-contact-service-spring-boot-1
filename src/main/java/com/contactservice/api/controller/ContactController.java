package com.contactservice.api.controller;

import com.contactservice.api.dto.ContactRequest;
import com.contactservice.api.dto.ContactResponse;
import com.contactservice.api.service.EmailService;
import com.contactservice.api.service.FormSubmissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Controller principal pour la gestion des formulaires de contact
 */
@RestController
@RequestMapping("/api/contact")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Contact", description = "API de gestion des formulaires de contact")
public class ContactController {

    private final FormSubmissionService submissionService;
    private final EmailService emailService;

    @PostMapping
    @Operation(summary = "Soumettre un formulaire de contact",
               description = "Enregistre la soumission dans la base de données et envoie un email de notification")
    @ApiResponse(responseCode = "201", description = "Soumission créée avec succès",
                 content = @Content(schema = @Schema(implementation = ContactResponse.class)))
    @ApiResponse(responseCode = "400", description = "Données invalides")
    @ApiResponse(responseCode = "500", description = "Erreur serveur")
    public ResponseEntity<ContactResponse> submitContact(@Valid @RequestBody ContactRequest request) {
        log.info("Nouvelle requête de contact reçue pour form_id: {}", request.getFormId());

        try {
            // Enregistrer dans la base de données
            UUID submissionId = submissionService.saveSubmission(request);
            log.info("Soumission enregistrée avec l'ID: {}", submissionId);

            // Envoyer l'email de notification (asynchrone)
            emailService.sendContactNotification(request);

            // Retourner la réponse de succès
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(ContactResponse.success(submissionId));

        } catch (Exception e) {
            log.error("Erreur lors du traitement de la soumission", e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ContactResponse.error("Erreur lors de l'enregistrement de votre message"));
        }
    }

    @GetMapping
    @Operation(summary = "Informations sur l'endpoint",
               description = "Retourne les informations d'usage de l'endpoint POST /api/contact")
    public ResponseEntity<?> getInfo() {
        return ResponseEntity
                .status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(new EndpointInfo());
    }

    private record EndpointInfo(
            String error,
            String message,
            UsageInfo usage
    ) {
        public EndpointInfo() {
            this("Method Not Allowed",
                 "Cette route accepte uniquement les requêtes POST",
                 new UsageInfo());
        }
    }

    private record UsageInfo(
            String method,
            String endpoint,
            String contentType,
            String[] requiredFields,
            String[] optionalFields
    ) {
        public UsageInfo() {
            this("POST",
                 "/api/contact",
                 "application/json",
                 new String[]{"formId", "email"},
                 new String[]{"name", "message", "pageUrl", "referrer", "data"});
        }
    }
}

