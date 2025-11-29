package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder  // ⭐ IMPORTANT : Ajouter cette annotation
public class QuizDTO {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String difficulty;
    private Integer questionCount;
    private Integer durationMinutes;
    private Integer xpReward;
    private Boolean hasAI;
    private Boolean isActive;
    private LocalDateTime createdAt;

    // Informations supplémentaires pour l'utilisateur
    private Boolean isCompleted;
    private Integer userBestScore;
    private Integer attemptsCount;
}