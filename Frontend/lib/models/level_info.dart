class LevelInfo {
  final int currentLevel;
  final String levelTitle;
  final String levelIcon;
  final int currentXp;
  final int xpForNextLevel;
  final int xpProgressInCurrentLevel;
  final double progressPercentage;
  final int xpNeeded;
  final String currentLevelBenefits;
  final String nextLevelBenefits;
  final String badgeUrl;
  final String badgeColor;

  LevelInfo({
    required this.currentLevel,
    required this.levelTitle,
    required this.levelIcon,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.xpProgressInCurrentLevel,
    required this.progressPercentage,
    required this.xpNeeded,
    required this.currentLevelBenefits,
    required this.nextLevelBenefits,
    required this.badgeUrl,
    required this.badgeColor,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      currentLevel: json['currentLevel'] ?? 1,
      levelTitle: json['levelTitle'] ?? 'Novice',
      levelIcon: json['levelIcon'] ?? '📖',
      currentXp: json['currentXp'] ?? 0,
      xpForNextLevel: json['xpForNextLevel'] ?? 1000,
      xpProgressInCurrentLevel: json['xpProgressInCurrentLevel'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      xpNeeded: json['xpNeeded'] ?? 1000,
      currentLevelBenefits: json['currentLevelBenefits'] ?? '',
      nextLevelBenefits: json['nextLevelBenefits'] ?? '',
      badgeUrl: json['badgeUrl'] ?? '',
      badgeColor: json['badgeColor'] ?? '#5B9FD8',
    );
  }
}