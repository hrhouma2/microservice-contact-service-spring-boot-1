package com.contactservice.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * DTO pour la réponse après soumission d'un formulaire
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContactResponse {

    private Boolean ok;
    private String message;
    private UUID submissionId;

    public static ContactResponse success(UUID submissionId) {
        return ContactResponse.builder()
                .ok(true)
                .message("Votre message a été envoyé avec succès")
                .submissionId(submissionId)
                .build();
    }

    public static ContactResponse error(String message) {
        return ContactResponse.builder()
                .ok(false)
                .message(message)
                .build();
    }
}

