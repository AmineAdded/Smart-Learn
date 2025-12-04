package com.example.controller;

import com.example.dto.*;
import com.example.service.AuthService;
import com.example.service.GoogleOAuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private GoogleOAuthService googleOAuthService;

    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignUpRequest signUpRequest) {
        try {
            AuthResponse response = authService.registerUser(signUpRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur d'inscription")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Une erreur est survenue lors de l'inscription")
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse response = authService.authenticateUser(loginRequest);
            return ResponseEntity.ok(response);
        } catch (BadCredentialsException e) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ErrorResponse.builder()
                            .error("Authentification échouée")
                            .message("Email ou mot de passe incorrect")
                            .status(HttpStatus.UNAUTHORIZED.value())
                            .build());
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Une erreur est survenue lors de la connexion")
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * ✅ NOUVEAU : Endpoint pour l'authentification Google
     */
    @PostMapping("/google")
    public ResponseEntity<?> authenticateWithGoogle(@Valid @RequestBody GoogleLoginRequest googleRequest) {
        try {
            AuthResponse response = googleOAuthService.authenticateGoogleUser(googleRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ErrorResponse.builder()
                            .error("Authentification Google échouée")
                            .message(e.getMessage())
                            .status(HttpStatus.UNAUTHORIZED.value())
                            .build());
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Une erreur est survenue lors de l'authentification Google")
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        try {
            var user = authService.getCurrentUser();
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ErrorResponse.builder()
                            .error("Non autorisé")
                            .message("Token invalide ou expiré")
                            .status(HttpStatus.UNAUTHORIZED.value())
                            .build());
        }
    }
}

// Contrôleur de test (optionnel)
//@RestController
//@RequestMapping("/api/test")
//@CrossOrigin(origins = "*", maxAge = 3600)
//class TestController {
//
//    @GetMapping("/public")
//    public ResponseEntity<MessageResponse> publicAccess() {
//        return ResponseEntity.ok(new MessageResponse("Contenu public"));
//    }
//
//    @GetMapping("/user")
//    public ResponseEntity<MessageResponse> userAccess() {
//        return ResponseEntity.ok(new MessageResponse("Contenu utilisateur"));
//    }
//}