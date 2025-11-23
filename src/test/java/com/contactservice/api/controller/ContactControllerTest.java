package com.contactservice.api.controller;

import com.contactservice.api.dto.ContactRequest;
import com.contactservice.api.service.FormSubmissionService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ContactControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private FormSubmissionService submissionService;

    @Test
    void testSubmitContact_Success() throws Exception {
        UUID mockId = UUID.randomUUID();
        when(submissionService.saveSubmission(any())).thenReturn(mockId);

        ContactRequest request = ContactRequest.builder()
                .formId("test-form")
                .email("test@example.com")
                .name("Test User")
                .message("Test message")
                .build();

        mockMvc.perform(post("/api/contact")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.ok").value(true))
                .andExpect(jsonPath("$.submissionId").exists());
    }

    @Test
    void testSubmitContact_InvalidEmail() throws Exception {
        ContactRequest request = ContactRequest.builder()
                .formId("test-form")
                .email("invalid-email")
                .build();

        mockMvc.perform(post("/api/contact")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testGetInfo() throws Exception {
        mockMvc.perform(get("/api/contact"))
                .andExpect(status().isMethodNotAllowed())
                .andExpect(jsonPath("$.error").value("Method Not Allowed"));
    }
}

