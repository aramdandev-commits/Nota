class SpaceNoteModel {
  final String id;
  String title;
  String content;
  final String authorName;
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isFavorite;
  final List<String> tags;

  SpaceNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  factory SpaceNoteModel.fromJson(Map<String, dynamic> json) {
    return SpaceNoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorName: json['author_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      isFavorite: json['is_favorite'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_favorite': isFavorite,
      'tags': tags,
    };
  }
}
