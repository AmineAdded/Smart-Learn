class UserProgress {
  final int userId;
  final String userName;
  final String userEmail;
  final String niveau;
  final int totalXp;
  final int currentLevel;
  final int quizCompleted;
  final int quizSucceeded;
  final int totalStudyTimeMinutes;
  final int videosWatched;
  final double averageSuccessRate;
  final int xpForNextLevel;
  final int xpProgressInCurrentLevel;
  final double progressPercentage;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime createdAt;
  final String studyTimeFormatted;
  final String levelTitle;

  UserProgress({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.niveau,
    required this.totalXp,
    required this.currentLevel,
    required this.quizCompleted,
    required this.quizSucceeded,
    required this.totalStudyTimeMinutes,
    required this.videosWatched,
    required this.averageSuccessRate,
    required this.xpForNextLevel,
    required this.xpProgressInCurrentLevel,
    required this.progressPercentage,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.createdAt,
    required this.studyTimeFormatted,
    required this.levelTitle,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      niveau: json['niveau'] ?? '',
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      quizCompleted: json['quizCompleted'] ?? 0,
      quizSucceeded: json['quizSucceeded'] ?? 0,
      totalStudyTimeMinutes: json['totalStudyTimeMinutes'] ?? 0,
      videosWatched: json['videosWatched'] ?? 0,
      averageSuccessRate: (json['averageSuccessRate'] ?? 0).toDouble(),
      xpForNextLevel: json['xpForNextLevel'] ?? 1000,
      xpProgressInCurrentLevel: json['xpProgressInCurrentLevel'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      studyTimeFormatted: json['studyTimeFormatted'] ?? '0min',
      levelTitle: json['levelTitle'] ?? 'Novice',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'niveau': niveau,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'quizCompleted': quizCompleted,
      'quizSucceeded': quizSucceeded,
      'totalStudyTimeMinutes': totalStudyTimeMinutes,
      'videosWatched': videosWatched,
      'averageSuccessRate': averageSuccessRate,
      'xpForNextLevel': xpForNextLevel,
      'xpProgressInCurrentLevel': xpProgressInCurrentLevel,
      'progressPercentage': progressPercentage,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'studyTimeFormatted': studyTimeFormatted,
      'levelTitle': levelTitle,
    };
  }
}