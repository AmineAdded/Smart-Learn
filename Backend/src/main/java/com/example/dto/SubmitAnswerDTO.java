package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubmitAnswerDTO {
    private Long sessionId;
    private Long questionId;
    private String answer;
    private Integer timeSpentSeconds;
}