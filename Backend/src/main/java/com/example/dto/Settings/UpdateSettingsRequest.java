package com.example.dto.Settings;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
class UpdateSettingsRequest {
    
    // Confidentialité
    private Boolean profileVisible;
    private Boolean shareDataWithAI;
    private Boolean showInLeaderboard;
    
    // Notifications
    private Boolean pushNotificationsEnabled;
    private Boolean studyRemindersEnabled;
    private Boolean newContentNotifications;
    
    // Préférences
    private String theme;
    private String language;
    private Boolean offlineMode;
}