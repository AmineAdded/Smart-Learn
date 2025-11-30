package com.example.dto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnswerFeedbackDTO {
    private Boolean isCorrect;
    private String correctAnswer;
    private String explanation;
    private Integer pointsEarned;
    private Integer currentScore;
    private Integer questionsAnswered;
    private Integer totalQuestions;
}
