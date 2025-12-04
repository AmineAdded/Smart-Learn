package com.example.service;

import com.example.dto.QuizDTO;
import com.example.dto.QuizDetailDTO;
import com.example.model.Quiz;
import com.example.model.User;
import com.example.model.QuizResult;
import com.example.model.Question;
import com.example.repository.QuizRepository;
import com.example.repository.QuizResultRepository;
import com.example.repository.UserRepository;
import com.example.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
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

    @Autowired
    private QuestionRepository questionRepository;

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
                .limit(3)
                .collect(Collectors.toList());

        return quizzes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * ⭐ NOUVELLE MÉTHODE - Récupérer les détails complets d'un quiz
     */
    public QuizDetailDTO getQuizDetail(Long quizId) {
        System.out.println("📥 Service: Récupération des détails du quiz #" + quizId);

        // Récupérer le quiz
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz non trouvé avec l'ID: " + quizId));

        if (!quiz.getIsActive()) {
            throw new RuntimeException("Ce quiz n'est plus disponible");
        }

        // Récupérer les questions pour analyser la distribution
        List<Question> questions = new ArrayList<>();
        try {
            questions = questionRepository.findByQuizId(quizId);
            System.out.println("✅ " + questions.size() + " questions trouvées");
        } catch (Exception e) {
            System.err.println("⚠️ Erreur lors de la récupération des questions: " + e.getMessage());
        }

        // Construire la distribution des types de questions
        QuizDetailDTO.QuestionDistribution distribution = buildQuestionDistribution(questions);

        // Récupérer toutes les tentatives du quiz
        List<QuizResult> allResults = new ArrayList<>();
        try {
            allResults = quizResultRepository.findByQuizId(quizId);
            System.out.println("✅ " + allResults.size() + " résultats trouvés");
        } catch (Exception e) {
            System.err.println("⚠️ Erreur lors de la récupération des résultats: " + e.getMessage());
        }

        // Construire les statistiques globales
        QuizDetailDTO.QuizStatistics statistics = buildQuizStatistics(allResults);

        // Récupérer le leaderboard (top 5)
        List<QuizDetailDTO.LeaderboardEntry> topScores = buildLeaderboard(allResults);

        // Récupérer les informations utilisateur
        QuizDetailDTO.UserQuizProgress userProgress = buildUserProgress(quizId);

        // Construire le DTO détaillé
        QuizDetailDTO detailDTO = QuizDetailDTO.builder()
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
                .createdBy("SmartLearn") // Valeur par défaut si pas de créateur
                .questionDistribution(distribution)
                .statistics(statistics)
                .userProgress(userProgress)
                .topScores(topScores)
                .prerequisites(new ArrayList<>())
                .recommendedLevel(quiz.getDifficulty())
                .topics(new ArrayList<>())
                .build();

        System.out.println("✅ Détails du quiz construits avec succès");
        return detailDTO;
    }

    /**
     * Construire la distribution des types de questions
     */
    private QuizDetailDTO.QuestionDistribution buildQuestionDistribution(List<Question> questions) {
        int multipleChoice = 0;
        int trueFalse = 0;
        int shortAnswer = 0;
        int matching = 0;
        int withImages = 0;

        for (Question q : questions) {
            String type = q.getType() != null ? q.getType().toUpperCase() : "";

            switch (type) {
                case "MULTIPLE_CHOICE":
                case "QCM":
                    multipleChoice++;
                    break;
                case "TRUE_FALSE":
                case "VRAI_FAUX":
                    trueFalse++;
                    break;
                case "SHORT_ANSWER":
                case "REPONSE_COURTE":
                    shortAnswer++;
                    break;
                case "MATCHING":
                case "ASSOCIATION":
                    matching++;
                    break;
            }

            if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) {
                withImages++;
            }
        }

        return QuizDetailDTO.QuestionDistribution.builder()
                .multipleChoice(multipleChoice)
                .trueFalse(trueFalse)
                .shortAnswer(shortAnswer)
                .matching(matching)
                .withImages(withImages)
                .build();
    }

    /**
     * Construire les statistiques globales du quiz
     */
    private QuizDetailDTO.QuizStatistics buildQuizStatistics(List<QuizResult> results) {
        if (results.isEmpty()) {
            return QuizDetailDTO.QuizStatistics.builder()
                    .totalAttempts(0)
                    .averageScore(0.0)
                    .completionRate(0)
                    .averageTimeMinutes(0.0)
                    .build();
        }

        int totalAttempts = results.size();

        double averageScore = results.stream()
                .filter(r -> r.getScore() != null)
                .mapToInt(QuizResult::getScore)
                .average()
                .orElse(0.0);

        long completedCount = results.stream()
                .filter(r -> r.getCompletedAt() != null)
                .count();
        int completionRate = (int) ((completedCount * 100.0) / totalAttempts);

        double averageTime = results.stream()
                .filter(r -> r.getTimeSpentMinutes() != null)
                .mapToInt(QuizResult::getTimeSpentMinutes)
                .average()
                .orElse(0.0);

        return QuizDetailDTO.QuizStatistics.builder()
                .totalAttempts(totalAttempts)
                .averageScore(averageScore)
                .completionRate(completionRate)
                .averageTimeMinutes(averageTime)
                .build();
    }

    /**
     * Construire le leaderboard (top 5)
     */
    private List<QuizDetailDTO.LeaderboardEntry> buildLeaderboard(List<QuizResult> results) {
        return results.stream()
                .filter(r -> r.getCompletedAt() != null && r.getScore() != null)
                .sorted((r1, r2) -> Integer.compare(r2.getScore(), r1.getScore()))
                .limit(5)
                .map(r -> {
                    int rank = (int) results.stream()
                            .filter(result -> result.getScore() != null && result.getScore() > r.getScore())
                            .count() + 1;

                    String username = "Utilisateur";
                    try {
                        username = r.getUser() != null && r.getUser().getUsername() != null
                                ? r.getUser().getUsername()
                                : "Anonyme";
                    } catch (Exception e) {
                        System.err.println("⚠️ Erreur lors de la récupération du username: " + e.getMessage());
                    }

                    return QuizDetailDTO.LeaderboardEntry.builder()
                            .username(username)
                            .score(r.getScore())
                            .completedAt(r.getCompletedAt())
                            .rank(rank)
                            .build();
                })
                .collect(Collectors.toList());
    }

    /**
     * Construire la progression utilisateur
     */
    private QuizDetailDTO.UserQuizProgress buildUserProgress(Long quizId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return QuizDetailDTO.UserQuizProgress.builder()
                        .hasAttempted(false)
                        .attemptsCount(0)
                        .canRetake(true)
                        .progressStatus("not_started")
                        .build();
            }

            List<QuizResult> userResults = quizResultRepository.findByUserIdAndQuizId(
                    currentUser.getId(), quizId
            );

            if (userResults.isEmpty()) {
                return QuizDetailDTO.UserQuizProgress.builder()
                        .hasAttempted(false)
                        .attemptsCount(0)
                        .canRetake(true)
                        .progressStatus("not_started")
                        .build();
            }

            Integer bestScore = userResults.stream()
                    .filter(r -> r.getScore() != null)
                    .mapToInt(QuizResult::getScore)
                    .max()
                    .orElse(0);

            QuizResult lastResult = userResults.stream()
                    .filter(r -> r.getCompletedAt() != null)
                    .max((r1, r2) -> r1.getCompletedAt().compareTo(r2.getCompletedAt()))
                    .orElse(userResults.get(0));

            String progressStatus = lastResult.getCompletedAt() != null ? "completed" : "in_progress";

            return QuizDetailDTO.UserQuizProgress.builder()
                    .hasAttempted(true)
                    .attemptsCount(userResults.size())
                    .bestScore(bestScore)
                    .lastScore(lastResult.getScore())
                    .lastAttemptDate(lastResult.getCompletedAt())
                    .canRetake(true)
                    .progressStatus(progressStatus)
                    .build();

        } catch (Exception e) {
            System.err.println("⚠️ Erreur lors de la construction de la progression utilisateur: " + e.getMessage());
            return QuizDetailDTO.UserQuizProgress.builder()
                    .hasAttempted(false)
                    .attemptsCount(0)
                    .canRetake(true)
                    .progressStatus("not_started")
                    .build();
        }
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
                            .filter(r -> r.getScore() != null)
                            .mapToInt(QuizResult::getScore)
                            .max()
                            .orElse(0);
                    dto.setUserBestScore(bestScore);
                }
            }
        } catch (Exception e) {
            // Pas d'utilisateur connecté ou erreur
            System.err.println("⚠️ Erreur lors de la conversion en DTO: " + e.getMessage());
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