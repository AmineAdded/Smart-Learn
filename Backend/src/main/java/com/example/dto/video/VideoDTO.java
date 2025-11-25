package com.example.dto.video;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoDTO {
    private Long id;
    private String youtubeId;
    private String title;
    private String description;
    private String thumbnailUrl;
    private String channelTitle;
    private Integer duration;
    private String formattedDuration;
    private String category;
    private String difficulty;
    private Integer viewCount;
    private Integer favoriteCount;
    private String[] tags;
    private Boolean isFavorite;
    private Boolean isWatched;
    private Double progressPercentage;
    private Integer lastTimestamp;
    private LocalDateTime createdAt;
}
