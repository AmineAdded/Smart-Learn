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

import java.util.List;
import java.util.stream.Collectors;

@Service
public class VideoService {

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private VideoProgressRepository progressRepository;

    @Autowired
    private VideoFavoriteRepository favoriteRepository;

    @Autowired
    private VideoNoteRepository noteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserInterestRepository interestRepository;

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
        
        // Tri par défaut : récent
        Sort sort = Sort.by(Sort.Direction.DESC, "createdAt");
        if ("popular".equals(request.getSortBy())) {
            sort = Sort.by(Sort.Direction.DESC, "viewCount");
        } else if ("duration".equals(request.getSortBy())) {
            sort = Sort.by(Sort.Direction.ASC, "duration");
        }
        
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Video> videoPage;
        
        // Appliquer les filtres
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
        
        // Convertir en DTO
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
        
        // Incrémenter le compteur de vues
        video.setViewCount(video.getViewCount() + 1);
        videoRepository.save(video);
        
        return convertToDTO(video, user);
    }

    /**
     * Récupérer les vidéos favorites
     */
    public List<VideoDTO> getFavoriteVideos() {
        User user = getCurrentUser();
        List<VideoFavorite> favorites = favoriteRepository.findByUserOrderByAddedAtDesc(user);
        
        return favorites.stream()
                .map(fav -> convertToDTO(fav.getVideo(), user))
                .collect(Collectors.toList());
    }

    /**
     * Ajouter une vidéo aux favoris
     */
    @Transactional
    public void addToFavorites(Long videoId) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
        
        // Vérifier si déjà en favori
        if (favoriteRepository.existsByUserAndVideo(user, video)) {
            throw new RuntimeException("Vidéo déjà dans les favoris");
        }
        
        VideoFavorite favorite = VideoFavorite.builder()
                .user(user)
                .video(video)
                .build();
        
        favoriteRepository.save(favorite);
        
        // Incrémenter le compteur
        video.setFavoriteCount(video.getFavoriteCount() + 1);
        videoRepository.save(video);
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
        
        // Décrémenter le compteur
        video.setFavoriteCount(Math.max(0, video.getFavoriteCount() - 1));
        videoRepository.save(video);
    }

    /**
     * Mettre à jour la progression de visionnage
     */
    @Transactional
    public VideoProgress updateProgress(Long videoId, VideoProgressRequest request) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));
        
        VideoProgress progress = progressRepository.findByUserAndVideo(user, video)
                .orElseGet(() -> VideoProgress.builder()
                        .user(user)
                        .video(video)
                        .build());
        
        // Mettre à jour la progression
        progress.updateProgress(request.getCurrentTimestamp(), video.getDuration());
        
        if (request.getCompleted() != null && request.getCompleted()) {
            progress.setCompleted(true);
            progress.setProgressPercentage(100.0);
        }
        
        return progressRepository.save(progress);
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
        
        // Récupérer les intérêts de l'utilisateur
        List<UserInterest> interests = interestRepository.findByUserAndIsActiveTrue(user);
        List<String> categories = interests.stream()
                .map(UserInterest::getCategory)
                .collect(Collectors.toList());
        
        // Si pas d'intérêts, retourner les vidéos populaires
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
        
        // Recommandations basées sur les intérêts
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