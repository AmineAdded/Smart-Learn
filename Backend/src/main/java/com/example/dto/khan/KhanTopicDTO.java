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
public class KhanTopicDTO {
    
    private String id;
    private String slug;
    private String title;
    private String description;
    
    @JsonProperty("translated_title")
    private String translatedTitle;
    
    @JsonProperty("translated_description")
    private String translatedDescription;
    
    @JsonProperty("ka_url")
    private String kaUrl;
    
    private String kind; // "Topic", "Video", "Exercise"
    
    @JsonProperty("creation_date")
    private String creationDate;
    
    @JsonProperty("render_type")
    private String renderType;
    
    private List<KhanContentDTO> children;
    
    @JsonProperty("child_data")
    private List<KhanContentDTO> childData;
}
