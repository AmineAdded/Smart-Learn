package com.example.service;

import com.example.model.*;
import com.example.repository.*;
import com.example.dto.video.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class VideoPlaylistService {

    @Autowired
    private VideoPlaylistRepository playlistRepository;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Créer une playlist personnelle
     */
    @Transactional
    public VideoPlaylist createPlaylist(CreatePlaylistRequest request, User creator) {
        VideoPlaylist playlist = VideoPlaylist.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .category(request.getCategory())
                .difficulty(request.getDifficulty())
                .creator(creator)
                .type(VideoPlaylist.PlaylistType.MANUAL)
                .isPublic(request.getIsPublic() != null ? request.getIsPublic() : false)
                .isActive(true)
                .videoCount(0)
                .build();

        return playlistRepository.save(playlist);
    }

    /**
     * Ajouter une vidéo à une playlist
     */
    @Transactional
    public void addVideoToPlaylist(Long playlistId, Long videoId, User user) {
        VideoPlaylist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist non trouvée"));

        // Vérifier les permissions
        if (!playlist.getCreator().getId().equals(user.getId())) {
            throw new RuntimeException("Vous n'avez pas la permission de modifier cette playlist");
        }

        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));

        playlist.addVideo(video, null);
        playlistRepository.save(playlist);

        log.info("✅ Vidéo {} ajoutée à la playlist {}", video.getTitle(), playlist.getTitle());
    }

    /**
     * Retirer une vidéo d'une playlist
     */
    @Transactional
    public void removeVideoFromPlaylist(Long playlistId, Long videoId, User user) {
        VideoPlaylist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist non trouvée"));

        if (!playlist.getCreator().getId().equals(user.getId())) {
            throw new RuntimeException("Permission refusée");
        }

        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));

        playlist.removeVideo(video);
        playlistRepository.save(playlist);
    }

    /**
     * Mes playlists
     */
    public List<VideoPlaylist> getMyPlaylists(User user) {
        return playlistRepository.findByCreatorAndIsActiveTrue(user);
    }

    /**
     * Playlists publiques
     */
    public List<VideoPlaylist> getPublicPlaylists() {
        return playlistRepository.findByIsPublicTrueAndIsActiveTrue();
    }

    /**
     * Générer une playlist automatique basée sur Khan Academy
     */
    @Transactional
    public VideoPlaylist generateAutoPlaylist(String category, List<Video> videos) {
        VideoPlaylist playlist = VideoPlaylist.builder()
                .title("Parcours " + category)
                .description("Playlist automatique générée pour " + category)
                .category(category)
                .difficulty("Moyen")
                .type(VideoPlaylist.PlaylistType.AUTO)
                .isPublic(true)
                .isActive(true)
                .isFeatured(true)
                .build();

        playlist = playlistRepository.save(playlist);

        // Ajouter les vidéos
        for (int i = 0; i < Math.min(videos.size(), 20); i++) {
            playlist.addVideo(videos.get(i), i);
        }

        return playlistRepository.save(playlist);
    }
}
