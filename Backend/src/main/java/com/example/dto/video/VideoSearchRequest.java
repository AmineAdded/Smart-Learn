package com.example.dto.video;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoSearchRequest {
    private String query; // Recherche textuelle
    private String category; // Filtrer par catégorie
    private String difficulty; // Filtrer par difficulté
    private String sortBy; // recent, popular, duration
    private Integer page;
    private Integer size;
}