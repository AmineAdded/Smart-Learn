package com.example.controller;

import com.example.dto.*;
import com.example.model.QuizResult;
import com.example.service.ProgressService;

import jakarta.validation.Valid;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import com.example.model.User;
import com.example.repository.QuizResultRepository;
import com.example.repository.UserRepository;

@RestController
@RequestMapping("/api/progress")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ProgressController {

    @Autowired
    private ProgressService progressService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private QuizResultRepository quizResultRepository;

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
            e.printStackTrace(); // Log pour debug
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
     * GET /api/progress/debug/weekly
     * Endpoint de débogage pour la progression hebdomadaire
     */
    @GetMapping("/debug/weekly")
    public ResponseEntity<?> debugWeeklyProgress() {
        try {
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime weekStart = now.with(DayOfWeek.MONDAY).truncatedTo(ChronoUnit.DAYS);
            LocalDateTime weekEnd = weekStart.plusDays(7);
            
            // Récupérer tous les quiz results de l'utilisateur
            List<QuizResult> allResults = quizResultRepository.findByUserId(user.getId());
            
            // Récupérer les résultats de cette semaine
            List<QuizResult> thisWeekResults = quizResultRepository.findByUserIdAndDateRange(
                user.getId(), weekStart, weekEnd
            );
            
            Map<String, Object> debugInfo = new HashMap<>();
            debugInfo.put("userId", user.getId());
            debugInfo.put("userEmail", user.getEmail());
            debugInfo.put("currentDate", now);
            debugInfo.put("weekStart", weekStart);
            debugInfo.put("weekEnd", weekEnd);
            debugInfo.put("totalQuizResults", allResults.size());
            debugInfo.put("thisWeekResults", thisWeekResults.size());
            
            // Détails de tous les quiz results
            List<Map<String, Object>> allResultsDetails = allResults.stream()
                .map(qr -> {
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("id", qr.getId());
                    detail.put("quizTitle", qr.getQuiz().getTitle());
                    detail.put("completedAt", qr.getCompletedAt());
                    detail.put("xpEarned", qr.getXpEarned());
                    detail.put("score", qr.getScore());
                    detail.put("dayOfWeek", qr.getCompletedAt().getDayOfWeek());
                    detail.put("isInCurrentWeek", 
                        !qr.getCompletedAt().isBefore(weekStart) && 
                        qr.getCompletedAt().isBefore(weekEnd));
                    return detail;
                })
                .collect(Collectors.toList());
            
            debugInfo.put("allResults", allResultsDetails);
            
            // Grouper par jour de la semaine
            Map<String, List<QuizResult>> resultsByDay = thisWeekResults.stream()
                .collect(Collectors.groupingBy(
                    qr -> qr.getCompletedAt().getDayOfWeek().toString()
                ));
            
            debugInfo.put("resultsByDayOfWeek", resultsByDay.entrySet().stream()
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    e -> e.getValue().size()
                )));
            
            return ResponseEntity.ok(debugInfo);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "error", "Erreur de débogage",
                    "message", e.getMessage()
                ));
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