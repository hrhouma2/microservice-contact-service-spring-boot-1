package com.contactservice.api.repository;

import com.contactservice.api.model.FormSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository pour les soumissions de formulaires
 */
@Repository
public interface FormSubmissionRepository extends JpaRepository<FormSubmission, UUID> {

    /**
     * Trouve les soumissions par form_id
     */
    List<FormSubmission> findByFormIdOrderByCreatedAtDesc(String formId);

    /**
     * Trouve les soumissions par email
     */
    List<FormSubmission> findByEmailOrderByCreatedAtDesc(String email);

    /**
     * Compte le nombre de soumissions par form_id
     */
    Long countByFormId(String formId);

    /**
     * Statistiques des soumissions par form_id
     */
    @Query("SELECT f.formId, COUNT(f) FROM FormSubmission f GROUP BY f.formId")
    List<Object[]> getSubmissionStats();
}

