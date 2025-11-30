package com.example.repository;

import com.example.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByQuizId(Long quizId);


    /**
     * Trouver les questions par type
     */
    List<Question> findByType(String type);

    /**
     * Trouver les questions d'un quiz par type
     */
    List<Question> findByQuizIdAndType(Long quizId, String type);

    /**
     * Compter le nombre de questions d'un quiz
     */
    long countByQuizId(Long quizId);
}