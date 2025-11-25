package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Playlists de vidéos thématiques
 * Permet de regrouper des vidéos par sujet/parcours
 */
@Entity
@Table(name = "video_playlists")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoPlaylist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private String category; // Mathématiques, Physique, etc.

    @Column(nullable = false)
    private String difficulty;

    @Column
    private String thumbnailUrl;

    /**
     * Type de playlist : MANUAL (créée manuellement), AUTO (générée), YOUTUBE (importée)
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private PlaylistType type = PlaylistType.MANUAL;

    /**
     * ID de playlist YouTube si importée
     */
    @Column
    private String youtubePlaylistId;

    /**
     * Créateur de la playlist (peut être null pour playlists auto)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id")
    private User creator;

    /**
     * Durée totale estimée en minutes
     */
    @Column
    private Integer totalDuration;

    /**
     * Nombre de vidéos
     */
    @Column(nullable = false)
    @Builder.Default
    private Integer videoCount = 0;

    /**
     * Playlist publique ou privée
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean isPublic = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    /**
     * Playlist mise en avant
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean isFeatured = false;

    /**
     * Liste ordonnée des vidéos
     */
    @OneToMany(mappedBy = "playlist", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    @Builder.Default
    private List<PlaylistVideo> videos = new ArrayList<>();

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Méthodes utilitaires
    public void addVideo(Video video, Integer sortOrder) {
        PlaylistVideo pv = PlaylistVideo.builder()
                .playlist(this)
                .video(video)
                .sortOrder(sortOrder != null ? sortOrder : videos.size())
                .build();
        videos.add(pv);
        videoCount = videos.size();
    }

    public void removeVideo(Video video) {
        videos.removeIf(pv -> pv.getVideo().getId().equals(video.getId()));
        videoCount = videos.size();
        reorderVideos();
    }

    private void reorderVideos() {
        for (int i = 0; i < videos.size(); i++) {
            videos.get(i).setSortOrder(i);
        }
    }

    public enum PlaylistType {
        MANUAL,     // Créée manuellement par utilisateur/admin
        AUTO,       // Générée automatiquement par IA
        YOUTUBE     // Importée depuis YouTube
    }
}
