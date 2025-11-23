package com.contactservice.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * DTO pour la soumission d'un formulaire de contact
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContactRequest {

    @NotBlank(message = "Le form_id est obligatoire")
    @Size(min = 1, max = 100, message = "Le form_id doit contenir entre 1 et 100 caractères")
    @Pattern(regexp = "^[a-zA-Z0-9_-]+$", message = "Le form_id ne peut contenir que des lettres, chiffres, tirets et underscores")
    private String formId;

    @NotBlank(message = "L'email est obligatoire")
    @Email(message = "Format d'email invalide")
    @Size(max = 500, message = "L'email ne doit pas dépasser 500 caractères")
    private String email;

    @Size(max = 500, message = "Le nom ne doit pas dépasser 500 caractères")
    private String name;

    @Size(max = 5000, message = "Le message ne doit pas dépasser 5000 caractères")
    private String message;

    @Size(max = 500, message = "L'URL ne doit pas dépasser 500 caractères")
    private String pageUrl;

    @Size(max = 500, message = "Le referrer ne doit pas dépasser 500 caractères")
    private String referrer;

    private Map<String, Object> data;
}

