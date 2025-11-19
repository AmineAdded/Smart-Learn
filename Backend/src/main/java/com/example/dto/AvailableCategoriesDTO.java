package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List; /**
 * DTO pour la liste complète des catégories disponibles
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AvailableCategoriesDTO {

    private List<CategoryInfo> categories;
    private int totalCategories;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CategoryInfo {
        private String name;
        private String icon; // Pour le frontend (emoji ou nom d'icône)
        private String description;
        private boolean isSelected;
    }
}
