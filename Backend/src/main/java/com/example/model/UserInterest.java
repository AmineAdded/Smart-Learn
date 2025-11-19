package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_interests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserInterest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String category; // Ex: "Mathématiques", "Sciences", "Langues"

    @Column(nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    @PreUpdate
    private void validateCategory() {
        if (!SubjectCategory.isValid(category)) {
            throw new IllegalArgumentException("Catégorie invalide: " + category);
        }
    }
}

/**
 * Énumération des catégories de matières disponibles
 */
class SubjectCategory {
    public static final String MATHEMATICS = "Mathématiques";
    public static final String SCIENCES = "Sciences";
    public static final String PHYSICS = "Physique";
    public static final String CHEMISTRY = "Chimie";
    public static final String BIOLOGY = "Biologie";
    public static final String LANGUAGES = "Langues";
    public static final String FRENCH = "Français";
    public static final String ENGLISH = "Anglais";
    public static final String SPANISH = "Espagnol";
    public static final String HISTORY = "Histoire";
    public static final String GEOGRAPHY = "Géographie";
    public static final String PHILOSOPHY = "Philosophie";
    public static final String COMPUTER_SCIENCE = "Informatique";
    public static final String ECONOMICS = "Économie";
    public static final String ARTS = "Arts";
    public static final String MUSIC = "Musique";
    public static final String SPORTS = "Sport";

    private static final String[] ALL_CATEGORIES = {
            MATHEMATICS, SCIENCES, PHYSICS, CHEMISTRY, BIOLOGY,
            LANGUAGES, FRENCH, ENGLISH, SPANISH,
            HISTORY, GEOGRAPHY, PHILOSOPHY,
            COMPUTER_SCIENCE, ECONOMICS, ARTS, MUSIC, SPORTS
    };

    public static boolean isValid(String category) {
        for (String cat : ALL_CATEGORIES) {
            if (cat.equals(category)) {
                return true;
            }
        }
        return false;
    }

    public static String[] getAllCategories() {
        return ALL_CATEGORIES;
    }
}