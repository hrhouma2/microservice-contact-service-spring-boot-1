package com.contactservice.api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Entité représentant une soumission de formulaire de contact
 */
@Entity
@Table(name = "form_submissions", indexes = {
    @Index(name = "idx_form_id", columnList = "form_id"),
    @Index(name = "idx_email", columnList = "email"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
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

