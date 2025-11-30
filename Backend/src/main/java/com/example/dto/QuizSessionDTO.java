package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizSessionDTO {
    private Long sessionId;
    private Long quizId;
    private String quizTitle;
    private Integer totalQuestions;
    private Integer durationMinutes;
    private LocalDateTime startedAt;
    private LocalDateTime expiresAt;
    private List<QuestionDTO> questions;

    // Progression sauvegardée (si reprise)
    private Integer currentQuestionIndex;
    private Map<Long, String> savedAnswers; // questionId -> answer
    private Integer timeSpentSeconds;
}