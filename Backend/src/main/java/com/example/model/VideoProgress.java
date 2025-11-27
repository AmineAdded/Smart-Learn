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
    
    @Column(name = "last_timestamp", nullable = false)
    @Builder.Default
    private Integer lastTimestamp = 0;
    
    @Column(name = "watched_seconds", nullable = false)
    @Builder.Default
    private Integer watchedSeconds = 0;
    
    @Column(name = "progress_percentage", nullable = false)
    @Builder.Default
    private Double progressPercentage = 0.0;
    
    @Column(nullable = false)
    @Builder.Default
    private Boolean completed = false;
    
    @Column(name = "watch_count", nullable = false)
    @Builder.Default
    private Integer watchCount = 1;
    
    // ✅ CORRECTION : Initialiser lastWatchedAt
    @Column(name = "last_watched_at", nullable = false)
    @Builder.Default
    private LocalDateTime lastWatchedAt = LocalDateTime.now();
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * ✅ Méthode pour mettre à jour la progression
     */
    public void updateProgress(Integer currentTimestamp, Integer videoDuration) {
        if (currentTimestamp == null || videoDuration == null || videoDuration == 0) {
            return;
        }

        this.lastTimestamp = currentTimestamp;
        
        // Calculer le pourcentage
        double percentage = (currentTimestamp.doubleValue() / videoDuration.doubleValue()) * 100.0;
        this.progressPercentage = Math.min(100.0, Math.max(0.0, percentage));

        // Auto-complétion si ≥ 90%
        if (this.progressPercentage >= 90.0 && !this.completed) {
            this.completed = true;
            this.progressPercentage = 100.0;
        }

        // Incrémenter watchCount si retour au début
        if (currentTimestamp < 30) {
            this.watchCount++;
        }
        
        // ✅ IMPORTANT : Mettre à jour lastWatchedAt
        this.lastWatchedAt = LocalDateTime.now();
    }
    
    /**
     * ✅ Initialisation automatique avant sauvegarde
     */
    @PrePersist
    protected void onCreate() {
        if (this.lastWatchedAt == null) {
            this.lastWatchedAt = LocalDateTime.now();
        }
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }
    
    /**
     * ✅ Mise à jour automatique
     */
    @PreUpdate
    protected void onUpdate() {
        this.lastWatchedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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
     * Formater le temps de visionnage
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