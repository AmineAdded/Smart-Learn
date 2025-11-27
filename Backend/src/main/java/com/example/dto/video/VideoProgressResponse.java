package com.example.dto.video;

import com.example.dto.AddXpResponse;
import com.example.model.VideoProgress;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Réponse pour updateProgress avec informations XP
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VideoProgressResponse {
    private VideoProgress progress;
    private AddXpResponse xpResponse;
    private Boolean videoCompleted;
    private Boolean milestoneReached;
}