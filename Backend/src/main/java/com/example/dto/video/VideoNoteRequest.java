package com.example.dto.video;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoNoteRequest {
    private String content;
    private Integer timestamp; // Position dans la vidéo (optionnel)
}