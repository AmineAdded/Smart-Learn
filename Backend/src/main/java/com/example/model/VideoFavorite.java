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
@Table(name = "video_favorites",
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "video_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoFavorite {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.EAGER) // EAGER car on veut souvent les infos de la vidéo
    @JoinColumn(name = "video_id", nullable = false)
    private Video video;
    
    /**
     * Date d'ajout aux favoris
     */
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime addedAt;
    
    /**
     * Notes personnelles sur la vidéo favorite (optionnel)
     */
    @Column(columnDefinition = "TEXT")
    private String personalNote;
    
    /**
     * Tags personnalisés (optionnel)
     * Permet à l'utilisateur d'organiser ses favoris
     */
    @Column(length = 500)
    private String customTags;
    
    /**
     * Ordre de tri personnalisé (optionnel)
     * Permet de réorganiser les favoris
     */
    @Column
    private Integer sortOrder;
}
