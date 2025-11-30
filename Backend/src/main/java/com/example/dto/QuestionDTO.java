package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionDTO {
    private Long id;
    private String questionText;
    private String type; // QCM, VRAI_FAUX, REPONSE_COURTE, ASSOCIATION
    private String imageUrl;
    private Integer points;
    private Integer orderNumber;

    // Pour les questions à choix multiples
    private List<AnswerOptionDTO> options;

    // Pour les questions d'association
    private List<String> leftItems;
    private List<String> rightItems;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnswerOptionDTO {
        private Long id;
        private String optionText;
        private String optionLetter; // A, B, C, D
        // Note: Ne pas envoyer isCorrect au frontend pour la sécurité
    }
}