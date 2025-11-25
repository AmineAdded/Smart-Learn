package com.example.controller;

import com.example.dto.*;
import com.example.dto.MessageResponse;
import com.example.dto.video.*;
import com.example.model.User;
import com.example.model.VideoPlaylist;
import com.example.model.VideoProgress;
import com.example.repository.UserRepository;
import com.example.service.VideoNoteService;
import com.example.service.VideoPlaylistService;
import com.example.service.VideoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/videos")
@Tag(name = "Vidéos", description = "Gestion de la bibliothèque de contenus vidéo")
@PreAuthorize("hasRole('USER')")
public class VideoController {

    @Autowired
    private VideoService videoService;

    @Autowired
    private VideoNoteService videoNoteService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private VideoPlaylistService playlistService;
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
            "Histoire", "Géographie", "Langues", "Informatique",
            "Philosophie", "Économie"
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
    @GetMapping("/favorites")
    @Operation(summary = "Vidéos favorites", 
               description = "Récupère toutes les vidéos favorites de l'utilisateur")
    public ResponseEntity<List<VideoDTO>> getFavorites() {
        List<VideoDTO> favorites = videoService.getFavoriteVideos();
        return ResponseEntity.ok(favorites);
    }

    /**
     * POST /api/videos/{id}/favorite - Ajouter aux favoris
     */
    @PostMapping("/{id}/favorite")
    @Operation(summary = "Ajouter aux favoris", 
               description = "Ajoute une vidéo aux favoris de l'utilisateur")
    public ResponseEntity<MessageResponse> addToFavorites(@PathVariable Long id) {
        videoService.addToFavorites(id);
        return ResponseEntity.ok(new MessageResponse("Vidéo ajoutée aux favoris"));
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
     * POST /api/videos/{id}/progress - Mettre à jour la progression
     * Sauvegarde la position actuelle et marque comme complété si nécessaire
     */
    @PostMapping("/{id}/progress")
    @Operation(summary = "Mettre à jour la progression", 
               description = "Sauvegarde la progression de visionnage (position, temps regardé, complétion)")
    public ResponseEntity<VideoProgress> updateProgress(
            @PathVariable Long id,
            @Valid @RequestBody VideoProgressRequest request) {
        
        VideoProgress progress = videoService.updateProgress(id, request);
        return ResponseEntity.ok(progress);
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
     * POST /api/videos/{id}/notes - Ajouter une note
     * Permet d'ajouter une annotation à un timestamp précis
     */
    @PostMapping("/{videoId}/notes")
    @Operation(summary = "Ajouter une note", 
               description = "Ajoute une note personnelle sur une vidéo (avec timestamp optionnel)")
    public ResponseEntity<VideoNoteDTO> addNote(
            @PathVariable Long videoId,
            @Valid @RequestBody VideoNoteRequest request) {
        
        VideoNoteDTO note = videoNoteService.addNote(videoId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(note);
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

    
/**
 * POST /api/videos/playlists - Créer une playlist
 */
@PostMapping("/playlists")
@Operation(summary = "Créer une playlist")
public ResponseEntity<VideoPlaylist> createPlaylist(
        @Valid @RequestBody CreatePlaylistRequest request) {
    User user = getCurrentUser();
    VideoPlaylist playlist = playlistService.createPlaylist(request, user);
    return ResponseEntity.status(HttpStatus.CREATED).body(playlist);
}

/**
 * GET /api/videos/playlists/my - Mes playlists
 */
@GetMapping("/playlists/my")
@Operation(summary = "Mes playlists")
public ResponseEntity<List<VideoPlaylist>> getMyPlaylists() {
    User user = getCurrentUser();
    List<VideoPlaylist> playlists = playlistService.getMyPlaylists(user);
    return ResponseEntity.ok(playlists);
}

/**
 * GET /api/videos/playlists/public - Playlists publiques
 */
@GetMapping("/playlists/public")
@Operation(summary = "Playlists publiques")
public ResponseEntity<List<VideoPlaylist>> getPublicPlaylists() {
    List<VideoPlaylist> playlists = playlistService.getPublicPlaylists();
    return ResponseEntity.ok(playlists);
}

/**
 * POST /api/videos/playlists/{playlistId}/videos/{videoId} - Ajouter vidéo
 */
@PostMapping("/playlists/{playlistId}/videos/{videoId}")
@Operation(summary = "Ajouter une vidéo à la playlist")
public ResponseEntity<MessageResponse> addVideoToPlaylist(
        @PathVariable Long playlistId,
        @PathVariable Long videoId) {
    User user = getCurrentUser();
    playlistService.addVideoToPlaylist(playlistId, videoId, user);
    return ResponseEntity.ok(new MessageResponse("Vidéo ajoutée à la playlist"));
}

/**
 * DELETE /api/videos/playlists/{playlistId}/videos/{videoId} - Retirer vidéo
 */
@DeleteMapping("/playlists/{playlistId}/videos/{videoId}")
@Operation(summary = "Retirer une vidéo de la playlist")
public ResponseEntity<MessageResponse> removeVideoFromPlaylist(
        @PathVariable Long playlistId,
        @PathVariable Long videoId) {
    User user = getCurrentUser();
    playlistService.removeVideoFromPlaylist(playlistId, videoId, user);
    return ResponseEntity.ok(new MessageResponse("Vidéo retirée de la playlist"));
}
}

