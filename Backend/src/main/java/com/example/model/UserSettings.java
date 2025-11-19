package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_settings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    // ✅ Confidentialité
    @Column(name = "profile_visible", nullable = false)
    @Builder.Default
    private Boolean profileVisible = true;

    @Column(name = "share_data_with_ai", nullable = false)
    @Builder.Default
    private Boolean shareDataWithAI = true;

    @Column(name = "show_in_leaderboard", nullable = false)
    @Builder.Default
    private Boolean showInLeaderboard = true;

    // ✅ Notifications
    @Column(name = "push_notifications_enabled", nullable = false)
    @Builder.Default
    private Boolean pushNotificationsEnabled = true;

    @Column(name = "study_reminders_enabled", nullable = false)
    @Builder.Default
    private Boolean studyRemindersEnabled = true;

    @Column(name = "new_content_notifications", nullable = false)
    @Builder.Default
    private Boolean newContentNotifications = true;

    // ✅ Préférences
    @Column(name = "theme", nullable = false)
    @Builder.Default
    private String theme = "system"; // "light", "dark", "system"

    @Column(name = "language", nullable = false)
    @Builder.Default
    private String language = "fr"; // "fr", "en", "ar"

    @Column(name = "offline_mode", nullable = false)
    @Builder.Default
    private Boolean offlineMode = false;

    // ✅ Horaires de notifications
    @Column(name = "morning_time")
    @Builder.Default
    private String morningTime = "08:00";

    @Column(name = "afternoon_time")
    @Builder.Default
    private String afternoonTime = "14:00";

    @Column(name = "evening_time")
    @Builder.Default
    private String eveningTime = "20:00";

    // ✅ Fréquence des rappels
    @Column(name = "reminder_frequency", nullable = false)
    @Builder.Default
    private Integer reminderFrequency = 1; // 1, 2, 3 fois par jour

    // ✅ Jours actifs (lundi, mardi, etc.)
    @Column(name = "active_days", nullable = false)
    @Builder.Default
    private String activeDays = "1,2,3,4,5,6,7"; // 1=Lun, 7=Dim

    @Column(name = "daily_reminder_enabled", nullable = false)
    @Builder.Default
    private Boolean dailyReminderEnabled = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}