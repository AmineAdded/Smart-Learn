package com.example.controller;

import com.example.dto.*;
import com.example.model.QuizResult;
import com.example.service.QuizSessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quiz-session")
@CrossOrigin(origins = "*", maxAge = 3600)
public class QuizSessionController {

    @Autowired
    private QuizSessionService quizSessionService;

    /**
     * POST /api/quiz-session/start/{quizId}
     * Démarrer une nouvelle session de quiz
     */
    @PostMapping("/start/{quizId}")
    public ResponseEntity<?> startQuiz(@PathVariable("quizId") Long quizId) {
        try {
            System.out.println("📥 Démarrage du quiz #" + quizId);

            QuizSessionDTO session = quizSessionService.startQuiz(quizId);

            System.out.println("✅ Session créée: #" + session.getSessionId());
            return ResponseEntity.ok(session);
        } catch (RuntimeException e) {
            System.err.println("❌ Erreur: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur de démarrage")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de démarrer le quiz: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/quiz-session/resume/{sessionId}
     * Reprendre une session existante
     */
    @GetMapping("/resume/{sessionId}")
    public ResponseEntity<?> resumeQuiz(@PathVariable("sessionId") Long sessionId) {
        try {
            System.out.println("📥 Reprise de la session #" + sessionId);

            QuizSessionDTO session = quizSessionService.resumeQuiz(sessionId);

            System.out.println("✅ Session reprise");
            return ResponseEntity.ok(session);
        } catch (RuntimeException e) {
            System.err.println("❌ Erreur: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur de reprise")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de reprendre la session: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * POST /api/quiz-session/submit-answer
     * Soumettre une réponse à une question
     */
    @PostMapping("/submit-answer")
    public ResponseEntity<?> submitAnswer(@RequestBody SubmitAnswerDTO submitDTO) {
        try {
            System.out.println("📥 Soumission de réponse - Session: " + submitDTO.getSessionId() +
                    ", Question: " + submitDTO.getQuestionId());

            AnswerFeedbackDTO feedback = quizSessionService.submitAnswer(submitDTO);

            System.out.println("✅ Réponse soumise - Correcte: " + feedback.getIsCorrect());
            return ResponseEntity.ok(feedback);
        } catch (RuntimeException e) {
            System.err.println("❌ Erreur: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur de soumission")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de soumettre la réponse: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * POST /api/quiz-session/complete/{sessionId}
     * Terminer le quiz et obtenir le résultat
     */
    @PostMapping("/complete/{sessionId}")
    public ResponseEntity<?> completeQuiz(@PathVariable("sessionId") Long sessionId) {
        try {
            System.out.println("📥 Fin du quiz - Session: " + sessionId);

            QuizResult result = quizSessionService.completeQuiz(sessionId);

            System.out.println("✅ Quiz terminé - Score: " + result.getScore() + "%");
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            System.err.println("❌ Erreur: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ErrorResponse.builder()
                            .error("Erreur de finalisation")
                            .message(e.getMessage())
                            .status(HttpStatus.BAD_REQUEST.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de terminer le quiz: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }
}