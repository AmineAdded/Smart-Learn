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
public class VideoListResponse {
    private List<VideoDTO> videos;
    private Integer currentPage;
    private Integer totalPages;
    private Long totalVideos;
    private Boolean hasNext;
    private Boolean hasPrevious;
}

