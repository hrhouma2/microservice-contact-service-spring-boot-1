package com.contactservice.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * DTO pour le health check de l'application
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthResponse {

    private String status;
    private LocalDateTime timestamp;
    private String responseTime;
    private ServiceInfo service;
    private EnvironmentCheck environment;
    private SystemInfo system;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ServiceInfo {
        private String name;
        private String version;
        private String description;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EnvironmentCheck {
        private Boolean database;
        private Boolean smtp;
        private Boolean notificationEmail;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SystemInfo {
        private String javaVersion;
        private String springBootVersion;
        private Long maxMemory;
        private Long freeMemory;
        private Integer availableProcessors;
    }
}

