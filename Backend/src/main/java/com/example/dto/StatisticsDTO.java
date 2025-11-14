package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StatisticsDTO {
    // Statistiques globales
    private Integer totalXp;
    private Integer currentLevel;
    private Integer quizCompleted;
    private Integer quizSucceeded;
    private Integer totalStudyTimeMinutes;
    private Integer videosWatched;
    private Double averageSuccessRate;
    
    // Progression par matière
    private List<SubjectProgress> subjectProgressList;
    
    // Activité récente
    private List<RecentActivity> recentActivities;
    
    // Classement
    private Integer globalRank;
    private Integer totalUsers;
    
    // Objectifs
    private List<Goal> goals;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectProgress {
        private String subject;
        private Integer quizCompleted;
        private Double successRate;
        private Integer xpEarned;
        private String icon;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RecentActivity {
        private String type; // QUIZ, VIDEO, ACHIEVEMENT
        private String title;
        private String description;
        private Integer xpEarned;
        private LocalDateTime date;
        private String icon;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Goal {
        private String title;
        private String description;
        private Integer current;
        private Integer target;
        private Double progress;
        private Boolean completed;
    }
}
