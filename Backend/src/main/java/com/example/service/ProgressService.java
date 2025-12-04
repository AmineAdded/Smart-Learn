package com.example.service;

import com.example.dto.*;
import com.example.model.User;
import com.example.model.UserProgress;
import com.example.model.QuizResult;
import com.example.repository.UserProgressRepository;
import com.example.repository.QuizResultRepository;
import com.example.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProgressService {

    @Autowired
    private UserProgressRepository userProgressRepository;

    @Autowired
    private QuizResultRepository quizResultRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupérer ou créer le progrès utilisateur
     */
    @Transactional
    public UserProgress getOrCreateUserProgress(User user) {
        return userProgressRepository.findByUser(user)
                .orElseGet(() -> {
                    UserProgress progress = UserProgress.builder()
                            .user(user)
                            .totalXp(0)
                            .currentLevel(1)
                            .quizCompleted(0)
                            .quizSucceeded(0)
                            .totalStudyTimeMinutes(0)
                            .videosWatched(0)
                            .averageSuccessRate(0.0)
                            .currentStreak(0)
                            .longestStreak(0)
                            .lastActivityDate(LocalDateTime.now())
                            .build();
                    return userProgressRepository.save(progress);
                });
    }

    /**
     * Obtenir les statistiques complètes de l'utilisateur
     */
    public UserProgressDTO getUserProgress() {
        User user = getCurrentUser();
        UserProgress progress = getOrCreateUserProgress(user);

        return UserProgressDTO.builder()
                .userId(user.getId())
                .userName(user.getNom() + " " + user.getPrenom())
                .userEmail(user.getEmail())
                .niveau(user.getNiveau())
                .totalXp(progress.getTotalXp())
                .currentLevel(progress.getCurrentLevel())
                .quizCompleted(progress.getQuizCompleted())
                .quizSucceeded(progress.getQuizSucceeded())
                .totalStudyTimeMinutes(progress.getTotalStudyTimeMinutes())
                .videosWatched(progress.getVideosWatched())
                .averageSuccessRate(progress.getAverageSuccessRate())
                .xpForNextLevel(progress.getXpForNextLevel())
                .xpProgressInCurrentLevel(progress.getXpProgressInCurrentLevel())
                .progressPercentage(progress.getProgressPercentage())
                .currentStreak(progress.getCurrentStreak())
                .longestStreak(progress.getLongestStreak())
                .lastActivityDate(progress.getLastActivityDate())
                .createdAt(progress.getCreatedAt())
                .studyTimeFormatted(formatStudyTime(progress.getTotalStudyTimeMinutes()))
                .levelTitle(getLevelTitle(progress.getCurrentLevel()))
                .totalQuizAttempts(progress.getQuizCompleted())
                .build();
    }

    /**
     * Obtenir les statistiques détaillées
     */
    public StatisticsDTO getDetailedStatistics() {
        User user = getCurrentUser();
        UserProgress progress = getOrCreateUserProgress(user);

        List<StatisticsDTO.SubjectProgress> subjectProgress = getSubjectProgress(user.getId());
        List<StatisticsDTO.RecentActivity> recentActivities = getRecentActivities(user.getId());

        Long rank = userProgressRepository.countUsersWithMoreXp(progress.getTotalXp()) + 1;
        Long totalUsers = userProgressRepository.countTotalUsers();

        List<StatisticsDTO.Goal> goals = generateGoals(progress);

        return StatisticsDTO.builder()
                .totalXp(progress.getTotalXp())
                .currentLevel(progress.getCurrentLevel())
                .quizCompleted(progress.getQuizCompleted())
                .quizSucceeded(progress.getQuizSucceeded())
                .totalStudyTimeMinutes(progress.getTotalStudyTimeMinutes())
                .videosWatched(progress.getVideosWatched())
                .averageSuccessRate(progress.getAverageSuccessRate())
                .subjectProgressList(subjectProgress)
                .recentActivities(recentActivities)
                .globalRank(rank.intValue())
                .totalUsers(totalUsers.intValue())
                .goals(goals)
                .build();
    }

    /**
     * Obtenir les informations de niveau
     */
    public LevelInfoDTO getLevelInfo() {
        User user = getCurrentUser();
        UserProgress progress = getOrCreateUserProgress(user);

        return LevelInfoDTO.builder()
                .currentLevel(progress.getCurrentLevel())
                .levelTitle(getLevelTitle(progress.getCurrentLevel()))
                .levelIcon(getLevelIcon(progress.getCurrentLevel()))
                .currentXp(progress.getTotalXp())
                .xpForNextLevel(progress.getXpForNextLevel())
                .xpProgressInCurrentLevel(progress.getXpProgressInCurrentLevel())
                .progressPercentage(progress.getProgressPercentage())
                .xpNeeded(1000 - progress.getXpProgressInCurrentLevel())
                .currentLevelBenefits(getLevelBenefits(progress.getCurrentLevel()))
                .nextLevelBenefits(getLevelBenefits(progress.getCurrentLevel() + 1))
                .badgeUrl("/badges/level_" + progress.getCurrentLevel() + ".png")
                .badgeColor(getLevelColor(progress.getCurrentLevel()))
                .build();
    }

    /**
     * Obtenir la progression hebdomadaire
     */
    // public WeeklyProgressDTO getWeeklyProgress() {
    //     String email = SecurityContextHolder.getContext().getAuthentication().getName();
    //     User user = userRepository.findByEmail(email)
    //         .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

    //     UserProgress progress = getOrCreateUserProgress(user);

    //     LocalDateTime now = LocalDateTime.now();
    //     LocalDateTime currentWeekStart = now.with(DayOfWeek.MONDAY).truncatedTo(ChronoUnit.DAYS);
    //     LocalDateTime currentWeekEnd = currentWeekStart.plusDays(7);
    //     LocalDateTime lastWeekStart = currentWeekStart.minusWeeks(1);
    //     LocalDateTime lastWeekEnd = currentWeekStart;

    //     List<QuizResult> currentWeekResults = quizResultRepository.findByUserIdAndDateRange(
    //         user.getId(), currentWeekStart, currentWeekEnd
    //     );

    //     List<QuizResult> lastWeekResults = quizResultRepository.findByUserIdAndDateRange(
    //         user.getId(), lastWeekStart, lastWeekEnd
    //     );

    //     int currentWeekXp = currentWeekResults.stream()
    //         .mapToInt(QuizResult::getXpEarned)
    //         .sum();

    //     int lastWeekXp = lastWeekResults.stream()
    //         .mapToInt(QuizResult::getXpEarned)
    //         .sum();

    //     double changePercentage = 0.0;
    //     if (lastWeekXp > 0) {
    //         changePercentage = ((double) (currentWeekXp - lastWeekXp) / lastWeekXp) * 100;
    //     } else if (currentWeekXp > 0) {
    //         changePercentage = 100.0;
    //     }

    //     List<WeeklyProgressDTO.DailyProgress> dailyProgress = new ArrayList<>();
    //     String[] dayLabels = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};

    //     for (int i = 0; i < 7; i++) {
    //         LocalDateTime dayStart = currentWeekStart.plusDays(i);
    //         LocalDateTime dayEnd = dayStart.plusDays(1);

    //         int dayXp = currentWeekResults.stream()
    //             .filter(qr -> !qr.getCompletedAt().isBefore(dayStart) && qr.getCompletedAt().isBefore(dayEnd))
    //             .mapToInt(QuizResult::getXpEarned)
    //             .sum();

    //         int quizCount = (int) currentWeekResults.stream()
    //             .filter(qr -> !qr.getCompletedAt().isBefore(dayStart) && qr.getCompletedAt().isBefore(dayEnd))
    //             .count();

    //         int studyTime = currentWeekResults.stream()
    //             .filter(qr -> !qr.getCompletedAt().isBefore(dayStart) && qr.getCompletedAt().isBefore(dayEnd))
    //             .mapToInt(QuizResult::getTimeSpentMinutes)
    //             .sum();

    //         boolean hasActivity = dayXp > 0;

    //         WeeklyProgressDTO.DailyProgress dayProgress = WeeklyProgressDTO.DailyProgress.builder()
    //             .day(dayLabels[i])
    //             .fullDate(dayStart.format(DateTimeFormatter.ISO_DATE))
    //             .xpEarned(dayXp)
    //             .quizCompleted(quizCount)
    //             .studyTimeMinutes(studyTime)
    //             .hasActivity(hasActivity)
    //             .build();

    //         dailyProgress.add(dayProgress);
    //     }

    //     System.out.println("=== WEEKLY PROGRESS DEBUG ===");
    //     System.out.println("Total XP (UserProgress): " + progress.getTotalXp());
    //     System.out.println("Current Week XP (QuizResults): " + currentWeekXp);
    //     System.out.println("Last Week XP (QuizResults): " + lastWeekXp);
    //     System.out.println("Number of results this week: " + currentWeekResults.size());
    //     System.out.println("Daily progress items: " + dailyProgress.size());

    //     int totalFromDaily = dailyProgress.stream()
    //         .mapToInt(WeeklyProgressDTO.DailyProgress::getXpEarned)
    //         .sum();
    //     System.out.println("Total from daily progress: " + totalFromDaily);
    //     System.out.println("============================");

    //     return WeeklyProgressDTO.builder()
    //         .currentWeekXp(currentWeekXp)
    //         .lastWeekXp(lastWeekXp)
    //         .changePercentage(changePercentage)
    //         .dailyProgress(dailyProgress)
    //         .build();
    // }
    /**
     * Obtenir la progression hebdomadaire
     * 🎯 VERSION AVEC DEBUG ULTRA-DÉTAILLÉ
     */
    public WeeklyProgressDTO getWeeklyProgress() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        UserProgress progress = getOrCreateUserProgress(user);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime currentWeekStart = now.with(DayOfWeek.MONDAY).truncatedTo(ChronoUnit.DAYS);
        LocalDateTime currentWeekEnd = currentWeekStart.plusDays(7);
        LocalDateTime lastWeekStart = currentWeekStart.minusWeeks(1);
        LocalDateTime lastWeekEnd = currentWeekStart;

        System.out.println("═══════════════════════════════════════════");
        System.out.println("📊 WEEKLY PROGRESS - DEBUG ULTRA-DÉTAILLÉ");
        System.out.println("═══════════════════════════════════════════");
        System.out.println("👤 User ID: " + user.getId());
        System.out.println("👤 Email: " + user.getEmail());
        System.out.println("📅 Maintenant: " + now);
        System.out.println("📅 Semaine courante: " + currentWeekStart + " → " + currentWeekEnd);
        System.out.println("📅 Semaine dernière: " + lastWeekStart + " → " + lastWeekEnd);
        System.out.println("───────────────────────────────────────────");

        // 🔍 ÉTAPE 1: Compter TOUS les résultats de l'utilisateur
        Integer totalResults = quizResultRepository.countByUserId(user.getId());
        System.out.println("📊 Total QuizResults pour cet utilisateur: " + totalResults);

        if (totalResults == null || totalResults == 0) {
            System.out.println("⚠️ AUCUN QUIZ RESULT TROUVÉ !");
            System.out.println("═══════════════════════════════════════════");
            return WeeklyProgressDTO.builder()
                    .currentWeekXp(0)
                    .lastWeekXp(0)
                    .changePercentage(0.0)
                    .dailyProgress(createEmptyDailyProgress(currentWeekStart))
                    .build();
        }

        // 🔍 ÉTAPE 2: Récupérer le dernier résultat pour vérifier
        List<QuizResult> latestResults = quizResultRepository.findLatestByUserId(
                user.getId(),
                PageRequest.of(0, 1)
        );

        if (!latestResults.isEmpty()) {
            QuizResult latest = latestResults.get(0);
            System.out.println("📌 DERNIER QuizResult:");
            System.out.println("   - ID: " + latest.getId());
            System.out.println("   - Quiz: " + latest.getQuiz().getTitle());
            System.out.println("   - Score: " + latest.getScore() + "%");
            System.out.println("   - XP Gagné: " + latest.getXpEarned());
            System.out.println("   - Completed At: " + latest.getCompletedAt());

            boolean isInCurrentWeek = latest.getCompletedAt() != null &&
                    !latest.getCompletedAt().isBefore(currentWeekStart) &&
                    latest.getCompletedAt().isBefore(currentWeekEnd);

            System.out.println("   - Dans semaine courante ? " + isInCurrentWeek);

            if (!isInCurrentWeek) {
                System.out.println("⚠️ Le dernier quiz n'est PAS dans la semaine courante !");
            }
        }
        System.out.println("───────────────────────────────────────────");

        // 🔍 ÉTAPE 3: Compter les résultats dans la semaine courante
        Long countCurrentWeek = quizResultRepository.countByUserIdAndDateRange(
                user.getId(), currentWeekStart, currentWeekEnd
        );
        System.out.println("🔢 Nombre de résultats semaine courante (COUNT): " + countCurrentWeek);

        // 🔍 ÉTAPE 4: Récupérer TOUS les résultats de la semaine courante
        List<QuizResult> currentWeekResults = quizResultRepository.findByUserIdAndDateRange(
                user.getId(), currentWeekStart, currentWeekEnd
        );

        System.out.println("📊 Résultats semaine courante (LISTE): " + currentWeekResults.size());

        if (currentWeekResults.isEmpty()) {
            System.out.println("⚠️ LA LISTE EST VIDE ! Vérifions pourquoi...");

            // Test avec une méthode alternative
            List<QuizResult> allResultsFromMonday = quizResultRepository.findByUserIdFromDate(
                    user.getId(), currentWeekStart
            );
            System.out.println("📊 Résultats depuis lundi (méthode alternative): " + allResultsFromMonday.size());

            if (!allResultsFromMonday.isEmpty()) {
                System.out.println("✅ TROUVÉ avec méthode alternative ! Utilisons celle-ci.");
                currentWeekResults = allResultsFromMonday;
            }
        }

        // Afficher les détails de chaque résultat
        for (int i = 0; i < currentWeekResults.size(); i++) {
            QuizResult qr = currentWeekResults.get(i);
            System.out.println("   [" + (i+1) + "] Quiz: " + qr.getQuiz().getTitle());
            System.out.println("       - Score: " + qr.getScore() + "%");
            System.out.println("       - XP: " + qr.getXpEarned());
            System.out.println("       - Date: " + qr.getCompletedAt());
            System.out.println("       - User ID: " + qr.getUser().getId());
        }
        System.out.println("───────────────────────────────────────────");

        // 🔍 ÉTAPE 5: Récupérer les résultats de la semaine dernière
        List<QuizResult> lastWeekResults = quizResultRepository.findByUserIdAndDateRange(
                user.getId(), lastWeekStart, lastWeekEnd
        );

        System.out.println("📊 Résultats semaine dernière: " + lastWeekResults.size());
        System.out.println("───────────────────────────────────────────");

        // 🔍 ÉTAPE 6: Calculer les XP
        int currentWeekXp = currentWeekResults.stream()
                .mapToInt(qr -> qr.getXpEarned() != null ? qr.getXpEarned() : 0)
                .sum();

        int lastWeekXp = lastWeekResults.stream()
                .mapToInt(qr -> qr.getXpEarned() != null ? qr.getXpEarned() : 0)
                .sum();

        System.out.println("💰 XP semaine courante (calculé): " + currentWeekXp);
        System.out.println("💰 XP semaine dernière (calculé): " + lastWeekXp);
        System.out.println("💰 Total XP (UserProgress): " + progress.getTotalXp());

        double changePercentage = 0.0;
        if (lastWeekXp > 0) {
            changePercentage = ((double) (currentWeekXp - lastWeekXp) / lastWeekXp) * 100;
        } else if (currentWeekXp > 0) {
            changePercentage = 100.0;
        }

        System.out.println("📈 Changement: " + String.format("%.1f", changePercentage) + "%");
        System.out.println("───────────────────────────────────────────");

        // 🔍 ÉTAPE 7: Construire la progression journalière
        List<WeeklyProgressDTO.DailyProgress> dailyProgress = new ArrayList<>();
        String[] dayLabels = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};

        System.out.println("📅 PROGRESSION JOURNALIÈRE:");
        for (int i = 0; i < 7; i++) {
            LocalDateTime dayStart = currentWeekStart.plusDays(i);
            LocalDateTime dayEnd = dayStart.plusDays(1);

            int dayXp = currentWeekResults.stream()
                    .filter(qr -> qr.getCompletedAt() != null &&
                            !qr.getCompletedAt().isBefore(dayStart) &&
                            qr.getCompletedAt().isBefore(dayEnd))
                    .mapToInt(qr -> qr.getXpEarned() != null ? qr.getXpEarned() : 0)
                    .sum();

            int quizCount = (int) currentWeekResults.stream()
                    .filter(qr -> qr.getCompletedAt() != null &&
                            !qr.getCompletedAt().isBefore(dayStart) &&
                            qr.getCompletedAt().isBefore(dayEnd))
                    .count();

            int studyTime = currentWeekResults.stream()
                    .filter(qr -> qr.getCompletedAt() != null &&
                            !qr.getCompletedAt().isBefore(dayStart) &&
                            qr.getCompletedAt().isBefore(dayEnd))
                    .mapToInt(qr -> qr.getTimeSpentMinutes() != null ? qr.getTimeSpentMinutes() : 0)
                    .sum();

            boolean hasActivity = dayXp > 0;

            String activityIndicator = hasActivity ? "✅" : "⭕";
            System.out.println("   " + activityIndicator + " " + dayLabels[i] + " (" +
                    dayStart.toLocalDate() + "): " +
                    dayXp + " XP, " + quizCount + " quiz, " +
                    studyTime + " min");

            WeeklyProgressDTO.DailyProgress dayProgress = WeeklyProgressDTO.DailyProgress.builder()
                    .day(dayLabels[i])
                    .fullDate(dayStart.format(DateTimeFormatter.ISO_DATE))
                    .xpEarned(dayXp)
                    .quizCompleted(quizCount)
                    .studyTimeMinutes(studyTime)
                    .hasActivity(hasActivity)
                    .build();

            dailyProgress.add(dayProgress);
        }

        int totalFromDaily = dailyProgress.stream()
                .mapToInt(WeeklyProgressDTO.DailyProgress::getXpEarned)
                .sum();

        System.out.println("───────────────────────────────────────────");
        System.out.println("🔢 Total XP (somme daily): " + totalFromDaily);

        if (totalFromDaily != currentWeekXp) {
            System.out.println("⚠️ INCOHÉRENCE ! Total daily ≠ currentWeekXp");
        } else {
            System.out.println("✅ Cohérence vérifiée");
        }

        System.out.println("═══════════════════════════════════════════");

        return WeeklyProgressDTO.builder()
                .currentWeekXp(currentWeekXp)
                .lastWeekXp(lastWeekXp)
                .changePercentage(changePercentage)
                .dailyProgress(dailyProgress)
                .build();
    }

    /**
     * Créer une progression journalière vide
     */
    private List<WeeklyProgressDTO.DailyProgress> createEmptyDailyProgress(LocalDateTime weekStart) {
        List<WeeklyProgressDTO.DailyProgress> dailyProgress = new ArrayList<>();
        String[] dayLabels = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};

        for (int i = 0; i < 7; i++) {
            LocalDateTime dayStart = weekStart.plusDays(i);
            dailyProgress.add(WeeklyProgressDTO.DailyProgress.builder()
                    .day(dayLabels[i])
                    .fullDate(dayStart.format(DateTimeFormatter.ISO_DATE))
                    .xpEarned(0)
                    .quizCompleted(0)
                    .studyTimeMinutes(0)
                    .hasActivity(false)
                    .build());
        }

        return dailyProgress;
    }
    /**
     * Mettre à jour le progrès après un quiz
     */





    // @Transactional
    // public void updateProgressAfterQuiz(QuizResult result) {
    //     User user = result.getUser();
    //     UserProgress progress = getOrCreateUserProgress(user);

    //     progress.addXp(result.getXpEarned());
    //     progress.incrementQuizCompleted();

    //     if (result.getPassed()) {
    //         progress.incrementQuizSucceeded();
    //     }

    //     progress.addStudyTime(result.getTimeSpentMinutes());
    //     progress.updateSuccessRate();
    //     progress.setLastActivityDate(LocalDateTime.now());

    //     updateStreak(progress);

    //     userProgressRepository.save(progress);
    // }
    /**
     * Mettre à jour le progrès après un quiz
     * 🎯 FIX: Cette méthode doit être appelée APRÈS la sauvegarde du QuizResult
     */
    @Transactional
    public void updateProgressAfterQuiz(QuizResult result) {
        User user = result.getUser();
        UserProgress progress = getOrCreateUserProgress(user);

        System.out.println("🔄 Mise à jour du progrès après quiz:");
        System.out.println("  - Quiz: " + result.getQuiz().getTitle());
        System.out.println("  - XP gagné: " + result.getXpEarned());
        System.out.println("  - Temps passé: " + result.getTimeSpentMinutes() + " min");
        System.out.println("  - Réussi: " + result.getPassed());

        // ✅ Ajouter les XP
        int oldXp = progress.getTotalXp();
        progress.addXp(result.getXpEarned());
        System.out.println("  - XP: " + oldXp + " → " + progress.getTotalXp());

        // ✅ Incrémenter le nombre de quiz complétés
        int oldQuizCount = progress.getQuizCompleted();
        progress.incrementQuizCompleted();
        System.out.println("  - Quiz complétés: " + oldQuizCount + " → " + progress.getQuizCompleted());

        // ✅ Incrémenter le nombre de quiz réussis si passé
        if (result.getPassed()) {
            int oldSuccessCount = progress.getQuizSucceeded();
            progress.incrementQuizSucceeded();
            System.out.println("  - Quiz réussis: " + oldSuccessCount + " → " + progress.getQuizSucceeded());
        }

        // ✅ Ajouter le temps d'étude
        int oldStudyTime = progress.getTotalStudyTimeMinutes();
        progress.addStudyTime(result.getTimeSpentMinutes());
        System.out.println("  - Temps d'étude: " + oldStudyTime + " → " + progress.getTotalStudyTimeMinutes() + " min");

        // ✅ Mettre à jour le taux de réussite
        progress.updateSuccessRate();
        System.out.println("  - Taux de réussite: " + progress.getAverageSuccessRate() + "%");

        // ✅ Mettre à jour la dernière activité
        progress.setLastActivityDate(LocalDateTime.now());

        // ✅ Mettre à jour le streak
        updateStreak(progress);
        System.out.println("  - Streak actuel: " + progress.getCurrentStreak() + " jours");
        System.out.println("  - Meilleur streak: " + progress.getLongestStreak() + " jours");

        // ✅ Sauvegarder les changements
        userProgressRepository.saveAndFlush(progress);
        System.out.println("✅ Progrès sauvegardé avec succès");
    }
    /**
     * Ajouter des XP à l'utilisateur
     */
    @Transactional
    public AddXpResponse addXp(Integer xpAmount, String reason, String source) {
        User user = getCurrentUser();
        UserProgress progress = getOrCreateUserProgress(user);

        Integer oldLevel = progress.getCurrentLevel();

        progress.addXp(xpAmount);
        progress.setLastActivityDate(LocalDateTime.now());
        updateStreak(progress);

        userProgressRepository.save(progress);

        Boolean leveledUp = progress.getCurrentLevel() > oldLevel;

        String message;
        if (leveledUp) {
            message = String.format(
                    "Félicitations ! Vous avez gagné %d XP et atteint le niveau %d (%s) !",
                    xpAmount,
                    progress.getCurrentLevel(),
                    getLevelTitle(progress.getCurrentLevel())
            );
        } else {
            message = String.format("Vous avez gagné %d XP !", xpAmount);
        }

        return AddXpResponse.builder()
                .xpAdded(xpAmount)
                .totalXp(progress.getTotalXp())
                .currentLevel(progress.getCurrentLevel())
                .levelTitle(getLevelTitle(progress.getCurrentLevel()))
                .xpForNextLevel(progress.getXpForNextLevel())
                .xpProgressInCurrentLevel(progress.getXpProgressInCurrentLevel())
                .progressPercentage(progress.getProgressPercentage())
                .leveledUp(leveledUp)
                .newLevel(leveledUp ? progress.getCurrentLevel() : null)
                .message(message)
                .build();
    }

    // ============= MÉTHODES PRIVÉES =============

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    private List<StatisticsDTO.SubjectProgress> getSubjectProgress(Long userId) {
        List<Object[]> results = quizResultRepository.getProgressBySubject(userId);
        return results.stream()
                .map(row -> StatisticsDTO.SubjectProgress.builder()
                        .subject((String) row[0])
                        .quizCompleted(((Long) row[1]).intValue())
                        .successRate(((Double) row[2]))
                        .xpEarned(((Long) row[3]).intValue())
                        .icon(getSubjectIcon((String) row[0]))
                        .build())
                .collect(Collectors.toList());
    }

    private List<StatisticsDTO.RecentActivity> getRecentActivities(Long userId) {
        List<QuizResult> recentResults = quizResultRepository.findRecentByUserId(
                userId, PageRequest.of(0, 10)
        );

        return recentResults.stream()
                .map(result -> StatisticsDTO.RecentActivity.builder()
                        .type("QUIZ")
                        .title(result.getQuiz().getTitle())
                        .description("Score: " + result.getScore() + "/" + result.getTotalQuestions())
                        .xpEarned(result.getXpEarned())
                        .date(result.getCompletedAt())
                        .icon("📝")
                        .build())
                .collect(Collectors.toList());
    }

    private List<StatisticsDTO.Goal> generateGoals(UserProgress progress) {
        List<StatisticsDTO.Goal> goals = new ArrayList<>();

        goals.add(StatisticsDTO.Goal.builder()
                .title("Maître des Quiz")
                .description("Compléter 50 quiz")
                .current(progress.getQuizCompleted())
                .target(50)
                .progress((progress.getQuizCompleted() * 100.0) / 50)
                .completed(progress.getQuizCompleted() >= 50)
                .build());

        goals.add(StatisticsDTO.Goal.builder()
                .title("Expert")
                .description("Atteindre le niveau 10")
                .current(progress.getCurrentLevel())
                .target(10)
                .progress((progress.getCurrentLevel() * 100.0) / 10)
                .completed(progress.getCurrentLevel() >= 10)
                .build());

        return goals;
    }

    public void updateStreak(UserProgress progress) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastActivity = progress.getLastActivityDate();

        if (lastActivity == null) {
            progress.setCurrentStreak(1);
            progress.setLongestStreak(1);
            return;
        }

        long daysBetween = ChronoUnit.DAYS.between(
                lastActivity.toLocalDate(), now.toLocalDate()
        );

        if (daysBetween == 0) {
            return;
        } else if (daysBetween == 1) {
            progress.setCurrentStreak(progress.getCurrentStreak() + 1);
            if (progress.getCurrentStreak() > progress.getLongestStreak()) {
                progress.setLongestStreak(progress.getCurrentStreak());
            }
        } else {
            progress.setCurrentStreak(1);
        }

        progress.setLastActivityDate(now);
    }

    private String formatStudyTime(int minutes) {
        if (minutes < 60) {
            return minutes + "min";
        }
        int hours = minutes / 60;
        int remainingMinutes = minutes % 60;
        return hours + "h" + (remainingMinutes > 0 ? remainingMinutes + "min" : "");
    }

    private String getLevelTitle(int level) {
        if (level >= 20) return "Grand Maître";
        if (level >= 15) return "Maître";
        if (level >= 10) return "Expert";
        if (level >= 7) return "Avancé";
        if (level >= 5) return "Intermédiaire";
        if (level >= 3) return "Débutant";
        return "Novice";
    }

    private String getLevelIcon(int level) {
        if (level >= 20) return "👑";
        if (level >= 15) return "🏆";
        if (level >= 10) return "⭐";
        if (level >= 5) return "📚";
        return "📖";
    }

    private String getLevelBenefits(int level) {
        return "Accès à " + (level * 5) + " quiz premium, Badge niveau " + level;
    }

    private String getLevelColor(int level) {
        if (level >= 15) return "#FFD700";
        if (level >= 10) return "#C0C0C0";
        if (level >= 5) return "#CD7F32";
        return "#5B9FD8";
    }

    private String getSubjectIcon(String subject) {
        switch (subject.toLowerCase()) {
            case "mathématiques": return "📐";
            case "physique": return "⚡";
            case "chimie": return "🧪";
            case "histoire": return "📜";
            case "français": return "📖";
            default: return "📚";
        }
    }
}