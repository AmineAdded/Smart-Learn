package com.example.dto.khan;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
class KhanContentDTO {
    
    private String id;
    private String slug;
    private String title;
    private String description;
    private String kind; // "Video", "Exercise", "Article"
    
    @JsonProperty("ka_url")
    private String kaUrl;
    
    @JsonProperty("translated_title")
    private String translatedTitle;
    
    @JsonProperty("translated_description")
    private String translatedDescription;
    
    // Spécifique aux vidéos
    @JsonProperty("youtube_id")
    private String youtubeId;
    
    @JsonProperty("duration")
    private Integer duration;
    
    @JsonProperty("image_url")
    private String imageUrl;
    
    @JsonProperty("thumbnail_url")
    private String thumbnailUrl;
    
    @JsonProperty("download_urls")
    private DownloadUrls downloadUrls;
    
    // Métadonnées
    @JsonProperty("date_added")
    private String dateAdded;
    
    @JsonProperty("keywords")
    private String keywords;
}
