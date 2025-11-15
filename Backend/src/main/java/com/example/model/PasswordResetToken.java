package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "password_reset_tokens")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String token;

    @Column(unique = true, nullable = false, length = 6)
    private String code;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDateTime expiryDate;

    @Column(nullable = false)
    @Builder.Default  // ✅ IMPORTANT : Pour que Builder utilise la valeur par défaut
    private Boolean used = false;

    @Column(nullable = false)
    @Builder.Default  // ✅ AJOUT : Pour que Builder initialise automatiquement
    private LocalDateTime createdAt = LocalDateTime.now();

    // Vérifier si le token est expiré
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiryDate);
    }

    // Vérifier si le token est valide
    public boolean isValid() {
        return !used && !isExpired();
    }
}