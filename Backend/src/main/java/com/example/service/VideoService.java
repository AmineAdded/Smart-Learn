package com.example.service;

import com.example.dto.*;
import com.example.dto.video.*;
import com.example.model.*;
import com.example.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class VideoService {

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private VideoProgressRepository progressRepository;

    @Autowired
private final VideoFavoriteRepository favoriteRepository;     // ← maintenant injecté !
    @Autowired
    private VideoNoteRepository noteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserInterestRepository interestRepository;

    @Autowired
    private ProgressService progressService;
    @Autowired
    private UserProgressRepository userProgressRepository;


    // 🎯 CONSTANTES XP
    private static final int XP_VIDEO_COMPLETED = 50;
    private static final int XP_NOTE_ADDED = 10;
    private static final int XP_FAVORITE_ADDED = 5;
    private static final int XP_MILESTONE_5_VIDEOS = 100;
    private static final int MILESTONE_5_VIDEOS = 5;

    /**
     * Récupérer l'utilisateur connecté
     */
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Lister les vidéos avec filtres et pagination
     */
    public VideoListResponse listVideos(VideoSearchRequest request) {
        User user = getCurrentUser();
        
        int page = request.getPage() != null ? request.getPage() : 0;
        int size = request.getSize() != null ? request.getSize() : 20;
        
        Sort sort = Sort.by(Sort.Direction.DESC, "createdAt");
        if ("popular".equals(request.getSortBy())) {
            sort = Sort.by(Sort.Direction.DESC, "viewCount");
        } else if ("duration".equals(request.getSortBy())) {
            sort = Sort.by(Sort.Direction.ASC, "duration");
        }
        
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Video> videoPage;
        
        if (request.getQuery() != null && !request.getQuery().isEmpty()) {
            videoPage = videoRepository.searchVideos(request.getQuery(), pageable);
        } else if (request.getCategory() != null && request.getDifficulty() != null) {
            videoPage = videoRepository.findByCategoryAndDifficulty(
                request.getCategory(), request.getDifficulty(), pageable
            );
        } else if (request.getCategory() != null) {
            videoPage = videoRepository.findByCategory(request.getCategory(), pageable);
        } else {
            videoPage = videoRepository.findByIsActiveTrue(pageable);
        }
        
        List<VideoDTO> videoDTOs = videoPage.getContent().stream()
                .map(video -> convertToDTO(video, user))
                .collect(Collectors.toList());
        
        return VideoListResponse.builder()
                .videos(videoDTOs)
                .currentPage(videoPage.getNumber())
                .totalPages(videoPage.getTotalPages())
                .totalVideos(videoPage.getTotalElements())
                .hasNext(videoPage.hasNext())
                .hasPrevious(videoPage.hasPrevious())
                .build();
    }

    /**
     * Récupérer une vidéo par ID
     */
    public VideoDTO getVideoById(Long id) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
        
        video.setViewCount(video.getViewCount() + 1);
        videoRepository.save(video);
        
        return convertToDTO(video, user);
    }

    /**
     * Récupérer les vidéos favorites
     */
public List<VideoDTO> getFavoriteVideos() {
    User currentUser = getCurrentUser();

    return favoriteRepository.findByUserOrderByAddedAtDesc(currentUser)
            .stream()
            .map(VideoFavorite::getVideo)
            .map(video -> convertToDTO(video, currentUser))  // ← utilise la méthode qui prend 2 paramètres
            .collect(Collectors.toList());
}

    /**
     * 🆕 Ajouter une vidéo aux favoris + XP
     */
    @Transactional
    public AddXpResponse addToFavorites(Long videoId) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
        
        if (favoriteRepository.existsByUserAndVideo(user, video)) {
            throw new RuntimeException("Vidéo déjà dans les favoris");
        }
        
        VideoFavorite favorite = VideoFavorite.builder()
                .user(user)
                .video(video)
                .build();
        
        favoriteRepository.save(favorite);
        
        video.setFavoriteCount(video.getFavoriteCount() + 1);
        videoRepository.save(video);
        
        // 🎯 AJOUTER XP
        log.info("⭐ Ajout aux favoris - Attribution de {} XP", XP_FAVORITE_ADDED);
        AddXpResponse xpResponse = progressService.addXp(
            XP_FAVORITE_ADDED,
            "Vidéo ajoutée aux favoris: " + video.getTitle(),
            "FAVORITE_ADDED"
        );
        
        return xpResponse;
    }

    /**
     * Retirer une vidéo des favoris
     */
    @Transactional
    public void removeFromFavorites(Long videoId) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
        
        favoriteRepository.deleteByUserAndVideo(user, video);
        
        video.setFavoriteCount(Math.max(0, video.getFavoriteCount() - 1));
        videoRepository.save(video);
    }

     /**
 * 🆕 Mettre à jour la progression de visionnage + XP si complété
 */
