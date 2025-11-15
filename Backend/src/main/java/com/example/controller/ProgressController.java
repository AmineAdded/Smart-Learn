package com.example.controller;

import com.example.dto.*;
import com.example.service.ProgressService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/progress")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ProgressController {

    @Autowired
    private ProgressService progressService;

    /**
     * GET /api/progress
     * Récupérer le progrès de l'utilisateur
     */
    @GetMapping
    public ResponseEntity<?> getUserProgress() {
        try {
            UserProgressDTO progress = progressService.getUserProgress();
            return ResponseEntity.ok(progress);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer les statistiques: " + e.getMessage())
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * GET /api/progress/statistics
     * Récupérer les statistiques détaillées
     */
    @GetMapping("/statistics")
    public ResponseEntity<?> getStatistics() {
        try {
            StatisticsDTO statistics = progressService.getDetailedStatistics();
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer les statistiques détaillées: " + e.getMessage())
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * GET /api/progress/level
     * Récupérer les informations de niveau
     */
    @GetMapping("/level")
    public ResponseEntity<?> getLevelInfo() {
        try {
            LevelInfoDTO levelInfo = progressService.getLevelInfo();
            return ResponseEntity.ok(levelInfo);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer les informations de niveau: " + e.getMessage())
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * GET /api/progress/weekly
     * Récupérer la progression hebdomadaire
     */
    @GetMapping("/weekly")
    public ResponseEntity<?> getWeeklyProgress() {
        try {
            WeeklyProgressDTO weeklyProgress = progressService.getWeeklyProgress();
            return ResponseEntity.ok(weeklyProgress);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer la progression hebdomadaire: " + e.getMessage())
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * GET /api/progress/summary
     * Récupérer un résumé simple des statistiques
     */
    @GetMapping("/summary")
    public ResponseEntity<?> getProgressSummary() {
        try {
            UserProgressDTO progress = progressService.getUserProgress();
            
            // Créer un résumé simplifié
            var summary = new java.util.HashMap<String, Object>();
            summary.put("totalXp", progress.getTotalXp());
            summary.put("currentLevel", progress.getCurrentLevel());
            summary.put("levelTitle", progress.getLevelTitle());
            summary.put("quizCompleted", progress.getQuizCompleted());
            summary.put("successRate", progress.getAverageSuccessRate());
            summary.put("studyTime", progress.getStudyTimeFormatted());
            summary.put("progressPercentage", progress.getProgressPercentage());
            summary.put("currentStreak", progress.getCurrentStreak());
            
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer le résumé: " + e.getMessage())
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }
    


/**
 * POST /api/progress/xp
 * Ajouter des XP à l'utilisateur
 */
@PostMapping("/xp")
public ResponseEntity<?> addXp(@Valid @RequestBody AddXpRequest request) {
    try {
        AddXpResponse response = progressService.addXp(
            request.getXpAmount(),
            request.getReason(),
            request.getSource()
        );
        
        return ResponseEntity.ok(response);
    } catch (Exception e) {
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse.builder()
                .error("Erreur serveur")
                .message("Impossible d'ajouter l'XP: " + e.getMessage())
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .build());
    }
}
}
