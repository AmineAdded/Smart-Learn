package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LevelInfoDTO {
    private Integer currentLevel;
    private String levelTitle;
    private String levelIcon;
    private Integer currentXp;
    private Integer xpForNextLevel;
    private Integer xpProgressInCurrentLevel;
    private Double progressPercentage;
    private Integer xpNeeded;
    
    // Récompenses du niveau actuel
    private String currentLevelBenefits;
    
    // Récompenses du prochain niveau
    private String nextLevelBenefits;
    
    // Badge du niveau
    private String badgeUrl;
    private String badgeColor;
}