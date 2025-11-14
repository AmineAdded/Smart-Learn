package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

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

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @Column(nullable = false)
    private Integer score;

    @Column(nullable = false)
    private Integer totalQuestions;

    @Column(nullable = false)
    private Integer correctAnswers;

    @Column(nullable = false)
    private Integer timeSpentMinutes;

    @Column(nullable = false)
    private Integer xpEarned;

    @Column(nullable = false)
    private Boolean passed;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime completedAt;

    // Méthodes utilitaires
    public double getSuccessRate() {
        return (correctAnswers * 100.0) / totalQuestions;
    }

    public String getPerformanceLevel() {
        double rate = getSuccessRate();
        if (rate >= 90) return "Excellent";
        if (rate >= 75) return "Très bien";
        if (rate >= 60) return "Bien";
        if (rate >= 50) return "Passable";
        return "Insuffisant";
    }
}