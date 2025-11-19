package com.example.controller;

import com.example.dto.*;
import com.example.service.PasswordResetService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth/password")
@CrossOrigin(origins = "*", maxAge = 3600)
public class PasswordResetController {

    @Autowired
    private PasswordResetService passwordResetService;

    /**
     * Demander un code OTP
     */
    @PostMapping("/forgot")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            MessageResponse response = passwordResetService.initiatePasswordReset(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible d'envoyer l'email")
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * ✅ NOUVEAU : Vérifier un code OTP à 6 chiffres
     */
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@Valid @RequestBody VerifyCodeRequest request) {
        try {
            TokenValidationResponse response = passwordResetService.verifyOTPCode(request.getCode());

            if (response.getValid()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity
                        .status(HttpStatus.BAD_REQUEST)
                        .body(response);
            }
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(TokenValidationResponse.builder()
                            .valid(false)
                            .message("Erreur lors de la vérification du code")
                            .build());
        }
    }

    /**
     * Vérifier un token UUID (gardé pour compatibilité)
     */
    @GetMapping("/verify")
    public ResponseEntity<?> verifyToken(@RequestParam String token) {
        try {
            TokenValidationResponse response = passwordResetService.verifyResetToken(token);

            if (response.getValid()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(TokenValidationResponse.builder()
                            .valid(false)
                            .message("Erreur lors de la vérification du token")
                            .build());
        }
    }

    /**
     * Réinitialiser le mot de passe
     */
    @PostMapping("/reset")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            MessageResponse response = passwordResetService.resetPassword(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur de réinitialisation")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de réinitialiser le mot de passe")
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }
}