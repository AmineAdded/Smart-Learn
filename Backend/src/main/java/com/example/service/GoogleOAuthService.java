package com.example.service;

import com.example.dto.AuthResponse;
import com.example.dto.GoogleLoginRequest;
import com.example.model.User;
import com.example.repository.UserRepository;
import com.example.security.JwtUtil;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.UUID;

@Service
public class GoogleOAuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String clientId;

    /**
     * Authentifier un utilisateur via Google ID Token
     */
    @Transactional
    public AuthResponse authenticateGoogleUser(GoogleLoginRequest request) {
        try {
            // Vérifier et décoder le token Google
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance()
            )
                    .setAudience(Collections.singletonList(clientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(request.getIdToken());

            if (idToken == null) {
                throw new RuntimeException("Token Google invalide");
            }

            Payload payload = idToken.getPayload();

            // Récupérer les informations de l'utilisateur
            String email = payload.getEmail();
            boolean emailVerified = payload.getEmailVerified();
            String name = (String) payload.get("name");
            String givenName = (String) payload.get("given_name");
            String familyName = (String) payload.get("family_name");
            String pictureUrl = (String) payload.get("picture");

            if (!emailVerified) {
                throw new RuntimeException("Email Google non vérifié");
            }

            // Chercher ou créer l'utilisateur
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                // Créer un nouvel utilisateur
                User newUser = User.builder()
                        .email(email)
                        .prenom(givenName != null ? givenName : "")
                        .nom(familyName != null ? familyName : "")
                        .password(passwordEncoder.encode(UUID.randomUUID().toString())) // Mot de passe aléatoire
                        .niveau("Non spécifié") // Valeur par défaut
                        .role(User.Role.USER)
                        .enabled(true)
                        .build();

                return userRepository.save(newUser);
            });

            // Générer le JWT
            String jwt = jwtUtil.generateTokenFromEmail(user.getEmail());

            // Retourner la réponse
            return AuthResponse.builder()
                    .token(jwt)
                    .type("Bearer")
                    .id(user.getId())
                    .nom(user.getNom())
                    .prenom(user.getPrenom())
                    .email(user.getEmail())
                    .niveau(user.getNiveau())
                    .role(user.getRole().name())
                    .build();

        } catch (Exception e) {
            System.err.println("❌ Erreur lors de l'authentification Google: " + e.getMessage());
            throw new RuntimeException("Erreur lors de l'authentification Google: " + e.getMessage());
        }
    }
}