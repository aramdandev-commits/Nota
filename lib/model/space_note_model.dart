class SpaceNoteModel {
  final String id;
  String title;
  String content;
  final String authorName;
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isFavorite;

  SpaceNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory SpaceNoteModel.fromJson(Map<String, dynamic> json) {
    return SpaceNoteModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 'true' || json['is_favorite'] == 1,
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
    };
  }
}
