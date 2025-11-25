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
@Table(name = "video_notes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoNote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "video_id", nullable = false)
    private Video video;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content; // Contenu de la note

    @Column
    private Integer timestamp; // Timestamp dans la vidéo (en secondes)

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Formater le timestamp pour l'affichage
    public String getFormattedTimestamp() {
        if (timestamp == null) {
            return null;
        }
        
        int minutes = timestamp / 60;
        int seconds = timestamp % 60;
        return String.format("%d:%02d", minutes, seconds);
    }
}