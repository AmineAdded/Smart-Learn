package com.example.repository;

import com.example.model.*;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VideoProgressRepository extends JpaRepository<VideoProgress, Long> {
    
    Optional<VideoProgress> findByUserAndVideo(User user, Video video);
    
    List<VideoProgress> findByUserOrderByLastWatchedAtDesc(User user);
    
    List<VideoProgress> findByUserAndCompletedTrue(User user);
    
    @Query("SELECT vp FROM VideoProgress vp WHERE vp.user.id = :userId " +
           "ORDER BY vp.lastWatchedAt DESC")
    List<VideoProgress> findRecentByUserId(@Param("userId") Long userId, Pageable pageable);
    
    @Query("SELECT COUNT(vp) FROM VideoProgress vp WHERE vp.user.id = :userId AND vp.completed = true")
    Integer countCompletedByUserId(@Param("userId") Long userId);
    
    @Query("SELECT SUM(vp.watchedSeconds) FROM VideoProgress vp WHERE vp.user.id = :userId")
    Integer getTotalWatchTimeByUserId(@Param("userId") Long userId);
}
