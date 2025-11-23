package com.contactservice.api.service;

import com.contactservice.api.dto.ContactRequest;
import com.contactservice.api.model.FormSubmission;
import com.contactservice.api.repository.FormSubmissionRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Service pour gérer les soumissions de formulaires
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class FormSubmissionService {

    private final FormSubmissionRepository repository;
    private final ObjectMapper objectMapper;

    /**
     * Enregistre une nouvelle soumission de formulaire
     */
    @Transactional
    public UUID saveSubmission(ContactRequest request) {
        log.info("Enregistrement d'une nouvelle soumission pour form_id: {}", request.getFormId());

        // Convertir les données supplémentaires en JSON
        String dataJson = null;
        if (request.getData() != null && !request.getData().isEmpty()) {
            try {
                dataJson = objectMapper.writeValueAsString(request.getData());
            } catch (JsonProcessingException e) {
                log.warn("Erreur lors de la conversion des données en JSON", e);
            }
        }

        // Créer l'entité
        FormSubmission submission = FormSubmission.builder()
                .formId(request.getFormId())
                .email(request.getEmail())
                .name(request.getName())
                .message(request.getMessage())
                .pageUrl(request.getPageUrl())
                .referrer(request.getReferrer())
                .data(dataJson)
                .build();

        // Sauvegarder
        FormSubmission saved = repository.save(submission);
        log.info("Soumission enregistrée avec l'ID: {}", saved.getId());

        return saved.getId();
    }

    /**
     * Compte le nombre de soumissions pour un form_id
     */
    public Long countByFormId(String formId) {
        return repository.countByFormId(formId);
    }
}

