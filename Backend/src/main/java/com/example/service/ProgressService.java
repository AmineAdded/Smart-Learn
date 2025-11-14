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
        
        // Statistiques par matière
        List<StatisticsDTO.SubjectProgress> subjectProgress = getSubjectProgress(user.getId());
        
        // Activités récentes
        List<StatisticsDTO.RecentActivity> recentActivities = getRecentActivities(user.getId());
        
        // Classement
        Long rank = userProgressRepository.countUsersWithMoreXp(progress.getTotalXp()) + 1;
        Long totalUsers = userProgressRepository.countTotalUsers();
        
        // Objectifs
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
    public WeeklyProgressDTO getWeeklyProgress() {
        User user = getCurrentUser();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime weekStart = now.with(DayOfWeek.MONDAY).truncatedTo(ChronoUnit.DAYS);
        LocalDateTime weekEnd = now.with(DayOfWeek.SUNDAY).plusDays(1).truncatedTo(ChronoUnit.DAYS);
        
        List<QuizResult> thisWeekResults = quizResultRepository.findByUserIdAndDateRange(
            user.getId(), weekStart, weekEnd
        );
        
        LocalDateTime lastWeekStart = weekStart.minusWeeks(1);
        LocalDateTime lastWeekEnd = weekEnd.minusWeeks(1);
        List<QuizResult> lastWeekResults = quizResultRepository.findByUserIdAndDateRange(
            user.getId(), lastWeekStart, lastWeekEnd
        );
        
        int currentWeekXp = thisWeekResults.stream().mapToInt(QuizResult::getXpEarned).sum();
        int lastWeekXp = lastWeekResults.stream().mapToInt(QuizResult::getXpEarned).sum();
        
        double changePercentage = lastWeekXp == 0 ? 100.0 :
            ((currentWeekXp - lastWeekXp) * 100.0 / lastWeekXp);
        
        List<WeeklyProgressDTO.DailyProgress> dailyProgress = generateDailyProgress(
            weekStart, thisWeekResults
        );
        
        return WeeklyProgressDTO.builder()
            .currentWeekXp(currentWeekXp)
            .lastWeekXp(lastWeekXp)
            .changePercentage(changePercentage)
            .dailyProgress(dailyProgress)
            .build();
    }

    /**
     * Mettre à jour le progrès après un quiz
     */
    @Transactional
    public void updateProgressAfterQuiz(QuizResult result) {
        User user = result.getUser();
        UserProgress progress = getOrCreateUserProgress(user);
        
        progress.addXp(result.getXpEarned());
        progress.incrementQuizCompleted();
        
        if (result.getPassed()) {
            progress.incrementQuizSucceeded();
        }
        
        progress.addStudyTime(result.getTimeSpentMinutes());
        progress.updateSuccessRate();
        progress.setLastActivityDate(LocalDateTime.now());
        
        updateStreak(progress);
        
        userProgressRepository.save(progress);
    }

    // Méthodes utilitaires privées
    
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

    private List<WeeklyProgressDTO.DailyProgress> generateDailyProgress(
        LocalDateTime weekStart, List<QuizResult> results
    ) {
        List<WeeklyProgressDTO.DailyProgress> dailyProgress = new ArrayList<>();
        String[] days = {"Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"};
        
        for (int i = 0; i < 7; i++) {
            LocalDateTime day = weekStart.plusDays(i);
            LocalDateTime dayEnd = day.plusDays(1);
            
            List<QuizResult> dayResults = results.stream()
                .filter(r -> r.getCompletedAt().isAfter(day) && 
                            r.getCompletedAt().isBefore(dayEnd))
                .collect(Collectors.toList());
            
            int xp = dayResults.stream().mapToInt(QuizResult::getXpEarned).sum();
            int quizCount = dayResults.size();
            int studyTime = dayResults.stream()
                .mapToInt(QuizResult::getTimeSpentMinutes).sum();
            
            dailyProgress.add(WeeklyProgressDTO.DailyProgress.builder()
                .day(days[i])
                .fullDate(day.format(DateTimeFormatter.ISO_DATE))
                .xpEarned(xp)
                .quizCompleted(quizCount)
                .studyTimeMinutes(studyTime)
                .hasActivity(quizCount > 0)
                .build());
        }
        
        return dailyProgress;
    }

    private void updateStreak(UserProgress progress) {
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
            // Même jour
            return;
        } else if (daysBetween == 1) {
            // Jour consécutif
            progress.setCurrentStreak(progress.getCurrentStreak() + 1);
            if (progress.getCurrentStreak() > progress.getLongestStreak()) {
                progress.setLongestStreak(progress.getCurrentStreak());
            }
        } else {
            // Streak cassé
            progress.setCurrentStreak(1);
        }
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
        if (level >= 15) return "#FFD700"; // Gold
        if (level >= 10) return "#C0C0C0"; // Silver
        if (level >= 5) return "#CD7F32";  // Bronze
        return "#5B9FD8"; // Blue
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
