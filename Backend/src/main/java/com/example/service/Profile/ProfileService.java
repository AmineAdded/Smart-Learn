package com.example.service.Profile;

import com.example.dto.Profile.ChangePasswordRequest;
import com.example.dto.Profile.ProfileResponse;
import com.example.dto.Profile.UpdateProfileRequest;
import com.example.model.User;
import com.example.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;

@Service
public class ProfileService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Récupérer le profil de l'utilisateur connecté
     */
    public ProfileResponse getProfile() {
        User user = getCurrentUser();
        return buildProfileResponse(user);
    }

    /**
     * Mettre à jour le profil de l'utilisateur
     */
    @Transactional
    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        User user = getCurrentUser();

        // Vérifier si le nouvel email est déjà utilisé par un autre utilisateur
        if (!user.getEmail().equals(request.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Cet email est déjà utilisé par un autre compte");
        }

        // Mettre à jour les informations
        user.setNom(request.getNom());
        user.setPrenom(request.getPrenom());
        user.setEmail(request.getEmail());
        user.setNiveau(request.getNiveau());

        user = userRepository.save(user);

        return buildProfileResponse(user);
    }

    /**
     * Changer le mot de passe
     */
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        User user = getCurrentUser();

        // Vérifier que l'ancien mot de passe est correct
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("L'ancien mot de passe est incorrect");
        }

        // Vérifier que le nouveau mot de passe est différent de l'ancien
        if (request.getOldPassword().equals(request.getNewPassword())) {
            throw new RuntimeException("Le nouveau mot de passe doit être différent de l'ancien");
        }

        // Mettre à jour le mot de passe
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    /**
     * Récupérer l'utilisateur connecté
     */
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Construire la réponse du profil
     */
    private ProfileResponse buildProfileResponse(User user) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        return ProfileResponse.builder()
                .id(user.getId())
                .nom(user.getNom())
                .prenom(user.getPrenom())
                .email(user.getEmail())
                .niveau(user.getNiveau())
                .role(user.getRole().name())
                .createdAt(user.getCreatedAt().format(formatter))
                .build();
    }
}
