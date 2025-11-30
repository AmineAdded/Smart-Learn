package com.example.controller;

import com.example.dto.*;
import com.example.dto.MessageResponse;
import com.example.dto.video.*;
import com.example.model.User;
import com.example.model.Video;

import com.example.model.VideoProgress;
import com.example.repository.UserRepository;
import com.example.repository.VideoRepository;
import com.example.service.VideoNoteService;

import com.example.service.VideoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import com.example.service.KhanAcademyService;
import com.example.repository.VideoRepository;
import jakarta.validation.Valid;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/videos")
@Tag(name = "Vidéos", description = "Gestion de la bibliothèque de contenus vidéo")
@PreAuthorize("hasRole('USER')")
@Slf4j

public class VideoController {

    @Autowired
    private VideoService videoService;

    @Autowired
    private VideoNoteService videoNoteService;
    @Autowired
    private UserRepository userRepository;

    @Autowired
private KhanAcademyService khanAcademyService;

    @Autowired
    private VideoRepository videoRepository; 

        // ========== MÉTHODE UTILITAIRE ==========
    
    /**
     * Récupère l'utilisateur actuellement connecté
     */
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }
    // ========== BF-027 à BF-033 : Liste et Recherche des Vidéos ==========
   /**
     * DELETE /api/videos/clear-all - Supprimer toutes les vidéos (admin only)
     */
    @DeleteMapping("/clear-all")
    @Operation(summary = "Supprimer toutes les vidéos")
    public ResponseEntity<MessageResponse> clearAllVideos() {
        try {
            long count = videoRepository.count();
            videoRepository.deleteAll();
            return ResponseEntity.ok(
                new MessageResponse(count + " vidéos supprimées avec succès")
            );
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new MessageResponse("Erreur lors de la suppression: " + e.getMessage()));
        }
    }

/**
 * POST /api/videos/init-sample - Charger 8 vidéos d'exemple
 */
@PostMapping("/init-sample")
@Operation(summary = "Initialiser vidéos d'exemple")
public ResponseEntity<MessageResponse> initializeSampleVideos() {
    try {
        // Catégories pour les 8 vidéos
        List<String> categories = Arrays.asList(
            "Mathématiques", "Physique", "Chimie", "Biologie",
            "Français", "Anglais", "Informatique", "Histoire"
        );
        
        int imported = 0;
        for (String category : categories) {
            List<Video> videos = khanAcademyService.searchVideosByCategory(category, 1);
            imported += videos.size();
        }
        
        return ResponseEntity.ok(
            new MessageResponse(imported + " vidéos d'exemple importées avec succès")
        );
    } catch (Exception e) {
        log.error("❌ Erreur init-sample", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new MessageResponse("Erreur: " + e.getMessage()));
    }
}

/**
 * POST /api/videos/init-khan - Importer TOUTES les vidéos Khan Academy
 */
