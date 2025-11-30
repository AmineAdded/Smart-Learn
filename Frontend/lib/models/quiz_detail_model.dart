class QuizDetailModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int questionCount;
  final int durationMinutes;
  final int xpReward;
  final bool hasAI;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;

  final QuestionDistribution questionDistribution;
  final QuizStatistics statistics;
  final UserQuizProgress userProgress;
  final List<LeaderboardEntry> topScores;

  final List<String>? prerequisites;
  final String? recommendedLevel;
  final List<String>? topics;

  QuizDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    required this.durationMinutes,
    required this.xpReward,
    required this.hasAI,
    required this.isActive,
    required this.createdAt,
    this.createdBy,
    required this.questionDistribution,
    required this.statistics,
    required this.userProgress,
    required this.topScores,
    this.prerequisites,
    this.recommendedLevel,
    this.topics,
  });

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    return QuizDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      questionCount: json['questionCount'] as int,
      durationMinutes: json['durationMinutes'] as int,
      xpReward: json['xpReward'] as int? ?? 100,
      hasAI: json['hasAI'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
      questionDistribution: QuestionDistribution.fromJson(
        json['questionDistribution'] as Map<String, dynamic>,
      ),
      statistics: QuizStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
      userProgress: UserQuizProgress.fromJson(
        json['userProgress'] as Map<String, dynamic>,
      ),
      topScores: (json['topScores'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      prerequisites: (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      recommendedLevel: json['recommendedLevel'] as String?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class QuestionDistribution {
  final int multipleChoice;
  final int trueFalse;
  final int shortAnswer;
  final int matching;
  final int withImages;

  QuestionDistribution({
    required this.multipleChoice,
    required this.trueFalse,
    required this.shortAnswer,
    required this.matching,
    required this.withImages,
  });

  factory QuestionDistribution.fromJson(Map<String, dynamic> json) {
    return QuestionDistribution(
      multipleChoice: json['multipleChoice'] as int? ?? 0,
      trueFalse: json['trueFalse'] as int? ?? 0,
      shortAnswer: json['shortAnswer'] as int? ?? 0,
      matching: json['matching'] as int? ?? 0,
      withImages: json['withImages'] as int? ?? 0,
    );
  }
}

class QuizStatistics {
  final int totalAttempts;
  final double averageScore;
  final int completionRate;
  final double averageTimeMinutes;

  QuizStatistics({
    required this.totalAttempts,
    required this.averageScore,
    required this.completionRate,
    required this.averageTimeMinutes,
  });

  factory QuizStatistics.fromJson(Map<String, dynamic> json) {
    return QuizStatistics(
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      completionRate: json['completionRate'] as int? ?? 0,
      averageTimeMinutes:
      (json['averageTimeMinutes'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UserQuizProgress {
  final bool hasAttempted;
  final int attemptsCount;
  final int? bestScore;
  final int? lastScore;
  final DateTime? lastAttemptDate;
  final bool canRetake;
  final String progressStatus; // "not_started", "in_progress", "completed"

  UserQuizProgress({
    required this.hasAttempted,
    required this.attemptsCount,
    this.bestScore,
    this.lastScore,
    this.lastAttemptDate,
    required this.canRetake,
    required this.progressStatus,
  });

  factory UserQuizProgress.fromJson(Map<String, dynamic> json) {
    return UserQuizProgress(
      hasAttempted: json['hasAttempted'] as bool? ?? false,
      attemptsCount: json['attemptsCount'] as int? ?? 0,
      bestScore: json['bestScore'] as int?,
      lastScore: json['lastScore'] as int?,
      lastAttemptDate: json['lastAttemptDate'] != null
          ? DateTime.parse(json['lastAttemptDate'] as String)
          : null,
      canRetake: json['canRetake'] as bool? ?? true,
      progressStatus: json['progressStatus'] as String? ?? 'not_started',
    );
  }
}

class LeaderboardEntry {
  final String username;
  final int score;
  final DateTime completedAt;
  final int rank;

  LeaderboardEntry({
    required this.username,
    required this.score,
    required this.completedAt,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] as String,
      score: json['score'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      rank: json['rank'] as int,
    );
  }
}