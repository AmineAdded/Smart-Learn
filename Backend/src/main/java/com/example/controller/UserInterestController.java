package com.example.controller;

import com.example.dto.*;
import com.example.service.UserInterestService;
import jakarta.validation.Valid;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/interests")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserInterestController {

    @Autowired
    private UserInterestService interestService;

    /**
     * GET /api/interests
     * Récupère les intérêts de l'utilisateur connecté
     */
    @GetMapping
    public ResponseEntity<?> getUserInterests() {
        try {
            UserInterestsDTO interests = interestService.getUserInterests();
            return ResponseEntity.ok(interests);
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les intérêts: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/interests/available
     * Récupère toutes les catégories disponibles avec leur statut
     */
    @GetMapping("/available")
    public ResponseEntity<?> getAvailableCategories() {
        try {
            AvailableCategoriesDTO categories = interestService.getAvailableCategories();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les catégories: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * POST /api/interests
     * Sauvegarde les intérêts de l'utilisateur
     */
    @PostMapping
    public ResponseEntity<?> saveUserInterests(@Valid @RequestBody SaveInterestsRequest request) {
        try {
            SaveInterestsResponse response = interestService.saveUserInterests(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Données invalides")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de sauvegarder les intérêts: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * POST /api/interests/add
     * Ajoute un seul intérêt
     */
    @PostMapping("/add")
    public ResponseEntity<?> addInterest(@RequestBody AddInterestRequest request) {
        try {
            SaveInterestsResponse response = interestService.addInterest(request.getCategory());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible d'ajouter l'intérêt: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * DELETE /api/interests/remove
     * Supprime un intérêt
     */
    @DeleteMapping("/remove")
    public ResponseEntity<?> removeInterest(@RequestBody RemoveInterestRequest request) {
        try {
            interestService.removeInterest(request.getCategory());
            return ResponseEntity.ok(new SuccessResponse(true, "Intérêt supprimé avec succès"));
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de supprimer l'intérêt: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/interests/check
     * Vérifie si l'utilisateur a des intérêts configurés
     */
    @GetMapping("/check")
    public ResponseEntity<?> checkHasInterests() {
        try {
            boolean hasInterests = interestService.hasInterests();
            return ResponseEntity.ok(new HasInterestsResponse(hasInterests));
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de vérifier les intérêts: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }
}

// Classes pour les requêtes simples
@Setter
@Getter
class AddInterestRequest {
    private String category;

}

@Setter
@Getter
class RemoveInterestRequest {
    private String category;

}

@Setter
@Getter
class HasInterestsResponse {
    private boolean hasInterests;

    public HasInterestsResponse(boolean hasInterests) {
        this.hasInterests = hasInterests;
    }

}

@Setter
@Getter
class SuccessResponse {
    private boolean success;
    private String message;

    public SuccessResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

}