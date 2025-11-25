package com.example.model;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

// ========== VideoProgress : Suivi de la progression de visionnage ==========

@Entity
@Table(name = "video_progress", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "video_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoProgress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "video_id", nullable = false)
    private Video video;
    
    /**
     * Position actuelle dans la vidéo (en secondes)
     * Permet de reprendre la vidéo où l'utilisateur s'est arrêté
     */
    @Column(nullable = false)
    @Builder.Default
    private Integer lastTimestamp = 0;
    
    /**
     * Temps total regardé (en secondes)
     * Peut être différent de lastTimestamp si l'utilisateur saute des parties
     */
    @Column(nullable = false)
    @Builder.Default
    private Integer watchedSeconds = 0;
    
    /**
     * Pourcentage de progression (0-100)
     */
    @Column(nullable = false)
    @Builder.Default
    private Double progressPercentage = 0.0;
    
    /**
     * Vidéo marquée comme terminée
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean completed = false;
    
    /**
     * Date de dernière visualisation
     */
    @Column(nullable = false)
    private LocalDateTime lastWatchedAt;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * Mise à jour de la progression
     * Calcule automatiquement le pourcentage
     */
    public void updateProgress(Integer currentTimestamp, Integer videoDuration) {
        this.lastTimestamp = currentTimestamp;
        this.lastWatchedAt = LocalDateTime.now();
        
        if (videoDuration != null && videoDuration > 0) {
            this.progressPercentage = (currentTimestamp * 100.0) / videoDuration;
            
            // Marquer comme complété si > 90%
            if (this.progressPercentage >= 90.0) {
                this.completed = true;
                this.progressPercentage = 100.0;
            }
        }
    }
    
    /**
     * Incrémenter le temps de visionnage
     */
    public void addWatchedSeconds(Integer seconds) {
        if (seconds != null && seconds > 0) {
            this.watchedSeconds += seconds;
        }
    }
    
    /**
     * Formater le temps de visionnage pour l'affichage
     */
    public String getFormattedWatchTime() {
        int hours = watchedSeconds / 3600;
        int minutes = (watchedSeconds % 3600) / 60;
        int seconds = watchedSeconds % 60;
        
        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, seconds);
        } else {
            return String.format("%d:%02d", minutes, seconds);
        }
    }
    
    /**
     * Formater le timestamp actuel
     */
    public String getFormattedTimestamp() {
        int minutes = lastTimestamp / 60;
        int seconds = lastTimestamp % 60;
        return String.format("%d:%02d", minutes, seconds);
    }
}
