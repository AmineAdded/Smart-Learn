package com.example.repository;

import com.example.model.*;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VideoFavoriteRepository extends JpaRepository<VideoFavorite, Long> {
    
    Optional<VideoFavorite> findByUserAndVideo(User user, Video video);
    
    List<VideoFavorite> findByUserOrderByAddedAtDesc(User user);
    
    boolean existsByUserAndVideo(User user, Video video);
    
    void deleteByUserAndVideo(User user, Video video);
    
    @Query("SELECT COUNT(vf) FROM VideoFavorite vf WHERE vf.user.id = :userId")
    Integer countByUserId(@Param("userId") Long userId);
}