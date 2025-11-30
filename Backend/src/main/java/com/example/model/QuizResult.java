package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Représente le résultat final d'un quiz terminé
 */
@Entity
@Table(name = "quiz_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @Column(name = "score", nullable = false)
    private Integer score; // Pourcentage (0-100)

    @Column(name = "time_spent_minutes")
    private Integer timeSpentMinutes;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // ⭐ Colonnes supplémentaires pour correspondre à votre base de données
    @Column(name = "correct_answers")
    private Integer correctAnswers = 0;

    @Column(name = "total_questions")
    private Integer totalQuestions = 0;

    @Column(name = "passed")
    private Boolean passed = false;

    @Column(name = "xp_earned")
    private Integer xpEarned = 0;

    @Column(name = "earned_points")
    private Integer earnedPoints = 0;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (completedAt == null) {
            completedAt = LocalDateTime.now();
        }
        if (correctAnswers == null) {
            correctAnswers = 0;
        }
        if (totalQuestions == null) {
            totalQuestions = 0;
        }
        if (passed == null) {
            passed = false;
        }
        if (xpEarned == null) {
            xpEarned = 0;
        }
        if (earnedPoints == null) {
            earnedPoints = 0;
        }
    }
}