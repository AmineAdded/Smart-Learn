package com.example.dto.Settings;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSettingsResponse {
    
    @JsonProperty("user_id")
    private Integer userId;

    // Confidentialité
    @JsonProperty("profile_visible")
    private Boolean profileVisible;

    @JsonProperty("share_data_with_ai")
    private Boolean shareDataWithAI;

    @JsonProperty("show_in_leaderboard")
    private Boolean showInLeaderboard;

    // Notifications
    @JsonProperty("push_notifications_enabled")
    private Boolean pushNotificationsEnabled;

    @JsonProperty("study_reminders_enabled")
    private Boolean studyRemindersEnabled;

    @JsonProperty("new_content_notifications")
    private Boolean newContentNotifications;

    // Préférences
    @JsonProperty("theme")
    private String theme;

    @JsonProperty("language")
    private String language;

    @JsonProperty("offline_mode")
    private Boolean offlineMode;

    // ✅ Horaires de notifications
    @JsonProperty("morning_time")
    private String morningTime;

    @JsonProperty("afternoon_time")
    private String afternoonTime;

    @JsonProperty("evening_time")
    private String eveningTime;

    // ✅ Fréquence des rappels
    @JsonProperty("reminder_frequency")
    private Integer reminderFrequency;

    // ✅ Jours actifs
    @JsonProperty("active_days")
    private String activeDays;

    // ✅ Rappels quotidiens
    @JsonProperty("daily_reminder_enabled")
    private Boolean dailyReminderEnabled;

    // Métadonnées
    @JsonProperty("updated_at")
    private String updatedAt;
}