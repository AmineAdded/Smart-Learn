/// Modèle pour la réponse d'ajout d'XP
class AddXpResponse {
  final int xpAdded;
  final int totalXp;
  final int currentLevel;
  final String levelTitle;
  final int xpForNextLevel;
  final int xpProgressInCurrentLevel;
  final double progressPercentage;
  final bool leveledUp;
  final int? newLevel;
  final String message;

  AddXpResponse({
    required this.xpAdded,
    required this.totalXp,
    required this.currentLevel,
    required this.levelTitle,
    required this.xpForNextLevel,
    required this.xpProgressInCurrentLevel,
    required this.progressPercentage,
    required this.leveledUp,
    this.newLevel,
    required this.message,
  });

  factory AddXpResponse.fromJson(Map<String, dynamic> json) {
    return AddXpResponse(
      xpAdded: json['xpAdded'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      levelTitle: json['levelTitle'] ?? 'Novice',
      xpForNextLevel: json['xpForNextLevel'] ?? 1000,
      xpProgressInCurrentLevel: json['xpProgressInCurrentLevel'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      leveledUp: json['leveledUp'] ?? false,
      newLevel: json['newLevel'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xpAdded': xpAdded,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'levelTitle': levelTitle,
      'xpForNextLevel': xpForNextLevel,
      'xpProgressInCurrentLevel': xpProgressInCurrentLevel,
      'progressPercentage': progressPercentage,
      'leveledUp': leveledUp,
      'newLevel': newLevel,
      'message': message,
    };
  }
}