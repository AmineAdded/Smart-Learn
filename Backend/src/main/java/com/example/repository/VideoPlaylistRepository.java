package com.example.repository;

import com.example.model.VideoPlaylist;
import com.example.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VideoPlaylistRepository extends JpaRepository<VideoPlaylist, Long> {
    List<VideoPlaylist> findByCreatorAndIsActiveTrue(User creator);
    List<VideoPlaylist> findByIsPublicTrueAndIsActiveTrue();
    List<VideoPlaylist> findByCategoryAndIsPublicTrue(String category);
    List<VideoPlaylist> findByIsFeaturedTrue();
}
