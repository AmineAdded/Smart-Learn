package com.example.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO pour la requête de sauvegarde des intérêts
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SaveInterestsRequest {

    @NotEmpty(message = "Veuillez sélectionner au moins un domaine d'intérêt")
    private List<String> categories;
}

