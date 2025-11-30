package com.example.repository;

import com.example.model.UserAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserAnswerRepository extends JpaRepository<UserAnswer, Long> {
    List<UserAnswer> findBySessionId(Long sessionId);
    Optional<UserAnswer> findBySessionIdAndQuestionId(Long sessionId, Long questionId);
    long countBySessionId(Long sessionId);
}