package com.example.repository;


import com.example.model.User;
import com.example.model.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserProgressRepository extends JpaRepository<UserProgress, Long> {
    
    Optional<UserProgress> findByUser(User user);
    
    Optional<UserProgress> findByUserId(Long userId);
    
    @Query("SELECT COUNT(up) FROM UserProgress up WHERE up.totalXp > :xp")
    Long countUsersWithMoreXp(@Param("xp") Integer xp);
    
    @Query("SELECT COUNT(up) FROM UserProgress up")
    Long countTotalUsers();
    
    @Query("SELECT up FROM UserProgress up ORDER BY up.totalXp DESC")
    java.util.List<UserProgress> findTopUsersByXp(org.springframework.data.domain.Pageable pageable);
}