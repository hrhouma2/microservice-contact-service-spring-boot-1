package com.contactservice.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * Application principale du Contact Service API
 * Microservice REST pour gérer des formulaires de contact
 * 
 * @author Contact Service Team
 * @version 1.0.0
 */
@SpringBootApplication
@EnableAsync
public class ContactServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(ContactServiceApplication.class, args);
    }
}

