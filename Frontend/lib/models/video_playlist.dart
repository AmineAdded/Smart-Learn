class VideoPlaylist {
  final int id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String? thumbnailUrl;
  final int videoCount;
  final bool isPublic;
  final DateTime createdAt;

  VideoPlaylist({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    this.thumbnailUrl,
    required this.videoCount,
    required this.isPublic,
    required this.createdAt,
  });

  factory VideoPlaylist.fromJson(Map<String, dynamic> json) {
    return VideoPlaylist(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      difficulty: json['difficulty'],
      thumbnailUrl: json['thumbnailUrl'],
      videoCount: json['videoCount'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}