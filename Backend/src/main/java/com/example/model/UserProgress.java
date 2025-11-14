package com.example.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_progress")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false)
    private Integer totalXp = 0;

    @Column(nullable = false)
    private Integer currentLevel = 1;

    @Column(nullable = false)
    private Integer quizCompleted = 0;

    @Column(nullable = false)
    private Integer quizSucceeded = 0;

    @Column(nullable = false)
    private Integer totalStudyTimeMinutes = 0;

    @Column(nullable = false)
    private Integer videosWatched = 0;

    @Column(nullable = false)
    private Double averageSuccessRate = 0.0;

    @Column(nullable = false)
    private Integer currentStreak = 0;

    @Column(nullable = false)
    private Integer longestStreak = 0;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column
    private LocalDateTime lastActivityDate;

    // Méthodes utilitaires
    public void addXp(int xp) {
        this.totalXp += xp;
        updateLevel();
    }

    public void addStudyTime(int minutes) {
        this.totalStudyTimeMinutes += minutes;
    }

    public void incrementQuizCompleted() {
        this.quizCompleted++;
    }

    public void incrementQuizSucceeded() {
        this.quizSucceeded++;
    }

    public void incrementVideosWatched() {
        this.videosWatched++;
    }

    public void updateSuccessRate() {
        if (quizCompleted > 0) {
            this.averageSuccessRate = (quizSucceeded * 100.0) / quizCompleted;
        }
    }

    private void updateLevel() {
        // Formule: niveau = floor(XP / 1000) + 1
        // Chaque niveau nécessite 1000 XP
        int newLevel = (totalXp / 1000) + 1;
        if (newLevel > currentLevel) {
            this.currentLevel = newLevel;
        }
    }

    public int getXpForNextLevel() {
        return currentLevel * 1000;
    }

    public int getXpProgressInCurrentLevel() {
        return totalXp % 1000;
    }

    public double getProgressPercentage() {
        return (getXpProgressInCurrentLevel() * 100.0) / 1000;
    }
}