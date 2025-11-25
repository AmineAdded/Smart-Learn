package com.example.repository;


import com.example.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, Long> {
    
    List<Quiz> findByIsActiveTrue();
    
    List<Quiz> findByCategory(String category);
    
    List<Quiz> findByDifficulty(String difficulty);
    
    List<Quiz> findByCategoryAndDifficulty(String category, String difficulty);
    
    List<Quiz> findByHasAITrue();
    
    @Query("SELECT q FROM Quiz q WHERE q.isActive = true ORDER BY q.createdAt DESC")
    List<Quiz> findRecentActiveQuizzes(org.springframework.data.domain.Pageable pageable);
    
    @Query("SELECT DISTINCT q.category FROM Quiz q WHERE q.isActive = true")
    List<String> findAllCategories();
}