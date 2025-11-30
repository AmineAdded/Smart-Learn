package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO détaillé pour afficher toutes les informations d'un quiz
 * avant de le commencer
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizDetailDTO {
    // Informations de base
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

    // Informations sur le créateur (optionnel)
    private String createdBy;

    // Distribution des types de questions
    private QuestionDistribution questionDistribution;

    // Statistiques globales du quiz
    private QuizStatistics statistics;

    // Informations utilisateur
    private UserQuizProgress userProgress;

    // Leaderboard (top 5)
    private List<LeaderboardEntry> topScores;

    // Prérequis et recommandations
    private List<String> prerequisites;
    private String recommendedLevel;
    private List<String> topics;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuestionDistribution {
        private Integer multipleChoice;  // QCM
        private Integer trueFalse;       // Vrai/Faux
        private Integer shortAnswer;     // Réponse courte
        private Integer matching;        // Association
        private Integer withImages;      // Avec images
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuizStatistics {
        private Integer totalAttempts;
        private Double averageScore;
        private Integer completionRate;  // Pourcentage
        private Double averageTimeMinutes;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserQuizProgress {
        private Boolean hasAttempted;
        private Integer attemptsCount;
        private Integer bestScore;
        private Integer lastScore;
        private LocalDateTime lastAttemptDate;
        private Boolean canRetake;
        private String progressStatus; // "not_started", "in_progress", "completed"
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LeaderboardEntry {
        private String username;
        private Integer score;
        private LocalDateTime completedAt;
        private Integer rank;
    }
}