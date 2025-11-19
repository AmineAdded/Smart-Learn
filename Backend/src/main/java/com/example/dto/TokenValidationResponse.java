package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenValidationResponse {
    private Boolean valid;
    private String message;
    private String email;
    private String token; // ✅ AJOUTÉ : Pour retourner le token UUID après vérification du code
}