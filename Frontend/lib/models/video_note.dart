class VideoNote {
  final int id;
  final String content;
  final int? timestamp;
  final String? formattedTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoNote({
    required this.id,
    required this.content,
    this.timestamp,
    this.formattedTimestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoNote.fromJson(Map<String, dynamic> json) {
    return VideoNote(
      id: json['id'],
      content: json['content'],
      timestamp: json['timestamp'],
      formattedTimestamp: json['formattedTimestamp'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
