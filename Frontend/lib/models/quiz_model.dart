class QuizModel {
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

  // Informations utilisateur
  final bool? isCompleted;
  final int? userBestScore;
  final int? attemptsCount;

  QuizModel({
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
    this.isCompleted,
    this.userBestScore,
    this.attemptsCount,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
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
      isCompleted: json['isCompleted'] as bool?,
      userBestScore: json['userBestScore'] as int?,
      attemptsCount: json['attemptsCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'durationMinutes': durationMinutes,
      'xpReward': xpReward,
      'hasAI': hasAI,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'userBestScore': userBestScore,
      'attemptsCount': attemptsCount,
    };
  }
}