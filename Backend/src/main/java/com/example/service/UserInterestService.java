package com.example.service;

import com.example.dto.*;
import com.example.model.User;
import com.example.model.UserInterest;
import com.example.repository.UserInterestRepository;
import com.example.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class UserInterestService {

    @Autowired
    private UserInterestRepository interestRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupère l'utilisateur connecté
     */
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Sauvegarde ou met à jour les intérêts d'un utilisateur
     */
    @Transactional
    public SaveInterestsResponse saveUserInterests(SaveInterestsRequest request) {
        User user = getCurrentUser();

        // Désactive tous les intérêts existants
        interestRepository.deactivateAllByUser(user);

        // Crée ou réactive les nouveaux intérêts
        List<String> savedInterests = new ArrayList<>();
        for (String category : request.getCategories()) {
            Optional<UserInterest> existing = interestRepository.findByUserAndCategory(user, category);

            if (existing.isPresent()) {
                // Réactive l'intérêt existant
                UserInterest interest = existing.get();
                interest.setIsActive(true);
                interestRepository.save(interest);
            } else {
                // Crée un nouvel intérêt
                UserInterest newInterest = UserInterest.builder()
                        .user(user)
                        .category(category)
                        .isActive(true)
                        .build();
                interestRepository.save(newInterest);
            }
            savedInterests.add(category);
        }

        return SaveInterestsResponse.builder()
                .success(true)
                .message("Domaines d'intérêt sauvegardés avec succès")
                .savedInterests(savedInterests)
                .totalInterests(savedInterests.size())
                .build();
    }

    /**
     * Récupère les intérêts actifs de l'utilisateur connecté
     */
    public UserInterestsDTO getUserInterests() {
        User user = getCurrentUser();
        List<UserInterest> interests = interestRepository.findByUserAndIsActiveTrue(user);

        List<String> interestNames = interests.stream()
                .map(UserInterest::getCategory)
                .collect(Collectors.toList());

        return UserInterestsDTO.builder()
                .userId(user.getId())
                .interests(interestNames)
                .totalInterests(interestNames.size())
                .hasInterests(!interestNames.isEmpty())
                .build();
    }

    /**
     * Récupère toutes les catégories disponibles avec leur statut de sélection
     */
    public AvailableCategoriesDTO getAvailableCategories() {
        User user = getCurrentUser();
        List<UserInterest> userInterests = interestRepository.findByUserAndIsActiveTrue(user);
        Set<String> selectedCategories = userInterests.stream()
                .map(UserInterest::getCategory)
                .collect(Collectors.toSet());

        List<AvailableCategoriesDTO.CategoryInfo> categories = Arrays.stream(getCategoryDefinitions())
                .map(def -> AvailableCategoriesDTO.CategoryInfo.builder()
                        .name(def.name)
                        .icon(def.icon)
                        .description(def.description)
                        .isSelected(selectedCategories.contains(def.name))
                        .build())
                .collect(Collectors.toList());

        return AvailableCategoriesDTO.builder()
                .categories(categories)
                .totalCategories(categories.size())
                .build();
    }

    /**
     * Ajoute un seul intérêt
     */
    @Transactional
    public SaveInterestsResponse addInterest(String category) {
        User user = getCurrentUser();

        Optional<UserInterest> existing = interestRepository.findByUserAndCategory(user, category);

        if (existing.isPresent()) {
            UserInterest interest = existing.get();
            interest.setIsActive(true);
            interestRepository.save(interest);
        } else {
            UserInterest newInterest = UserInterest.builder()
                    .user(user)
                    .category(category)
                    .isActive(true)
                    .build();
            interestRepository.save(newInterest);
        }

        return SaveInterestsResponse.builder()
                .success(true)
                .message("Intérêt ajouté avec succès")
                .savedInterests(List.of(category))
                .totalInterests(1)
                .build();
    }

    /**
     * Supprime un intérêt
     */
    @Transactional
    public void removeInterest(String category) {
        User user = getCurrentUser();
        Optional<UserInterest> interest = interestRepository.findByUserAndCategory(user, category);

        interest.ifPresent(i -> {
            i.setIsActive(false);
            interestRepository.save(i);
        });
    }

    /**
     * Vérifie si l'utilisateur a des intérêts configurés
     */
    public boolean hasInterests() {
        User user = getCurrentUser();
        return interestRepository.existsByUserAndIsActiveTrue(user);
    }

    // Définitions des catégories avec icônes et descriptions
    private CategoryDefinition[] getCategoryDefinitions() {
        return new CategoryDefinition[]{
                new CategoryDefinition("Mathématiques", "🔢", "Algèbre, géométrie, analyse"),
                new CategoryDefinition("Sciences", "🔬", "Sciences générales"),
                new CategoryDefinition("Physique", "⚛️", "Mécanique, électricité, optique"),
                new CategoryDefinition("Chimie", "🧪", "Chimie organique et inorganique"),
                new CategoryDefinition("Biologie", "🧬", "Sciences de la vie"),
                new CategoryDefinition("Langues", "🗣️", "Langues étrangères"),
                new CategoryDefinition("Français", "📖", "Langue française et littérature"),
                new CategoryDefinition("Anglais", "🇬🇧", "Langue anglaise"),
                new CategoryDefinition("Espagnol", "🇪🇸", "Langue espagnole"),
                new CategoryDefinition("Histoire", "📜", "Histoire et civilisations"),
                new CategoryDefinition("Géographie", "🌍", "Géographie mondiale"),
                new CategoryDefinition("Philosophie", "💭", "Pensée et philosophie"),
                new CategoryDefinition("Informatique", "💻", "Programmation et technologies"),
                new CategoryDefinition("Économie", "💰", "Économie et gestion"),
                new CategoryDefinition("Arts", "🎨", "Arts plastiques et visuels"),
                new CategoryDefinition("Musique", "🎵", "Théorie musicale et pratique"),
                new CategoryDefinition("Sport", "⚽", "Éducation physique et sportive")
        };
    }

    private static class CategoryDefinition {
        String name;
        String icon;
        String description;

        CategoryDefinition(String name, String icon, String description) {
            this.name = name;
            this.icon = icon;
            this.description = description;
        }
    }
}