@Transactional
public VideoProgressResponse updateProgress(Long videoId, VideoProgressRequest request) {
    User user = getCurrentUser();
    Video video = videoRepository.findById(videoId)
            .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
    
    log.info("📹 UPDATE PROGRESS - User: {}, Video ID: {}, Title: {}", 
        user.getEmail(), video.getId(), video.getTitle());
    log.info("📹 Request - Timestamp: {}, Completed: {}", 
        request.getCurrentTimestamp(), request.getCompleted());
    log.info("📹 Video Duration: {} secondes", video.getDuration());
    
    // ✅ CORRECTION : Récupérer ou créer la progression
    VideoProgress progress = progressRepository.findByUserAndVideo(user, video)
            .orElseGet(() -> {
                log.info("🆕 CRÉATION nouvelle progression");
                VideoProgress newProgress = VideoProgress.builder()
                        .user(user)
                        .video(video)
                        .lastTimestamp(0)
                        .progressPercentage(0.0)
                        .completed(false)
                        .watchCount(1)
                        .watchedSeconds(0)
                        .build();
                // ✅ Initialiser lastWatchedAt manuellement car pas de @Builder.Default
                newProgress.setLastWatchedAt(LocalDateTime.now());
                return newProgress;
            });
    
    // Sauvegarder l'état avant modification
    boolean wasCompleted = progress.getCompleted() != null && progress.getCompleted();
    
    log.info("📊 AVANT - ID: {}, Completed: {}, Percentage: {}%, Timestamp: {}s", 
        progress.getId(), wasCompleted, progress.getProgressPercentage(), progress.getLastTimestamp());
    
    // Mettre à jour la progression
    progress.updateProgress(request.getCurrentTimestamp(), video.getDuration());
    
    // Complétion manuelle si demandée
    if (request.getCompleted() != null && request.getCompleted()) {
        progress.setCompleted(true);
        progress.setProgressPercentage(100.0);
        log.info("✅ Complétion MANUELLE forcée");
    }
    
    boolean autoCompleted = progress.getProgressPercentage() >= 90.0 && !wasCompleted;
    if (autoCompleted) {
        progress.setCompleted(true);
        log.info("✅ Complétion AUTOMATIQUE à {}%", progress.getProgressPercentage());
    }
    
    log.info("📊 APRÈS - Completed: {}, Percentage: {}%, Timestamp: {}s", 
        progress.getCompleted(), progress.getProgressPercentage(), progress.getLastTimestamp());
    
    // ✅ CORRECTION : S'assurer que lastWatchedAt est toujours défini
    if (progress.getLastWatchedAt() == null) {
        progress.setLastWatchedAt(LocalDateTime.now());
        log.warn("⚠️ lastWatchedAt était null, initialisé à now()");
    }
    
    // 💾 SAUVEGARDE EN BASE
    try {
        VideoProgress savedProgress = progressRepository.save(progress);
        log.info("✅ ✅ ✅ PROGRESSION SAUVEGARDÉE - ID: {}", savedProgress.getId());
        UserProgress userProgress = progressService.getOrCreateUserProgress(user);
    // Si vidéo complétée pour la première fois, incrémenter le compteur
    if ((autoCompleted || (request.getCompleted() != null && request.getCompleted())) && !wasCompleted) {
        userProgress.setVideosWatched(userProgress.getVideosWatched() + 1);
        
        // Ajouter le temps de visionnage (en minutes)
        int watchTimeMinutes = video.getDuration() / 60;
        userProgress.setTotalStudyTimeMinutes(
            userProgress.getTotalStudyTimeMinutes() + watchTimeMinutes
        );
        
        progressService.updateStreak(userProgress);
        userProgressRepository.save(userProgress);
    }
        // ✅ Vérifier immédiatement en base
        VideoProgress verif = progressRepository.findById(savedProgress.getId()).orElse(null);
        if (verif != null) {
            log.info("✅ VÉRIFICATION - Timestamp en base: {}s, Percentage: {}%, lastWatchedAt: {}", 
                verif.getLastTimestamp(), verif.getProgressPercentage(), verif.getLastWatchedAt());
        } else {
            log.error("❌ ERREUR - Progression introuvable après save!");
        }
        
    } catch (Exception e) {
        log.error("❌ ❌ ❌ ERREUR SAUVEGARDE: {}", e.getMessage(), e);
        throw new RuntimeException("Impossible de sauvegarder la progression: " + e.getMessage());
    }
    
    // 🎯 ATTRIBUTION XP SI VIDÉO COMPLÉTÉE
    AddXpResponse xpResponse = null;
    boolean isNowCompleted = progress.getCompleted() != null && progress.getCompleted();
    
    if ((isNowCompleted && !wasCompleted) || autoCompleted) {
        log.info("🎥 VIDÉO COMPLÉTÉE - Attribution de {} XP", XP_VIDEO_COMPLETED);
        xpResponse = progressService.addXp(
            XP_VIDEO_COMPLETED,
            "Vidéo complétée: " + video.getTitle(),
            "VIDEO_COMPLETED"
        );
        
        // 🎯 VÉRIFIER MILESTONE 5 VIDÉOS
        Integer completedCount = progressRepository.countCompletedByUserId(user.getId());
        if (completedCount != null && completedCount % MILESTONE_5_VIDEOS == 0) {
            log.info("🎯 MILESTONE! {} vidéos complétées - Bonus {} XP", 
                completedCount, XP_MILESTONE_5_VIDEOS);
            xpResponse = progressService.addXp(
                XP_MILESTONE_5_VIDEOS,
                String.format("Milestone: %d vidéos complétées!", completedCount),
                "VIDEO_MILESTONE"
            );
        }
    }
    
    return VideoProgressResponse.builder()
            .progress(progress)
            .xpResponse(xpResponse)
            .videoCompleted(isNowCompleted && !wasCompleted)
            .milestoneReached(xpResponse != null && xpResponse.getMessage().contains("Milestone"))
            .build();
}
    /**
     * Récupérer les vidéos récemment regardées
     */
    public List<VideoDTO> getRecentlyWatched() {
        User user = getCurrentUser();
        Pageable pageable = PageRequest.of(0, 10);
        List<VideoProgress> recent = progressRepository.findRecentByUserId(user.getId(), pageable);
        
        return recent.stream()
                .map(progress -> convertToDTO(progress.getVideo(), user))
                .collect(Collectors.toList());
    }

    /**
     * Récupérer les recommandations basées sur l'IA
     */
    public VideoRecommendationsResponse getRecommendations() {
        User user = getCurrentUser();
        
        List<UserInterest> interests = interestRepository.findByUserAndIsActiveTrue(user);
        List<String> categories = interests.stream()
                .map(UserInterest::getCategory)
                .collect(Collectors.toList());
        
        if (categories.isEmpty()) {
            Pageable pageable = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "viewCount"));
            Page<Video> popular = videoRepository.findByIsActiveTrue(pageable);
            
            List<VideoDTO> videoDTOs = popular.getContent().stream()
                    .map(video -> convertToDTO(video, user))
                    .collect(Collectors.toList());
            
            return VideoRecommendationsResponse.builder()
                    .recommended(videoDTOs)
                    .reason("Vidéos populaires")
                    .totalRecommendations(videoDTOs.size())
                    .build();
        }
        
        List<Video> recommended = videoRepository.findAll().stream()
                .filter(video -> categories.contains(video.getCategory()))
                .filter(video -> video.getDifficulty().equals(user.getNiveau()) || 
                               video.getDifficulty().equals("Moyen"))
                .limit(10)
                .collect(Collectors.toList());
        
        List<VideoDTO> videoDTOs = recommended.stream()
                .map(video -> convertToDTO(video, user))
                .collect(Collectors.toList());
        
        return VideoRecommendationsResponse.builder()
                .recommended(videoDTOs)
                .reason("Basé sur vos intérêts: " + String.join(", ", categories))
                .totalRecommendations(videoDTOs.size())
                .build();
    }

    /**
     * Statistiques vidéos de l'utilisateur
     */
    public VideoStatsDTO getUserVideoStats() {
        User user = getCurrentUser();
        
        List<VideoProgress> allProgress = progressRepository.findByUserOrderByLastWatchedAtDesc(user);
        
        Integer totalWatchTime = progressRepository.getTotalWatchTimeByUserId(user.getId());
        Integer totalMinutes = totalWatchTime != null ? totalWatchTime / 60 : 0;
        
        Integer completedCount = progressRepository.countCompletedByUserId(user.getId());
        Integer favoritesCount = favoriteRepository.countByUserId(user.getId());
        
        return VideoStatsDTO.builder()
                .totalVideosWatched(allProgress.size())
                .totalWatchTimeMinutes(totalMinutes)
                .favoritesCount(favoritesCount)
                .completedCount(completedCount)
                .build();
    }

    /**
     * Convertir Video en VideoDTO
     */
    public VideoDTO convertToDTO(Video video, User user) {
        VideoProgress progress = progressRepository.findByUserAndVideo(user, video).orElse(null);
        boolean isFavorite = favoriteRepository.existsByUserAndVideo(user, video);
        
        return VideoDTO.builder()
                .id(video.getId())
                .youtubeId(video.getYoutubeId())
                .title(video.getTitle())
                .description(video.getDescription())
                .thumbnailUrl(video.getThumbnailUrl())
                .channelTitle(video.getChannelTitle())
                .duration(video.getDuration())
                .formattedDuration(video.getFormattedDuration())
                .category(video.getCategory())
                .difficulty(video.getDifficulty())
                .viewCount(video.getViewCount())
                .favoriteCount(video.getFavoriteCount())
                .tags(video.getTagsList())
                .isFavorite(isFavorite)
                .isWatched(progress != null)
                .progressPercentage(progress != null ? progress.getProgressPercentage() : 0.0)
                .lastTimestamp(progress != null ? progress.getLastTimestamp() : 0)
                .createdAt(video.getCreatedAt())
                .build();
    }
}