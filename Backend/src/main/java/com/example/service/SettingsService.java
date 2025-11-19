package com.example.service;

import com.example.dto.Settings.UserSettingsResponse;
import com.example.model.User;
import com.example.model.UserSettings;
import com.example.repository.UserRepository;
import com.example.repository.UserSettingsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.Map;

@Service
public class SettingsService {

    @Autowired
    private UserSettingsRepository settingsRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupérer ou créer les paramètres de l'utilisateur
     */
    @Transactional
    public UserSettings getOrCreateUserSettings(User user) {
        return settingsRepository.findByUser(user)
            .orElseGet(() -> {
                UserSettings settings = UserSettings.builder()
                    .user(user)
                    .profileVisible(true)
                    .shareDataWithAI(true)
                    .showInLeaderboard(true)
                    .pushNotificationsEnabled(true)
                    .studyRemindersEnabled(true)
                    .newContentNotifications(true)
                    .theme("system")
                    .language("fr")
                    .offlineMode(false)
                    .morningTime("08:00")
                    .afternoonTime("14:00")
                    .eveningTime("20:00")
                    .reminderFrequency(1)
                    .activeDays("1,2,3,4,5,6,7")
                    .dailyReminderEnabled(true)
                    .build();
                return settingsRepository.save(settings);
            });
    }

    /**
     * Récupérer les paramètres de l'utilisateur connecté
     */
    public UserSettingsResponse getUserSettings() {
        User user = getCurrentUser();
        UserSettings settings = getOrCreateUserSettings(user);
        return buildSettingsResponse(settings);
    }

    /**
     * Mettre à jour les paramètres
     */
    @Transactional
    public UserSettingsResponse updateSettings(Map<String, Object> updates) {
        User user = getCurrentUser();
        UserSettings settings = getOrCreateUserSettings(user);

        System.out.println("🔵 Mise à jour reçue: " + updates);

        // Confidentialité
        if (updates.containsKey("profile_visible")) {
            settings.setProfileVisible((Boolean) updates.get("profile_visible"));
        }
        if (updates.containsKey("share_data_with_ai")) {
            settings.setShareDataWithAI((Boolean) updates.get("share_data_with_ai"));
        }
        if (updates.containsKey("show_in_leaderboard")) {
            settings.setShowInLeaderboard((Boolean) updates.get("show_in_leaderboard"));
        }

        // Notifications
        if (updates.containsKey("push_notifications_enabled")) {
            settings.setPushNotificationsEnabled((Boolean) updates.get("push_notifications_enabled"));
        }
        if (updates.containsKey("study_reminders_enabled")) {
            settings.setStudyRemindersEnabled((Boolean) updates.get("study_reminders_enabled"));
        }
        if (updates.containsKey("new_content_notifications")) {
            settings.setNewContentNotifications((Boolean) updates.get("new_content_notifications"));
        }

        // ✅ Horaires de notifications
        if (updates.containsKey("morning_time")) {
            String time = (String) updates.get("morning_time");
            if (isValidTime(time)) {
                settings.setMorningTime(time);
            }
        }
        if (updates.containsKey("afternoon_time")) {
            String time = (String) updates.get("afternoon_time");
            if (isValidTime(time)) {
                settings.setAfternoonTime(time);
            }
        }
        if (updates.containsKey("evening_time")) {
            String time = (String) updates.get("evening_time");
            if (isValidTime(time)) {
                settings.setEveningTime(time);
            }
        }

        // ✅ Fréquence des rappels
        if (updates.containsKey("reminder_frequency")) {
            Integer frequency = (Integer) updates.get("reminder_frequency");
            if (frequency != null && frequency >= 1 && frequency <= 3) {
                settings.setReminderFrequency(frequency);
            }
        }

        // ✅ Jours actifs
        if (updates.containsKey("active_days")) {
            settings.setActiveDays((String) updates.get("active_days"));
        }

        // ✅ Rappels quotidiens
        if (updates.containsKey("daily_reminder_enabled")) {
            settings.setDailyReminderEnabled((Boolean) updates.get("daily_reminder_enabled"));
        }

        // Préférences
        if (updates.containsKey("theme")) {
            String theme = (String) updates.get("theme");
            if (isValidTheme(theme)) {
                settings.setTheme(theme);
            }
        }
        if (updates.containsKey("language")) {
            String language = (String) updates.get("language");
            if (isValidLanguage(language)) {
                settings.setLanguage(language);
            }
        }
        if (updates.containsKey("offline_mode")) {
            settings.setOfflineMode((Boolean) updates.get("offline_mode"));
        }

        settings = settingsRepository.save(settings);
        System.out.println("✅ Paramètres mis à jour avec succès");
        
        return buildSettingsResponse(settings);
    }

    /**
     * Réinitialiser les paramètres par défaut
     */
    @Transactional
    public UserSettingsResponse resetToDefault() {
        User user = getCurrentUser();
        UserSettings settings = getOrCreateUserSettings(user);

        settings.setProfileVisible(true);
        settings.setShareDataWithAI(true);
        settings.setShowInLeaderboard(true);
        settings.setPushNotificationsEnabled(true);
        settings.setStudyRemindersEnabled(true);
        settings.setNewContentNotifications(true);
        settings.setTheme("system");
        settings.setLanguage("fr");
        settings.setOfflineMode(false);
        settings.setMorningTime("08:00");
        settings.setAfternoonTime("14:00");
        settings.setEveningTime("20:00");
        settings.setReminderFrequency(1);
        settings.setActiveDays("1,2,3,4,5,6,7");
        settings.setDailyReminderEnabled(true);

        settings = settingsRepository.save(settings);
        return buildSettingsResponse(settings);
    }

    // Méthodes privées

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    private UserSettingsResponse buildSettingsResponse(UserSettings settings) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        return UserSettingsResponse.builder()
            .userId(settings.getUser().getId().intValue())
            .profileVisible(settings.getProfileVisible())
            .shareDataWithAI(settings.getShareDataWithAI())
            .showInLeaderboard(settings.getShowInLeaderboard())
            .pushNotificationsEnabled(settings.getPushNotificationsEnabled())
            .studyRemindersEnabled(settings.getStudyRemindersEnabled())
            .newContentNotifications(settings.getNewContentNotifications())
            .theme(settings.getTheme())
            .language(settings.getLanguage())
            .offlineMode(settings.getOfflineMode())
            .morningTime(settings.getMorningTime())
            .afternoonTime(settings.getAfternoonTime())
            .eveningTime(settings.getEveningTime())
            .reminderFrequency(settings.getReminderFrequency())
            .activeDays(settings.getActiveDays())
            .dailyReminderEnabled(settings.getDailyReminderEnabled())
            .updatedAt(settings.getUpdatedAt().format(formatter))
            .build();
    }

    private boolean isValidTheme(String theme) {
        return theme != null && 
               (theme.equals("light") || theme.equals("dark") || theme.equals("system"));
    }

    private boolean isValidLanguage(String language) {
        return language != null && 
               (language.equals("fr") || language.equals("en") || language.equals("ar"));
    }

    /**
     * ✅ Valider le format de l'heure (HH:mm)
     */
    private boolean isValidTime(String time) {
        if (time == null) return false;
        return time.matches("^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$");
    }
}