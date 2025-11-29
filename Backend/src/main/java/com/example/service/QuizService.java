package com.example.service;

import com.example.dto.QuizDTO;
import com.example.model.Quiz;
import com.example.model.User;
import com.example.model.QuizResult;
import com.example.repository.QuizRepository;
import com.example.repository.QuizResultRepository;
import com.example.repository.UserRepository;
import java.util.Collections;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class QuizService {

    @Autowired
    private QuizRepository quizRepository;

    @Autowired
    private QuizResultRepository quizResultRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupérer tous les quiz avec filtres optionnels
     */
    public List<QuizDTO> getQuizzes(String category, String difficulty, Boolean hasAI) {
        List<Quiz> quizzes;

        // Appliquer les filtres
        if (category != null && difficulty != null) {
            quizzes = quizRepository.findByCategoryAndDifficulty(category, difficulty);
        } else if (category != null) {
            quizzes = quizRepository.findByCategory(category);
        } else if (difficulty != null) {
            quizzes = quizRepository.findByDifficulty(difficulty);
        } else if (hasAI != null && hasAI) {
            quizzes = quizRepository.findByHasAITrue();
        } else {
            quizzes = quizRepository.findByIsActiveTrue();
        }

        // Convertir en DTO avec informations utilisateur
        return quizzes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupérer un quiz par son ID
     */
    public QuizDTO getQuizById(Long id) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quiz non trouvé avec l'ID: " + id));

        if (!quiz.getIsActive()) {
            throw new RuntimeException("Ce quiz n'est plus disponible");
        }

        return convertToDTO(quiz);
    }

    /**
     * Récupérer toutes les catégories disponibles
     */
    public List<String> getAllCategories() {
        return quizRepository.findAllCategories();
    }

    /**
     * Récupérer les quiz recommandés basés sur les intérêts de l'utilisateur
     */
    public List<QuizDTO> getRecommendedQuizzes() {
        // Pour l'instant, retourner les quiz les plus récents
        // Plus tard, on pourra intégrer la logique IA
        List<Quiz> quizzes = quizRepository.findByIsActiveTrue()
                .stream()
                .limit(10)
                .collect(Collectors.toList());

        return quizzes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Convertir Quiz en QuizDTO avec les informations utilisateur
     */
    private QuizDTO convertToDTO(Quiz quiz) {
        QuizDTO dto = QuizDTO.builder()
                .id(quiz.getId())
                .title(quiz.getTitle())
                .description(quiz.getDescription())
                .category(quiz.getCategory())
                .difficulty(quiz.getDifficulty())
                .questionCount(quiz.getQuestionCount())
                .durationMinutes(quiz.getDurationMinutes())
                .xpReward(quiz.getXpReward())
                .hasAI(quiz.getHasAI())
                .isActive(quiz.getIsActive())
                .createdAt(quiz.getCreatedAt())
                .build();

        // Ajouter les informations utilisateur si connecté
        try {
            User currentUser = getCurrentUser();
            if (currentUser != null) {
                List<QuizResult> userResults = quizResultRepository.findByUserId(currentUser.getId())
                        .stream()
                        .filter(qr -> qr.getQuiz().getId().equals(quiz.getId()))
                        .collect(Collectors.toList());

                dto.setIsCompleted(!userResults.isEmpty());
                dto.setAttemptsCount(userResults.size());

                if (!userResults.isEmpty()) {
                    Integer bestScore = userResults.stream()
                            .mapToInt(QuizResult::getScore)
                            .max()
                            .orElse(0);
                    dto.setUserBestScore(bestScore);
                }
            }
        } catch (Exception e) {
            // Pas d'utilisateur connecté ou erreur
        }

        return dto;
    }

    /**
     * Récupérer l'utilisateur connecté
     */
    private User getCurrentUser() {
        try {
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            return userRepository.findByEmail(email).orElse(null);
        } catch (Exception e) {
            return null;
        }
    }
}