@PostMapping("/init-khan")
@Operation(summary = "Importer Khan Academy")
public ResponseEntity<Map<String, Object>> initializeKhanVideos() {
    try {
        log.info("🚀 Démarrage import Khan Academy COMPLET");
        
        Map<String, Integer> results = khanAcademyService.importAllCategories();
        
        int total = results.values().stream().mapToInt(Integer::intValue).sum();
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", total + " vidéos Khan Academy importées");
        response.put("details", results);
        response.put("total", total);
        
        return ResponseEntity.ok(response);
        
    } catch (Exception e) {
        log.error("❌ Erreur init-khan", e);
        Map<String, Object> error = new HashMap<>();
        error.put("message", "Erreur import Khan: " + e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

/**
 * GET /api/videos/khan/stats - Statistiques Khan Academy
 */
@GetMapping("/khan/stats")
@Operation(summary = "Statistiques base Khan Academy")
public ResponseEntity<Map<String, Object>> getKhanStats() {
    Map<String, Object> stats = khanAcademyService.getDatabaseStats();
    return ResponseEntity.ok(stats);
}

/**
 * GET /api/videos/khan/categories - Catégories Khan disponibles
 */
@GetMapping("/khan/categories")
@Operation(summary = "Catégories Khan Academy disponibles")
public ResponseEntity<List<String>> getKhanCategories() {
    List<String> categories = khanAcademyService.getAvailableCategories();
    return ResponseEntity.ok(categories);
}
    /**
     * GET /api/videos - Liste paginée des vidéos avec filtres et recherche
     * Supporte la recherche textuelle, filtres par catégorie/difficulté, tri
     */
    @GetMapping
    @Operation(summary = "Liste des vidéos", 
               description = "Récupère la liste paginée des vidéos avec options de recherche et filtrage")
    public ResponseEntity<VideoListResponse> listVideos(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false, defaultValue = "recent") String sortBy,
            @RequestParam(required = false, defaultValue = "0") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer size) {
        
        VideoSearchRequest request = VideoSearchRequest.builder()
                .query(query)
                .category(category)
                .difficulty(difficulty)
                .sortBy(sortBy)
                .page(page)
                .size(size)
                .build();
        
        VideoListResponse response = videoService.listVideos(request);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/videos/search - Recherche avancée via API YouTube
     * Intègre les résultats de l'API YouTube avec notre base de données
     */
    @GetMapping("/search")
    @Operation(summary = "Recherche YouTube", 
               description = "Recherche des vidéos via l'API YouTube")
    public ResponseEntity<VideoListResponse> searchYouTube(
            @RequestParam String q,
            @RequestParam(required = false) String category,
            @RequestParam(required = false, defaultValue = "0") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer size) {
        
        VideoSearchRequest request = VideoSearchRequest.builder()
                .query(q)
                .category(category)
                .page(page)
                .size(size)
                .build();
        
        VideoListResponse response = videoService.listVideos(request);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/videos/categories - Liste des catégories disponibles
     */
    @GetMapping("/categories")
    @Operation(summary = "Catégories", 
               description = "Liste toutes les catégories de vidéos disponibles")
    public ResponseEntity<List<String>> getCategories() {
        // Cette méthode devrait être ajoutée au VideoService
        return ResponseEntity.ok(List.of(
            "Mathématiques", "Physique", "Chimie", "Biologie",
          "Informatique","Français","Anglais"
        ));
    }

    // ========== BF-027 : Détails d'une Vidéo ==========

    /**
     * GET /api/videos/{id} - Détails complets d'une vidéo
     * Incrémente automatiquement le compteur de vues
     */
    @GetMapping("/{id}")
    @Operation(summary = "Détails d'une vidéo", 
               description = "Récupère les détails complets d'une vidéo et incrémente le compteur de vues")
    public ResponseEntity<VideoDTO> getVideoById(@PathVariable Long id) {
        VideoDTO video = videoService.getVideoById(id);
        return ResponseEntity.ok(video);
    }

    // ========== BF-028 : Système de Favoris ==========

    /**
     * GET /api/videos/favorites - Liste des vidéos favorites
     */
    // @GetMapping(value = "/favorites", produces = "application/json; charset=UTF-8")
    // @Operation(summary = "Récupérer les favoris", 
    //            description = "Liste toutes les vidéos favorites de l'utilisateur")
    // public ResponseEntity<List<VideoDTO>> getFavorites() {
    //     try {
    //         List<VideoDTO> favorites = videoService.getFavoriteVideos();
    //         log.info("📹 Renvoi de {} favoris", favorites.size());
    //         return ResponseEntity.ok(favorites);
    //     } catch (Exception e) {
    //         log.error("❌ Erreur getFavorites", e);
    //         return ResponseEntity
    //                 .status(HttpStatus.INTERNAL_SERVER_ERROR)
    //                 .build();
    //     }
    // }
@GetMapping(value = "/my-favorites", produces = MediaType.APPLICATION_JSON_VALUE)
@Operation(summary = "Récupérer les favoris")
public ResponseEntity<List<VideoDTO>> getFavorites() {
    List<VideoDTO> favorites = videoService.getFavoriteVideos();
    log.info("Envoi de {} favoris", favorites.size());
    
    return ResponseEntity.ok()
            .header("Content-Type", "application/json; charset=UTF-8")
            .body(favorites);
}

    // /**
    //  * POST /api/videos/{id}/favorite - Ajouter aux favoris
    //  */
    // @PostMapping("/{id}/favorite")
    // @Operation(summary = "Ajouter aux favoris", 
    //            description = "Ajoute une vidéo aux favoris de l'utilisateur")
    // public ResponseEntity<MessageResponse> addToFavorites(@PathVariable Long id) {
    //     videoService.addToFavorites(id);
    //     return ResponseEntity.ok(new MessageResponse("Vidéo ajoutée aux favoris"));
    // }
/**
 * POST /api/videos/{id}/favorite - Ajouter aux favoris + XP
 */
@PostMapping("/{id}/favorite")
@Operation(summary = "Ajouter aux favoris", 
           description = "Ajoute une vidéo aux favoris et gagne 5 XP")
public ResponseEntity<AddXpResponse> addToFavorites(@PathVariable Long id) {
    AddXpResponse response = videoService.addToFavorites(id);
    return ResponseEntity.ok(response);
}
    /**
     * DELETE /api/videos/{id}/favorite - Retirer des favoris
     */
    @DeleteMapping("/{id}/favorite")
    @Operation(summary = "Retirer des favoris", 
               description = "Retire une vidéo des favoris de l'utilisateur")
    public ResponseEntity<MessageResponse> removeFromFavorites(@PathVariable Long id) {
        videoService.removeFromFavorites(id);
        return ResponseEntity.ok(new MessageResponse("Vidéo retirée des favoris"));
    }

    // ========== BF-029 à BF-031 : Suivi de Progression ==========

/**
 * POST /api/videos/{id}/progress - Mettre à jour la progression + XP
 */
@PostMapping("/{id}/progress")
@Operation(summary = "Mettre à jour la progression", 
           description = "Sauvegarde la progression et donne 50 XP si complétée à 90%")
public ResponseEntity<VideoProgressResponse> updateProgress(
        @PathVariable Long id,
        @Valid @RequestBody VideoProgressRequest request) {
    
    VideoProgressResponse response = videoService.updateProgress(id, request);
    return ResponseEntity.ok(response);
}


    /**
     * GET /api/videos/recent - Vidéos récemment regardées
     * Historique de visionnage avec reprise possible
     */
    @GetMapping("/recent")
    @Operation(summary = "Vidéos récentes", 
               description = "Récupère l'historique des vidéos récemment regardées")
    public ResponseEntity<List<VideoDTO>> getRecentlyWatched() {
        List<VideoDTO> recent = videoService.getRecentlyWatched();
        return ResponseEntity.ok(recent);
    }

    // ========== BF-032 : Recommandations Personnalisées ==========

    /**
     * GET /api/videos/recommendations - Recommandations basées sur l'IA
     * Suggestions personnalisées selon niveau, intérêts et historique
     */
    @GetMapping("/recommendations")
    @Operation(summary = "Recommandations", 
               description = "Obtient des recommandations personnalisées basées sur le profil et l'historique")
    public ResponseEntity<VideoRecommendationsResponse> getRecommendations() {
        VideoRecommendationsResponse recommendations = videoService.getRecommendations();
        return ResponseEntity.ok(recommendations);
    }

    // ========== BF-034 : Notes Personnelles sur les Vidéos ==========

    /**
     * GET /api/videos/{id}/notes - Toutes les notes d'une vidéo
     * Permet de retrouver toutes les annotations sur une vidéo
     */
    @GetMapping("/{videoId}/notes")
    @Operation(summary = "Notes de la vidéo", 
               description = "Récupère toutes les notes de l'utilisateur pour une vidéo")
    public ResponseEntity<List<VideoNoteDTO>> getNotesByVideo(@PathVariable Long videoId) {
        List<VideoNoteDTO> notes = videoNoteService.getNotesByVideo(videoId);
        return ResponseEntity.ok(notes);
    }
/**
 * POST /api/videos/{videoId}/notes - Ajouter une note + XP
 */
@PostMapping("/{videoId}/notes")
@Operation(summary = "Ajouter une note", 
           description = "Ajoute une note personnelle et gagne 10 XP")
public ResponseEntity<VideoNoteResponse> addNote(
        @PathVariable Long videoId,
        @Valid @RequestBody VideoNoteRequest request) {
    
    VideoNoteResponse response = videoNoteService.addNote(videoId, request);
    return ResponseEntity.status(HttpStatus.CREATED).body(response);
}
    /**
     * PUT /api/videos/notes/{noteId} - Modifier une note
     */
    @PutMapping("/notes/{noteId}")
    @Operation(summary = "Modifier une note", 
               description = "Modifie le contenu ou le timestamp d'une note existante")
    public ResponseEntity<VideoNoteDTO> updateNote(
            @PathVariable Long noteId,
            @Valid @RequestBody VideoNoteRequest request) {
        
        VideoNoteDTO note = videoNoteService.updateNote(noteId, request);
        return ResponseEntity.ok(note);
    }

    /**
     * DELETE /api/videos/notes/{noteId} - Supprimer une note
     */
    @DeleteMapping("/notes/{noteId}")
    @Operation(summary = "Supprimer une note", 
               description = "Supprime une note personnelle")
    public ResponseEntity<MessageResponse> deleteNote(@PathVariable Long noteId) {
        videoNoteService.deleteNote(noteId);
        return ResponseEntity.ok(new MessageResponse("Note supprimée avec succès"));
    }

    /**
     * GET /api/videos/notes - Toutes les notes de l'utilisateur
     * Vue globale de toutes les annotations sur toutes les vidéos
     */
    @GetMapping("/notes")
    @Operation(summary = "Toutes les notes", 
               description = "Récupère toutes les notes de l'utilisateur sur toutes les vidéos")
    public ResponseEntity<List<VideoNoteDTO>> getAllUserNotes() {
        List<VideoNoteDTO> notes = videoNoteService.getAllUserNotes();
        return ResponseEntity.ok(notes);
    }

    // ========== BF-033 : Statistiques Vidéos ==========

    /**
     * GET /api/videos/stats - Statistiques de visionnage
     * Vue d'ensemble de l'activité vidéo de l'utilisateur
     */
    @GetMapping("/stats")
    @Operation(summary = "Statistiques vidéos", 
               description = "Récupère les statistiques de visionnage de l'utilisateur")
    public ResponseEntity<VideoStatsDTO> getVideoStats() {
        VideoStatsDTO stats = videoService.getUserVideoStats();
        return ResponseEntity.ok(stats);
    }

    // ========== Gestion des Erreurs ==========

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(RuntimeException e) {
        ErrorResponse error = ErrorResponse.builder()
                .message(e.getMessage())
                .status(HttpStatus.BAD_REQUEST.value())
                .build();
        return ResponseEntity.badRequest().body(error);
    }

    



}

