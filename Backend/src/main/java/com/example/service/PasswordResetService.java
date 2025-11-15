package com.example.service;

import com.example.dto.*;
import com.example.model.PasswordResetToken;
import com.example.model.User;
import com.example.repository.PasswordResetTokenRepository;
import com.example.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.UUID;

@Service
public class PasswordResetService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordResetTokenRepository tokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EmailService emailService;

    private static final int TOKEN_EXPIRY_HOURS = 1;

    /**
     * ✅ Initier la réinitialisation avec code OTP
     */
    @Transactional
    public MessageResponse initiatePasswordReset(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);

        if (user == null) {
            System.out.println("⚠️ Tentative pour email inexistant : " + request.getEmail());
            return new MessageResponse("Si un compte existe avec cet email, vous recevrez un code de vérification");
        }

        // Supprimer les anciens tokens
        tokenRepository.deleteByUser(user);

        // Générer token UUID (pour l'API) et code OTP (pour l'utilisateur)
        String token = UUID.randomUUID().toString();
        String code = generateOTPCode();

        PasswordResetToken resetToken = PasswordResetToken.builder()
                .token(token)
                .code(code)
                .user(user)
                .expiryDate(LocalDateTime.now().plusHours(TOKEN_EXPIRY_HOURS))
                .used(false)
                .build();

        tokenRepository.save(resetToken);

        // Envoyer le code par email
        emailService.sendPasswordResetCode(
                user.getEmail(),
                code,
                user.getPrenom() + " " + user.getNom()
        );

        System.out.println("✅ Code OTP créé pour : " + user.getEmail() + " | Code: " + code);
        return new MessageResponse("Si un compte existe avec cet email, vous recevrez un code de vérification");
    }

    /**
     * ✅ Vérifier le code OTP à 6 chiffres
     */
    public TokenValidationResponse verifyOTPCode(String code) {
        PasswordResetToken resetToken = tokenRepository.findByCode(code).orElse(null);

        if (resetToken == null) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Code invalide")
                    .build();
        }

        if (resetToken.getUsed()) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Ce code a déjà été utilisé")
                    .build();
        }

        if (resetToken.isExpired()) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Ce code a expiré")
                    .build();
        }

        // Retourner le token UUID pour l'étape suivante
        return TokenValidationResponse.builder()
                .valid(true)
                .message("Code valide")
                .email(resetToken.getUser().getEmail())
                .token(resetToken.getToken()) // ✅ Important !
                .build();
    }

    /**
     * Vérifier un token UUID (ancienne méthode, gardée pour compatibilité)
     */
    public TokenValidationResponse verifyResetToken(String token) {
        PasswordResetToken resetToken = tokenRepository.findByToken(token).orElse(null);

        if (resetToken == null) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Token invalide")
                    .build();
        }

        if (resetToken.getUsed()) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Ce lien a déjà été utilisé")
                    .build();
        }

        if (resetToken.isExpired()) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Ce lien a expiré")
                    .build();
        }

        return TokenValidationResponse.builder()
                .valid(true)
                .message("Token valide")
                .email(resetToken.getUser().getEmail())
                .build();
    }

    /**
     * Réinitialiser le mot de passe
     */
    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = tokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Token invalide"));

        if (!resetToken.isValid()) {
            throw new RuntimeException("Le token est invalide ou a expiré");
        }

        User user = resetToken.getUser();

        if (passwordEncoder.matches(request.getNewPassword(), user.getPassword())) {
            throw new RuntimeException("Le nouveau mot de passe doit être différent de l'ancien");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        resetToken.setUsed(true);
        tokenRepository.save(resetToken);

        emailService.sendPasswordChangedEmail(user.getEmail(), user.getPrenom() + " " + user.getNom());

        System.out.println("✅ Mot de passe réinitialisé pour : " + user.getEmail());
        return new MessageResponse("Votre mot de passe a été réinitialisé avec succès");
    }

    /**
     * ✅ Générer un code OTP à 6 chiffres
     */
    private String generateOTPCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000); // Entre 100000 et 999999
        return String.valueOf(code);
    }

    /**
     * Nettoyer les tokens expirés
     */
    @Transactional
    public void cleanupExpiredTokens() {
        tokenRepository.deleteExpiredTokens(LocalDateTime.now());
        System.out.println("🧹 Nettoyage des tokens expirés effectué");
    }
}