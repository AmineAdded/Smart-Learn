package com.example.dto.video;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class CreatePlaylistRequest {
    @NotBlank(message = "Le titre est obligatoire")
    private String title;
    
    private String description;
    
    @NotBlank(message = "La catégorie est obligatoire")
    private String category;
    
    private String difficulty;
    
    private Boolean isPublic;
}
