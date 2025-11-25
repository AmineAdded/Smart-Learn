package com.example.dto.video;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
// ========== VideoStatsDTO : Statistiques utilisateur ==========
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoStatsDTO {
    private Integer totalVideosWatched;
    private Integer totalWatchTimeMinutes;
    private Integer favoritesCount;
    private Integer completedCount;
    private List<CategoryStats> byCategory;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CategoryStats {
        private String category;
        private Integer count;
        private Integer totalMinutes;
    }
}