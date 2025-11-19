class UserSettings {
  final int userId;
  final String theme;
  final String language;
  final bool profileVisible;
  final bool shareDataWithAI;
  final bool showInLeaderboard;
  final bool pushNotificationsEnabled;
  final bool studyRemindersEnabled;
  final bool newContentNotifications;
  final bool offlineMode;

  // New properties for notification times
  final String? morningTime;
  final String? afternoonTime;
  final String? eveningTime;
  final int reminderFrequency;

  UserSettings({
    required this.userId,
    required this.theme,
    required this.language,
    required this.profileVisible,
    required this.shareDataWithAI,
    required this.showInLeaderboard,
    required this.pushNotificationsEnabled,
    required this.studyRemindersEnabled,
    required this.newContentNotifications,
    required this.offlineMode,
    this.morningTime,
    this.afternoonTime,
    this.eveningTime,
    this.reminderFrequency = 1,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] ?? 0,
      theme: json['theme'] ?? 'system',
      language: json['language'] ?? 'fr',
      profileVisible: json['profile_visible'] == 1 || json['profile_visible'] == true,
      shareDataWithAI: json['share_data_with_ai'] == 1 || json['share_data_with_ai'] == true,
      showInLeaderboard: json['show_in_leaderboard'] == 1 || json['show_in_leaderboard'] == true,
      pushNotificationsEnabled: json['push_notifications_enabled'] == 1 || json['push_notifications_enabled'] == true,
      studyRemindersEnabled: json['study_reminders_enabled'] == 1 || json['study_reminders_enabled'] == true,
      newContentNotifications: json['new_content_notifications'] == 1 || json['new_content_notifications'] == true,
      offlineMode: json['offline_mode'] == 1 || json['offline_mode'] == true,
      morningTime: json['morning_time'],
      afternoonTime: json['afternoon_time'],
      eveningTime: json['evening_time'],
      reminderFrequency: json['reminder_frequency'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'theme': theme,
      'language': language,
      'profile_visible': profileVisible,
      'share_data_with_ai': shareDataWithAI,
      'show_in_leaderboard': showInLeaderboard,
      'push_notifications_enabled': pushNotificationsEnabled,
      'study_reminders_enabled': studyRemindersEnabled,
      'new_content_notifications': newContentNotifications,
      'offline_mode': offlineMode,
      'morning_time': morningTime,
      'afternoon_time': afternoonTime,
      'evening_time': eveningTime,
      'reminder_frequency': reminderFrequency,
    };
  }
}