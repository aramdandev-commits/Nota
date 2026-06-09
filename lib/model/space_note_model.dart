class SpaceNoteModel {
  final String id;
  String title;
  String? preview;
  List<dynamic> content;
  final String authorName;
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isFavorite;

  SpaceNoteModel({
    required this.id,
    required this.title,
    this.preview,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory SpaceNoteModel.fromJson(Map<String, dynamic> json) {
    // Handle data wrapper
    final data = json.containsKey('data') ? json['data'] : json;

    List<dynamic> parsedContent = [];
    final rawContent = data['content'];
    if (rawContent is List) {
      parsedContent = rawContent;
    }

    return SpaceNoteModel(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      preview: data['preview']?.toString(),
      content: parsedContent,
      authorName: data['author_name']?.toString() ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'].toString())
          : null,
      isFavorite: data['is_favorite'] == true || data['is_favorite'] == 'true' || data['is_favorite'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'content': content, // Already a list, API expects array
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }
}
