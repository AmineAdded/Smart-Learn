package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List; /**
 * DTO pour la réponse après sauvegarde des intérêts
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SaveInterestsResponse {

    private boolean success;
    private String message;
    private List<String> savedInterests;
    private int totalInterests;
}
