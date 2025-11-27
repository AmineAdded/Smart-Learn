class Video {
  final int id;
  final String youtubeId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final int duration;
  final String formattedDuration;
  final String category;
  final String difficulty;
  final int viewCount;
  final int favoriteCount;
  final List<String> tags;
  final bool isFavorite;
  final bool isWatched;
  final double progressPercentage;
  final int lastTimestamp;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.duration,
    required this.formattedDuration,
    required this.category,
    required this.difficulty,
    required this.viewCount,
    required this.favoriteCount,
    required this.tags,
    required this.isFavorite,
    required this.isWatched,
    required this.progressPercentage,
    required this.lastTimestamp,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      youtubeId: json['youtubeId'],
      title: json['title'],
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      channelTitle: json['channelTitle'],
      duration: json['duration'],
      formattedDuration: json['formattedDuration'],
      category: json['category'],
      difficulty: json['difficulty'],
      viewCount: json['viewCount'],
      favoriteCount: json['favoriteCount'],
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'],
      isWatched: json['isWatched'],
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      lastTimestamp: json['lastTimestamp'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Add this copyWith method
  Video copyWith({
    int? id,
    String? youtubeId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? channelTitle,
    int? duration,
    String? formattedDuration,
    String? category,
    String? difficulty,
    int? viewCount,
    int? favoriteCount,
    List<String>? tags,
    bool? isFavorite,
    bool? isWatched,
    double? progressPercentage,
    int? lastTimestamp,
    DateTime? createdAt,
  }) {
    return Video(
      id: id ?? this.id,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelTitle: channelTitle ?? this.channelTitle,
      duration: duration ?? this.duration,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatched: isWatched ?? this.isWatched,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}