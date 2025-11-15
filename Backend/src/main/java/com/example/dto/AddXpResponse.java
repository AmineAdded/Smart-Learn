package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour la réponse après ajout d'XP
 * Retourne les nouvelles informations de progression
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddXpResponse {
    
    private Integer xpAdded;
    private Integer totalXp;
    private Integer currentLevel;
    private String levelTitle;
    private Integer xpForNextLevel;
    private Integer xpProgressInCurrentLevel;
    private Double progressPercentage;
    private Boolean leveledUp; // Indique si l'utilisateur a gagné un niveau
    private Integer newLevel; // Le nouveau niveau (si leveledUp = true)
    private String message;
}