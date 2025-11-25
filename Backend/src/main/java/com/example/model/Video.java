package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "videos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Video {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String youtubeId; // ID unique de YouTube (ex: "dQw4w9WgXcQ")

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private String thumbnailUrl; // URL de la miniature

    @Column(nullable = false)
    private String channelTitle; // Nom de la chaîne YouTube

    @Column(nullable = false)
    private Integer duration; // Durée en secondes

    @Column(nullable = false)
    private String category; // Mathématiques, Physique, etc.

    @Column(nullable = false)
    private String difficulty; // Facile, Moyen, Difficile

    @Column(nullable = false)
    private Integer viewCount = 0;

    @Column(nullable = false)
    private Integer favoriteCount = 0;

    @Column
    private String tags; // Tags séparés par des virgules

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isFeatured = false; // Vidéo mise en avant

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Méthode utilitaire pour formater la durée
    public String getFormattedDuration() {
        int hours = duration / 3600;
        int minutes = (duration % 3600) / 60;
        int seconds = duration % 60;

        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, seconds);
        } else {
            return String.format("%d:%02d", minutes, seconds);
        }
    }

    // Convertir les tags en liste
    public String[] getTagsList() {
        if (tags == null || tags.isEmpty()) {
            return new String[0];
        }
        return tags.split(",");
    }
}