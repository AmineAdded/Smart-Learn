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
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
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

        Pageable limitTwo = PageRequest.of(0, 2); // page 0, taille 2

        List<Quiz> quizzes = quizRepository.findRecentActiveQuizzes(limitTwo);

        return quizzes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }


    /**
     * ⭐ MÉTHODE CORRIGÉE - Récupérer les détails complets d'un quiz
     */
    public QuizDetailDTO getQuizDetail(Long quizId) {
        System.out.println("========================================");
        System.out.println("📥 DÉBUT - Récupération détails quiz #" + quizId);
        System.out.println("========================================");

        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz non trouvé avec l'ID: " + quizId));

        if (!quiz.getIsActive()) {
            throw new RuntimeException("Ce quiz n'est plus disponible");
        }

        // Récupérer les questions
        List<Question> questions = new ArrayList<>();
        try {
            questions = questionRepository.findByQuizId(quizId);
            System.out.println("✅ " + questions.size() + " questions trouvées");
        } catch (Exception e) {
            System.err.println("⚠️ Erreur questions: " + e.getMessage());
        }

        QuizDetailDTO.QuestionDistribution distribution = buildQuestionDistribution(questions);

        // ⭐ CORRECTION 1: Récupérer TOUS les résultats pour les stats globales
        List<QuizResult> allResults = new ArrayList<>();
        try {
            allResults = quizResultRepository.findByQuizId(quizId);
            System.out.println("📊 STATS GLOBALES: " + allResults.size() + " résultats totaux (tous utilisateurs)");
        } catch (Exception e) {
            System.err.println("⚠️ Erreur résultats globaux: " + e.getMessage());
        }

        // ⭐ Stats globales (TOUS les utilisateurs)
        QuizDetailDTO.QuizStatistics statistics = buildQuizStatistics(allResults);
        List<QuizDetailDTO.LeaderboardEntry> topScores = buildLeaderboard(allResults);

        // ⭐ CORRECTION 2: Stats utilisateur (SEULEMENT l'utilisateur connecté)
        QuizDetailDTO.UserQuizProgress userProgress = buildUserProgress(quizId);

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
                .createdBy("SmartLearn")
                .questionDistribution(distribution)
                .statistics(statistics)
                .userProgress(userProgress)
                .topScores(topScores)
                .prerequisites(new ArrayList<>())
                .recommendedLevel(quiz.getDifficulty())
                .topics(new ArrayList<>())
                .build();

        System.out.println("========================================");
        System.out.println("✅ FIN - Détails construits avec succès");
        System.out.println("========================================");
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
     * ⭐ MÉTHODE CORRECTE - Statistiques globales (TOUS LES UTILISATEURS)
     * Cette méthode doit bien utiliser TOUS les résultats
     */
    private QuizDetailDTO.QuizStatistics buildQuizStatistics(List<QuizResult> allResults) {
        System.out.println("📈 Construction statistiques GLOBALES");
        System.out.println("   Résultats analysés: " + allResults.size() + " (tous utilisateurs)");

        if (allResults.isEmpty()) {
            return QuizDetailDTO.QuizStatistics.builder()
                    .totalAttempts(0)
                    .averageScore(0.0)
                    .completionRate(0)
                    .averageTimeMinutes(0.0)
                    .build();
        }

        int totalAttempts = allResults.size();

        double averageScore = allResults.stream()
                .filter(r -> r.getScore() != null)
                .mapToInt(QuizResult::getScore)
                .average()
                .orElse(0.0);

        long completedCount = allResults.stream()
                .filter(r -> r.getCompletedAt() != null)
                .count();
        int completionRate = (int) ((completedCount * 100.0) / totalAttempts);

        double averageTime = allResults.stream()
                .filter(r -> r.getTimeSpentMinutes() != null)
                .mapToInt(QuizResult::getTimeSpentMinutes)
                .average()
                .orElse(0.0);

        System.out.println("   ✅ Stats: " + totalAttempts + " tentatives, score moyen: " + averageScore + "%");

        return QuizDetailDTO.QuizStatistics.builder()
                .totalAttempts(totalAttempts)
                .averageScore(averageScore)
                .completionRate(completionRate)
                .averageTimeMinutes(averageTime)
                .build();
    }

    /**
     * ⭐ MÉTHODE CORRECTE - Leaderboard (TOP 5 DE TOUS LES UTILISATEURS)
     * Cette méthode doit bien utiliser TOUS les résultats
     */
    private List<QuizDetailDTO.LeaderboardEntry> buildLeaderboard(List<QuizResult> allResults) {
        System.out.println("🏆 Construction LEADERBOARD GLOBAL");
        System.out.println("   Résultats analysés: " + allResults.size() + " (tous utilisateurs)");

        return allResults.stream()
                .filter(r -> r.getCompletedAt() != null && r.getScore() != null)
                .sorted((r1, r2) -> Integer.compare(r2.getScore(), r1.getScore()))
                .limit(5)
                .map(r -> {
                    int rank = (int) allResults.stream()
                            .filter(result -> result.getScore() != null && result.getScore() > r.getScore())
                            .count() + 1;

                    String username = "Utilisateur";
                    try {
                        username = r.getUser() != null && r.getUser().getUsername() != null
                                ? r.getUser().getUsername()
                                : "Anonyme";
                    } catch (Exception e) {
                        System.err.println("⚠️ Erreur username: " + e.getMessage());
                    }

                    System.out.println("   #" + rank + ": " + username + " - " + r.getScore() + "%");

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
     * ⭐ MÉTHODE CORRECTE - Progression utilisateur (UNIQUEMENT L'UTILISATEUR CONNECTÉ)
     */
    private QuizDetailDTO.UserQuizProgress buildUserProgress(Long quizId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                System.out.println("⚠️ Aucun utilisateur connecté");
                return QuizDetailDTO.UserQuizProgress.builder()
                        .hasAttempted(false)
                        .attemptsCount(0)
                        .canRetake(true)
                        .progressStatus("not_started")
                        .build();
            }

            System.out.println("========================================");
            System.out.println("👤 PROGRESSION UTILISATEUR");
            System.out.println("   User ID: " + currentUser.getId());
            System.out.println("   Username: " + currentUser.getUsername());
            System.out.println("========================================");

            // ⭐ FILTRER UNIQUEMENT PAR L'UTILISATEUR CONNECTÉ
            List<QuizResult> userResults = quizResultRepository.findByUserIdAndQuizId(
                    currentUser.getId(),
                    quizId
            );

            System.out.println("📊 Résultats pour CET utilisateur: " + userResults.size());

            if (userResults.isEmpty()) {
                System.out.println("   ℹ️ Aucune tentative pour cet utilisateur");
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

            System.out.println("✅ Progression calculée:");
            System.out.println("   - Tentatives: " + userResults.size());
            System.out.println("   - Meilleur score: " + bestScore + "%");
            System.out.println("   - Dernier score: " + lastResult.getScore() + "%");
            System.out.println("========================================");

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
            System.err.println("⚠️ Erreur progression utilisateur: " + e.getMessage());
            e.printStackTrace();
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
            System.err.println("⚠️ Erreur conversion DTO: " + e.getMessage());
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