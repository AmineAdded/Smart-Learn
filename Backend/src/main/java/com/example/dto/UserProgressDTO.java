package com.example.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProgressDTO {
    private Long userId;
    private String userName;
    private String userEmail;
    private String niveau;
    
    // Statistiques principales
    private Integer totalXp;
    private Integer currentLevel;
    private Integer quizCompleted;
    private Integer quizSucceeded;
    private Integer totalStudyTimeMinutes;
    private Integer videosWatched;
    private Double averageSuccessRate;
    
    // Informations de progression
    private Integer xpForNextLevel;
    private Integer xpProgressInCurrentLevel;
    private Double progressPercentage;
    
    // Streaks
    private Integer currentStreak;
    private Integer longestStreak;
    
    // Dates
    private LocalDateTime lastActivityDate;
    private LocalDateTime createdAt;
    
    // Informations dérivées
    private String studyTimeFormatted;
    private String levelTitle;
    private Integer totalQuizAttempts;
}
