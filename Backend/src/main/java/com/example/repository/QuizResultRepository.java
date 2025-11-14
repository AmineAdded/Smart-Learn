package com.example.repository;

import com.example.model.QuizResult;
import com.example.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface QuizResultRepository extends JpaRepository<QuizResult, Long> {
    
    List<QuizResult> findByUser(User user);
    
    List<QuizResult> findByUserId(Long userId);
    
    List<QuizResult> findByUserIdOrderByCompletedAtDesc(Long userId);
    
    @Query("SELECT qr FROM QuizResult qr WHERE qr.user.id = :userId ORDER BY qr.completedAt DESC")
    List<QuizResult> findRecentByUserId(
        @Param("userId") Long userId, 
        org.springframework.data.domain.Pageable pageable
    );
    
    @Query("SELECT COUNT(qr) FROM QuizResult qr WHERE qr.user.id = :userId")
    Integer countByUserId(@Param("userId") Long userId);
    
    @Query("SELECT COUNT(qr) FROM QuizResult qr WHERE qr.user.id = :userId AND qr.passed = true")
    Integer countSuccessfulByUserId(@Param("userId") Long userId);
    
    @Query("SELECT AVG(qr.score) FROM QuizResult qr WHERE qr.user.id = :userId")
    Double getAverageScoreByUserId(@Param("userId") Long userId);
    
    @Query("SELECT SUM(qr.timeSpentMinutes) FROM QuizResult qr WHERE qr.user.id = :userId")
    Integer getTotalStudyTimeByUserId(@Param("userId") Long userId);
    
    @Query("SELECT SUM(qr.xpEarned) FROM QuizResult qr WHERE qr.user.id = :userId")
    Integer getTotalXpEarnedByUserId(@Param("userId") Long userId);
    
    @Query("SELECT qr FROM QuizResult qr WHERE qr.user.id = :userId " +
           "AND qr.completedAt BETWEEN :startDate AND :endDate")
    List<QuizResult> findByUserIdAndDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    @Query("SELECT q.category, COUNT(qr), AVG(qr.score), SUM(qr.xpEarned) " +
           "FROM QuizResult qr JOIN qr.quiz q " +
           "WHERE qr.user.id = :userId " +
           "GROUP BY q.category")
    List<Object[]> getProgressBySubject(@Param("userId") Long userId);
}