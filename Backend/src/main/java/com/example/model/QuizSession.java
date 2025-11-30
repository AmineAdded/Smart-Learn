package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Représente une session de quiz en cours
 * Permet de sauvegarder la progression et de reprendre plus tard
 */
@Entity
@Table(name = "quiz_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "current_question_index")
    private Integer currentQuestionIndex = 0;

    @Column(name = "time_spent_seconds")
    private Integer timeSpentSeconds = 0;

    @Column(name = "current_score")
    private Integer currentScore = 0;

    @Column(name = "total_points_possible")
    private Integer totalPointsPossible = 0;

    @Column(name = "is_completed")
    private Boolean isCompleted = false;

    @Column(name = "is_expired")
    private Boolean isExpired = false;

    @PrePersist
    protected void onCreate() {
        startedAt = LocalDateTime.now();
    }
}