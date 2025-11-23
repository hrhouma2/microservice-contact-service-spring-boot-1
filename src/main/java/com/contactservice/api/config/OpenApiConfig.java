package com.contactservice.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuration OpenAPI/Swagger
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI contactServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Contact Service API")
                        .version("1.0.0")
                        .description("Microservice REST pour gérer des formulaires de contact multi-sites avec Spring Boot 3, PostgreSQL et Spring Mail")
                        .contact(new Contact()
                                .name("Contact Service Team")
                                .email("support@contactservice.com"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Développement local"),
                        new Server().url("http://your-server.com").description("Production")
                ));
    }
}

