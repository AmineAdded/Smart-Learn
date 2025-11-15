package com.example.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour la requête d'ajout d'XP
 * Utilisé lors des appels POST /api/progress/xp
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddXpRequest {
    
    @NotNull(message = "Le montant d'XP est obligatoire")
    @Min(value = 1, message = "L'XP doit être au moins 1")
    private Integer xpAmount;
    
    private String reason; // Raison de l'ajout d'XP (optionnel)
    
    private String source; // Source: "QUIZ", "VIDEO", "ACHIEVEMENT", etc.
}