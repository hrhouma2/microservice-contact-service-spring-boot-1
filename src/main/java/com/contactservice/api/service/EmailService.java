package com.contactservice.api.service;

import com.contactservice.api.dto.ContactRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

/**
 * Service pour l'envoi d'emails de notification
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    
    @Value("${contact.notification.email}")
    private String notificationEmail;

    @Value("${spring.mail.username}")
    private String fromEmail;

    /**
     * Envoie un email de notification de façon asynchrone
     */
    @Async
    public void sendContactNotification(ContactRequest request) {
        try {
            log.info("Envoi de l'email de notification pour: {}", request.getEmail());

            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(notificationEmail);
            helper.setReplyTo(request.getEmail());
            helper.setSubject(String.format("[%s] Nouveau message de %s", 
                request.getFormId(), request.getEmail()));

            // Construire le contenu HTML
            String htmlContent = buildEmailContent(request);
            helper.setText(htmlContent, true);

            mailSender.send(mimeMessage);
            log.info("Email envoyé avec succès à: {}", notificationEmail);

        } catch (MessagingException e) {
            log.error("Erreur lors de l'envoi de l'email", e);
            // On ne propage pas l'erreur pour ne pas bloquer la réponse
        }
    }

    /**
     * Construit le contenu HTML de l'email
     */
    private String buildEmailContent(ContactRequest request) {
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>");
        html.append("<html lang='fr'>");
        html.append("<head><meta charset='UTF-8'><title>Nouveau message</title></head>");
        html.append("<body style='font-family: Arial, sans-serif; padding: 20px;'>");
        html.append("<div style='max-width: 600px; margin: 0 auto;'>");
        html.append("<h2 style='color: #4F46E5;'>Nouveau message de contact</h2>");
        
        html.append("<table style='width: 100%; border-collapse: collapse;'>");
        html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Formulaire ID:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'>%s</td></tr>", request.getFormId()));
        html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Email:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'><a href='mailto:%s'>%s</a></td></tr>", request.getEmail(), request.getEmail()));
        
        if (request.getName() != null) {
            html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Nom:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'>%s</td></tr>", request.getName()));
        }
        
        if (request.getMessage() != null) {
            html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Message:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'>%s</td></tr>", request.getMessage().replace("\n", "<br>")));
        }
        
        if (request.getPageUrl() != null) {
            html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Page URL:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'><a href='%s'>%s</a></td></tr>", request.getPageUrl(), request.getPageUrl()));
        }
        
        if (request.getReferrer() != null) {
            html.append(String.format("<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'><strong>Référent:</strong></td><td style='padding: 10px; border-bottom: 1px solid #eee;'>%s</td></tr>", request.getReferrer()));
        }
        
        html.append("</table>");
        html.append("<p style='margin-top: 20px; color: #666; font-size: 12px;'>Email envoyé automatiquement par Contact Service API</p>");
        html.append("</div></body></html>");
        
        return html.toString();
    }
}

