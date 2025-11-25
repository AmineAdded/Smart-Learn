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
public class VideoNoteDTO {
    private Long id;
    private String content;
    private Integer timestamp;
    private String formattedTimestamp;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}