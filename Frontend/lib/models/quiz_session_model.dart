class QuizSessionModel {
  final int sessionId;
  final int quizId;
  final String quizTitle;
  final int totalQuestions;
  final int? durationMinutes;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final Map<int, String> savedAnswers;
  final int timeSpentSeconds;

  QuizSessionModel({
    required this.sessionId,
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    this.durationMinutes,
    required this.startedAt,
    this.expiresAt,
    required this.questions,
    required this.currentQuestionIndex,
    required this.savedAnswers,
    required this.timeSpentSeconds,
  });

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    return QuizSessionModel(
      sessionId: json['sessionId'] as int,
      quizId: json['quizId'] as int,
      quizTitle: json['quizTitle'] as String,
      totalQuestions: json['totalQuestions'] as int,
      durationMinutes: json['durationMinutes'] as int?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList(),
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      savedAnswers: (json['savedAnswers'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(int.parse(key), value.toString())) ??
          {},
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
    );
  }
}

class QuestionModel {
  final int id;
  final String questionText;
  final String type;
  final String? imageUrl;
  final int points;
  final int? orderNumber;
  final List<AnswerOptionModel>? options;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.type,
    this.imageUrl,
    required this.points,
    this.orderNumber,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      questionText: json['questionText'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
      points: json['points'] as int? ?? 1,
      orderNumber: json['orderNumber'] as int?,
      options: json['options'] != null
          ? (json['options'] as List)
          .map((o) => AnswerOptionModel.fromJson(o))
          .toList()
          : null,
    );
  }
}

class AnswerOptionModel {
  final int id;
  final String optionText;
  final String? optionLetter;

  AnswerOptionModel({
    required this.id,
    required this.optionText,
    this.optionLetter,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] as int,
      optionText: json['optionText'] as String,
      optionLetter: json['optionLetter'] as String?,
    );
  }
}

class AnswerFeedbackModel {
  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;
  final int pointsEarned;
  final int currentScore;
  final int questionsAnswered;
  final int totalQuestions;

  AnswerFeedbackModel({
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
    required this.pointsEarned,
    required this.currentScore,
    required this.questionsAnswered,
    required this.totalQuestions,
  });

  factory AnswerFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AnswerFeedbackModel(
      isCorrect: json['isCorrect'] as bool,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      pointsEarned: json['pointsEarned'] as int,
      currentScore: json['currentScore'] as int,
      questionsAnswered: json['questionsAnswered'] as int,
      totalQuestions: json['totalQuestions'] as int,
    );
  }
}