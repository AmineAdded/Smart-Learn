package com.example.dto.video;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoProgressRequest {
    private Integer currentTimestamp; // Position actuelle (en secondes)
    private Boolean completed; // Marquer comme terminé
}