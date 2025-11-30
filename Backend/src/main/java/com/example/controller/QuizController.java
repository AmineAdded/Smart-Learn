package com.example.controller;

import com.example.dto.ErrorResponse;
import com.example.dto.QuizDTO;
import com.example.dto.QuizDetailDTO;
import com.example.service.QuizService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quizzes")
@CrossOrigin(origins = "*", maxAge = 3600)
public class QuizController {

    @Autowired
    private QuizService quizService;

    /**
     * GET /api/quizzes
     * Récupérer tous les quiz actifs avec filtres optionnels
     */
    @GetMapping
    public ResponseEntity<?> getAllQuizzes(
            @RequestParam(name = "category", required = false) String category,
            @RequestParam(name = "difficulty", required = false) String difficulty,
            @RequestParam(name = "hasAI", required = false) Boolean hasAI
    ) {
        try {
            System.out.println("📥 Requête reçue - category: " + category + ", difficulty: " + difficulty + ", hasAI: " + hasAI);

            List<QuizDTO> quizzes = quizService.getQuizzes(category, difficulty, hasAI);

            System.out.println("✅ " + quizzes.size() + " quiz retournés");
            return ResponseEntity.ok(quizzes);
        } catch (Exception e) {
            System.err.println("❌ Erreur dans getAllQuizzes: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les quiz: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/quizzes/{id}
     * Récupérer un quiz par son ID (version simple)
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getQuizById(@PathVariable("id") Long id) {
        try {
            System.out.println("📥 Récupération du quiz #" + id);

            QuizDTO quiz = quizService.getQuizById(id);
            return ResponseEntity.ok(quiz);
        } catch (RuntimeException e) {
            System.err.println("❌ Quiz non trouvé: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ErrorResponse.builder()
                            .error("Quiz non trouvé")
                            .message(e.getMessage())
                            .status(HttpStatus.NOT_FOUND.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer le quiz: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/quizzes/{id}/detail
     * Récupérer les détails complets d'un quiz avant de le commencer
     */
    @GetMapping("/{id}/detail")
    public ResponseEntity<?> getQuizDetail(@PathVariable("id") Long id) {
        try {
            System.out.println("📥 Récupération des détails du quiz #" + id);

            QuizDetailDTO quizDetail = quizService.getQuizDetail(id);

            System.out.println("✅ Détails du quiz récupérés: " + quizDetail.getTitle());
            return ResponseEntity.ok(quizDetail);
        } catch (RuntimeException e) {
            System.err.println("❌ Erreur: " + e.getMessage());

            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ErrorResponse.builder()
                            .error("Quiz non trouvé")
                            .message(e.getMessage())
                            .status(HttpStatus.NOT_FOUND.value())
                            .build());
        } catch (Exception e) {
            System.err.println("❌ Erreur serveur: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les détails: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/quizzes/categories
     * Récupérer toutes les catégories disponibles
     */
    @GetMapping("/categories")
    public ResponseEntity<?> getCategories() {
        try {
            System.out.println("📥 Récupération des catégories");

            List<String> categories = quizService.getAllCategories();

            System.out.println("✅ " + categories.size() + " catégories retournées");
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            System.err.println("❌ Erreur dans getCategories: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les catégories: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }

    /**
     * GET /api/quizzes/recommended
     * Récupérer les quiz recommandés pour l'utilisateur connecté
     */
    @GetMapping("/recommended")
    public ResponseEntity<?> getRecommendedQuizzes() {
        try {
            System.out.println("📥 Récupération des quiz recommandés");

            List<QuizDTO> quizzes = quizService.getRecommendedQuizzes();

            System.out.println("✅ " + quizzes.size() + " quiz recommandés retournés");
            return ResponseEntity.ok(quizzes);
        } catch (Exception e) {
            System.err.println("❌ Erreur dans getRecommendedQuizzes: " + e.getMessage());
            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ErrorResponse.builder()
                            .error("Erreur serveur")
                            .message("Impossible de récupérer les quiz recommandés: " + e.getMessage())
                            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                            .build());
        }
    }
}