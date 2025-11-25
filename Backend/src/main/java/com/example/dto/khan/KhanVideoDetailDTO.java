package com.example.dto.khan;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
/**
 * DTO pour la réponse vidéo individuelle
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
class KhanVideoDetailDTO {
    
    private String id;
    private String slug;
    private String title;
    private String description;
    
    @JsonProperty("youtube_id")
    private String youtubeId;
    
    @JsonProperty("duration")
    private Integer duration;
    
    @JsonProperty("ka_url")
    private String kaUrl;
    
    @JsonProperty("translated_youtube_id")
    private String translatedYoutubeId;
    
    @JsonProperty("translated_title")
    private String translatedTitle;
    
    @JsonProperty("translated_description")
    private String translatedDescription;
    
    private List<String> keywords;
}