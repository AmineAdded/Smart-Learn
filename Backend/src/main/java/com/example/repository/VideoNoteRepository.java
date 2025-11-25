package com.example.repository;

import com.example.model.*;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VideoNoteRepository extends JpaRepository<VideoNote, Long> {
    
    List<VideoNote> findByUserAndVideoOrderByTimestampAsc(User user, Video video);
    
    List<VideoNote> findByUserOrderByCreatedAtDesc(User user);
    
    Optional<VideoNote> findByIdAndUser(Long id, User user);
    
    @Query("SELECT COUNT(vn) FROM VideoNote vn WHERE vn.user.id = :userId AND vn.video.id = :videoId")
    Integer countByUserIdAndVideoId(@Param("userId") Long userId, @Param("videoId") Long videoId);
}
