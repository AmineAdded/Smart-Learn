package com.example.service;

import com.example.dto.*;
import com.example.model.*;
import com.example.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class QuizSessionService {
    @Autowired
    private ProgressService progressService;

    @Autowired
    private QuizRepository quizRepository;

    @Autowired
    private QuizSessionRepository sessionRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private AnswerOptionRepository answerOptionRepository;

    @Autowired
    private UserAnswerRepository userAnswerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private QuizResultRepository quizResultRepository;

    /**
     * Démarrer une nouvelle session de quiz
     */
    @Transactional
    public QuizSessionDTO startQuiz(Long quizId) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("Utilisateur non authentifié");
        }

        // Vérifier si le quiz existe et est actif
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz non trouvé"));

        if (!quiz.getIsActive()) {
            throw new RuntimeException("Ce quiz n'est plus disponible");
        }

        // Vérifier s'il y a déjà une session en cours
        Optional<QuizSession> existingSession = sessionRepository
                .findByUserIdAndQuizIdAndIsCompletedFalse(currentUser.getId(), quizId);

        if (existingSession.isPresent()) {
            QuizSession session = existingSession.get();

            // ⭐ Si la session est expirée, la marquer comme terminée et en créer une nouvelle
            if (session.getExpiresAt() != null && LocalDateTime.now().isAfter(session.getExpiresAt())) {
                session.setIsExpired(true);
                session.setIsCompleted(true);
                session.setCompletedAt(LocalDateTime.now());
                sessionRepository.save(session);

                System.out.println("⚠️ Session expirée, création d'une nouvelle session");
                // Continuer pour créer une nouvelle session
            } else {
                // Reprendre la session existante
                return resumeQuiz(session.getId());
            }
        }

        // Créer une nouvelle session
        QuizSession session = QuizSession.builder()
                .user(currentUser)
                .quiz(quiz)
                .startedAt(LocalDateTime.now())
                .currentQuestionIndex(0)
                .timeSpentSeconds(0)
                .currentScore(0)
                .isCompleted(false)
                .isExpired(false)
                .build();

        // Calculer l'expiration si le quiz a une durée limitée
        if (quiz.getDurationMinutes() != null && quiz.getDurationMinutes() > 0) {
            session.setExpiresAt(LocalDateTime.now().plusMinutes(quiz.getDurationMinutes()));
        }

        session = sessionRepository.save(session);

        // Récupérer les questions
        List<Question> questions = questionRepository.findByQuizId(quizId);

        // Calculer le total de points possibles
        int totalPoints = questions.stream()
                .mapToInt(q -> q.getPoints() != null ? q.getPoints() : 1)
                .sum();
        session.setTotalPointsPossible(totalPoints);
        sessionRepository.save(session);

        // Convertir en DTO
        return buildSessionDTO(session, questions, new HashMap<>(), 0);
    }

    /**
     * Reprendre une session existante
     */
    @Transactional
    public QuizSessionDTO resumeQuiz(Long sessionId) {
        QuizSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session non trouvée"));

        User currentUser = getCurrentUser();
        if (!session.getUser().getId().equals(currentUser.getId())) {
            throw new RuntimeException("Accès non autorisé à cette session");
        }

        if (session.getIsCompleted()) {
            throw new RuntimeException("Cette session est déjà terminée");
        }

        // Vérifier l'expiration
        if (session.getExpiresAt() != null && LocalDateTime.now().isAfter(session.getExpiresAt())) {
            session.setIsExpired(true);
            session.setIsCompleted(true);
            session.setCompletedAt(LocalDateTime.now());
            sessionRepository.save(session);

            // ⭐ Calculer le score final même si expiré
            int scorePercentage = 0;
            if (session.getTotalPointsPossible() > 0) {
                scorePercentage = (int) ((session.getCurrentScore() * 100.0) / session.getTotalPointsPossible());
            }

            throw new RuntimeException("Cette session a expiré. Score obtenu: " + scorePercentage + "%");
        }

        // Récupérer les questions
        List<Question> questions = questionRepository.findByQuizId(session.getQuiz().getId());

        // Récupérer les réponses déjà données
        List<UserAnswer> userAnswers = userAnswerRepository.findBySessionId(sessionId);
        Map<Long, String> savedAnswers = userAnswers.stream()
                .collect(Collectors.toMap(
                        ua -> ua.getQuestion().getId(),
                        UserAnswer::getUserAnswer
                ));

        return buildSessionDTO(session, questions, savedAnswers, session.getTimeSpentSeconds());
    }

    /**
     * Soumettre une réponse à une question
     */
    @Transactional
    public AnswerFeedbackDTO submitAnswer(SubmitAnswerDTO submitDTO) {
        QuizSession session = sessionRepository.findById(submitDTO.getSessionId())
                .orElseThrow(() -> new RuntimeException("Session non trouvée"));

        if (session.getIsCompleted()) {
            throw new RuntimeException("Cette session est déjà terminée");
        }

        Question question = questionRepository.findById(submitDTO.getQuestionId())
                .orElseThrow(() -> new RuntimeException("Question non trouvée"));

        // Vérifier si la réponse a déjà été donnée
        Optional<UserAnswer> existingAnswer = userAnswerRepository
                .findBySessionIdAndQuestionId(submitDTO.getSessionId(), submitDTO.getQuestionId());

        if (existingAnswer.isPresent()) {
            // Mettre à jour la réponse existante
            UserAnswer answer = existingAnswer.get();
            answer.setUserAnswer(submitDTO.getAnswer());
            answer.setTimeSpentSeconds(submitDTO.getTimeSpentSeconds());

            // Évaluer la réponse
            boolean isCorrect = evaluateAnswer(question, submitDTO.getAnswer());
            answer.setIsCorrect(isCorrect);
            answer.setPointsEarned(isCorrect ? (question.getPoints() != null ? question.getPoints() : 1) : 0);

            // Incrémenter le nombre de tentatives
            answer.setAttemptCount(answer.getAttemptCount() != null ? answer.getAttemptCount() + 1 : 1);

            System.out.println("✏️ Mise à jour de la réponse - Correcte: " + isCorrect);
            userAnswerRepository.save(answer);
        } else {
            // Créer une nouvelle réponse
            boolean isCorrect = evaluateAnswer(question, submitDTO.getAnswer());
            int pointsEarned = isCorrect ? (question.getPoints() != null ? question.getPoints() : 1) : 0;

            System.out.println("📝 Création d'une nouvelle réponse - Correcte: " + isCorrect + ", Points: " + pointsEarned);

            UserAnswer answer = UserAnswer.builder()
                    .session(session)
                    .question(question)
                    .userAnswer(submitDTO.getAnswer())
                    .isCorrect(isCorrect)
                    .pointsEarned(pointsEarned)
                    .timeSpentSeconds(submitDTO.getTimeSpentSeconds())
                    .attemptCount(1)
                    .build();

            try {
                userAnswerRepository.save(answer);
                System.out.println("✅ Réponse sauvegardée avec succès");
            } catch (Exception e) {
                System.err.println("❌ Erreur lors de la sauvegarde de la réponse: " + e.getMessage());
                e.printStackTrace();
                throw e;
            }
        }

        // Mettre à jour le temps passé et le score de la session
        session.setTimeSpentSeconds(session.getTimeSpentSeconds() + submitDTO.getTimeSpentSeconds());

        // Recalculer le score total
        int totalScore = userAnswerRepository.findBySessionId(session.getId())
                .stream()
                .mapToInt(UserAnswer::getPointsEarned)
                .sum();
        session.setCurrentScore(totalScore);

        sessionRepository.save(session);

        // Compter les questions répondues
        long questionsAnswered = userAnswerRepository.countBySessionId(session.getId());
        long totalQuestions = questionRepository.countByQuizId(session.getQuiz().getId());

        // Construire le feedback
        boolean isCorrect = evaluateAnswer(question, submitDTO.getAnswer());
        String correctAnswer = getCorrectAnswer(question);

        return AnswerFeedbackDTO.builder()
                .isCorrect(isCorrect)
                .correctAnswer(correctAnswer)
                .explanation(question.getExplanation())
                .pointsEarned(isCorrect ? (question.getPoints() != null ? question.getPoints() : 1) : 0)
                .currentScore(totalScore)
                .questionsAnswered((int) questionsAnswered)
                .totalQuestions((int) totalQuestions)
                .build();
    }

    /**
     * Terminer le quiz et calculer le résultat final
     */
    @Transactional
    public QuizResult completeQuiz(Long sessionId) {
        System.out.println("📥 Tentative de complétion du quiz - Session: " + sessionId);

        QuizSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session non trouvée"));

        if (session.getIsCompleted()) {
            System.out.println("⚠️ Session déjà terminée");
            // Si déjà terminée, retourner le résultat existant
            return quizResultRepository.findByUserIdAndQuizId(
                            session.getUser().getId(),
                            session.getQuiz().getId()
                    ).stream()
                    .max((r1, r2) -> r1.getCompletedAt().compareTo(r2.getCompletedAt()))
                    .orElseThrow(() -> new RuntimeException("Résultat non trouvé"));
        }

        try {
            // Compter les réponses correctes
            List<UserAnswer> userAnswers = userAnswerRepository.findBySessionId(sessionId);
            long correctAnswersCount = userAnswers.stream()
                    .filter(ua -> ua.getIsCorrect() != null && ua.getIsCorrect())
                    .count();

            long totalQuestions = questionRepository.countByQuizId(session.getQuiz().getId());

            // Calculer le score en pourcentage
            int scorePercentage = 0;
            if (session.getTotalPointsPossible() != null && session.getTotalPointsPossible() > 0) {
                scorePercentage = (int) ((session.getCurrentScore() * 100.0) / session.getTotalPointsPossible());
            }

            // Déterminer si le quiz est réussi (>= 50%)
            boolean passed = scorePercentage >= 50;

            // Calculer les XP gagnés
            int xpEarned = session.getQuiz().getXpReward() != null ? session.getQuiz().getXpReward() : 0;
            if (passed) {
                // Bonus si parfait
                if (scorePercentage == 100) {
                    xpEarned = (int) (xpEarned * 1.5);
                }
            } else {
                // Réduction si échoué
                xpEarned = xpEarned / 2;
            }

            System.out.println("📊 Résultats calculés:");
            System.out.println("  - Score: " + scorePercentage + "%");
            System.out.println("  - Réponses correctes: " + correctAnswersCount + "/" + totalQuestions);
            System.out.println("  - Réussi: " + passed);
            System.out.println("  - XP: " + xpEarned);

            // Marquer la session comme terminée AVANT de créer le résultat
            session.setIsCompleted(true);
            session.setCompletedAt(LocalDateTime.now());
            session = sessionRepository.saveAndFlush(session); // ⭐ Utiliser saveAndFlush pour forcer l'écriture

            System.out.println("✅ Session marquée comme terminée");

            // Créer le résultat du quiz
            QuizResult result = QuizResult.builder()
                    .user(session.getUser())
                    .quiz(session.getQuiz())
                    .score(scorePercentage)
                    .timeSpentMinutes((int) Math.ceil(session.getTimeSpentSeconds() / 60.0))
                    .completedAt(LocalDateTime.now())
                    .correctAnswers((int) correctAnswersCount)
                    .totalQuestions((int) totalQuestions)
                    .passed(passed)
                    .xpEarned(xpEarned)
                    .earnedPoints(session.getCurrentScore())
                    .build();

            result = quizResultRepository.save(result);
            progressService.updateProgressAfterQuiz(result);
            System.out.println("✅ Résultat sauvegardé - ID: " + result.getId());

            return result;

        } catch (Exception e) {
            System.err.println("❌ Erreur lors de la complétion du quiz: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Erreur lors de la finalisation du quiz: " + e.getMessage());
        }
    }

    /**
     * Construire le DTO de session
     */
    private QuizSessionDTO buildSessionDTO(QuizSession session, List<Question> questions,
                                           Map<Long, String> savedAnswers, Integer timeSpentSeconds) {
        List<QuestionDTO> questionDTOs = questions.stream()
                .map(this::convertToQuestionDTO)
                .collect(Collectors.toList());

        return QuizSessionDTO.builder()
                .sessionId(session.getId())
                .quizId(session.getQuiz().getId())
                .quizTitle(session.getQuiz().getTitle())
                .totalQuestions(questions.size())
                .durationMinutes(session.getQuiz().getDurationMinutes())
                .startedAt(session.getStartedAt())
                .expiresAt(session.getExpiresAt())
                .questions(questionDTOs)
                .currentQuestionIndex(session.getCurrentQuestionIndex())
                .savedAnswers(savedAnswers)
                .timeSpentSeconds(timeSpentSeconds)
                .build();
    }

    /**
     * Convertir Question en QuestionDTO
     */
    private QuestionDTO convertToQuestionDTO(Question question) {
        QuestionDTO dto = QuestionDTO.builder()
                .id(question.getId())
                .questionText(question.getQuestionText())
                .type(question.getType())
                .imageUrl(question.getImageUrl())
                .points(question.getPoints())
                .orderNumber(question.getOrderNumber())
                .build();

        // Ajouter les options pour les QCM
        if ("QCM".equalsIgnoreCase(question.getType()) || "MULTIPLE_CHOICE".equalsIgnoreCase(question.getType())) {
            List<AnswerOption> options = answerOptionRepository.findByQuestionIdOrderByOrderNumber(question.getId());
            dto.setOptions(options.stream()
                    .map(opt -> QuestionDTO.AnswerOptionDTO.builder()
                            .id(opt.getId())
                            .optionText(opt.getOptionText())
                            .optionLetter(opt.getOptionLetter())
                            .build())
                    .collect(Collectors.toList()));
        }

        return dto;
    }

    /**
     * Évaluer si une réponse est correcte
     */
    private boolean evaluateAnswer(Question question, String userAnswer) {
        String type = question.getType().toUpperCase();

        switch (type) {
            case "QCM":
            case "MULTIPLE_CHOICE":
                // Vérifier si l'option choisie est correcte
                try {
                    Long optionId = Long.parseLong(userAnswer);
                    AnswerOption option = answerOptionRepository.findById(optionId).orElse(null);
                    return option != null && option.getIsCorrect();
                } catch (NumberFormatException e) {
                    return false;
                }

            case "VRAI_FAUX":
            case "TRUE_FALSE":
                // Comparer avec la bonne réponse stockée
                List<AnswerOption> options = answerOptionRepository.findByQuestionId(question.getId());
                return options.stream()
                        .filter(AnswerOption::getIsCorrect)
                        .anyMatch(opt -> opt.getOptionText().equalsIgnoreCase(userAnswer));

            case "REPONSE_COURTE":
            case "SHORT_ANSWER":
                // Comparaison simple (peut être améliorée)
                List<AnswerOption> correctAnswers = answerOptionRepository.findByQuestionId(question.getId());
                return correctAnswers.stream()
                        .anyMatch(opt -> opt.getOptionText().equalsIgnoreCase(userAnswer.trim()));

            default:
                return false;
        }
    }

    /**
     * Récupérer la bonne réponse
     */
    private String getCorrectAnswer(Question question) {
        List<AnswerOption> options = answerOptionRepository.findByQuestionId(question.getId());
        return options.stream()
                .filter(AnswerOption::getIsCorrect)
                .map(opt -> opt.getOptionLetter() != null ?
                        opt.getOptionLetter() + ". " + opt.getOptionText() :
                        opt.getOptionText())
                .findFirst()
                .orElse("Non disponible");
    }

    /**
     * Supprimer une session (abandon)
     */
    @Transactional
    public void deleteSession(Long sessionId) {
        QuizSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session non trouvée"));

        User currentUser = getCurrentUser();
        if (!session.getUser().getId().equals(currentUser.getId())) {
            throw new RuntimeException("Accès non autorisé à cette session");
        }

        // Supprimer les réponses associées
        userAnswerRepository.deleteAll(userAnswerRepository.findBySessionId(sessionId));

        // Supprimer la session
        sessionRepository.delete(session);
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