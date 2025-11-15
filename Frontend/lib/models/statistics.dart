class Statistics {
  final int totalXp;
  final int currentLevel;
  final int quizCompleted;
  final int quizSucceeded;
  final int totalStudyTimeMinutes;
  final int videosWatched;
  final double averageSuccessRate;
  final List<SubjectProgress> subjectProgressList;
  final List<RecentActivity> recentActivities;
  final int globalRank;
  final int totalUsers;
  final List<Goal> goals;

  Statistics({
    required this.totalXp,
    required this.currentLevel,
    required this.quizCompleted,
    required this.quizSucceeded,
    required this.totalStudyTimeMinutes,
    required this.videosWatched,
    required this.averageSuccessRate,
    required this.subjectProgressList,
    required this.recentActivities,
    required this.globalRank,
    required this.totalUsers,
    required this.goals,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      quizCompleted: json['quizCompleted'] ?? 0,
      quizSucceeded: json['quizSucceeded'] ?? 0,
      totalStudyTimeMinutes: json['totalStudyTimeMinutes'] ?? 0,
      videosWatched: json['videosWatched'] ?? 0,
      averageSuccessRate: (json['averageSuccessRate'] ?? 0).toDouble(),
      subjectProgressList: (json['subjectProgressList'] as List? ?? [])
          .map((e) => SubjectProgress.fromJson(e))
          .toList(),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
      globalRank: json['globalRank'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      goals: (json['goals'] as List? ?? [])
          .map((e) => Goal.fromJson(e))
          .toList(),
    );
  }
}

class SubjectProgress {
  final String subject;
  final int quizCompleted;
  final double successRate;
  final int xpEarned;
  final String icon;

  SubjectProgress({
    required this.subject,
    required this.quizCompleted,
    required this.successRate,
    required this.xpEarned,
    required this.icon,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      subject: json['subject'] ?? '',
      quizCompleted: json['quizCompleted'] ?? 0,
      successRate: (json['successRate'] ?? 0).toDouble(),
      xpEarned: json['xpEarned'] ?? 0,
      icon: json['icon'] ?? '📚',
    );
  }
}

class RecentActivity {
  final String type;
  final String title;
  final String description;
  final int xpEarned;
  final DateTime date;
  final String icon;

  RecentActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.xpEarned,
    required this.date,
    required this.icon,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? 'QUIZ',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      xpEarned: json['xpEarned'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      icon: json['icon'] ?? '📝',
    );
  }
}

class Goal {
  final String title;
  final String description;
  final int current;
  final int target;
  final double progress;
  final bool completed;

  Goal({
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.progress,
    required this.completed,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      current: json['current'] ?? 0,
      target: json['target'] ?? 100,
      progress: (json['progress'] ?? 0).toDouble(),
      completed: json['completed'] ?? false,
    );
  }
}