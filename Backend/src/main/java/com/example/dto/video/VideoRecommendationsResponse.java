package com.example.dto.video;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoRecommendationsResponse {
    private List<VideoDTO> recommended;
    private String reason; // Raison de la recommandation
    private Integer totalRecommendations;
}
