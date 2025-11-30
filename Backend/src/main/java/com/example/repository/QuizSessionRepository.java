package com.example.repository;

import com.example.model.QuizSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuizSessionRepository extends JpaRepository<QuizSession, Long> {
    List<QuizSession> findByUserIdAndIsCompletedFalse(Long userId);
    Optional<QuizSession> findByUserIdAndQuizIdAndIsCompletedFalse(Long userId, Long quizId);
    List<QuizSession> findByUserIdOrderByStartedAtDesc(Long userId);
}
