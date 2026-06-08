class SpaceNoteModel {
  final String id;
  String title;
  String? preview;
  String content;
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

    // Safely parse content which might be a List<dynamic> containing the Yjs base64
    String parsedContent = '';
    final rawContent = data['content'];
    if (rawContent is List && rawContent.isNotEmpty) {
      parsedContent = rawContent.first.toString();
    } else if (rawContent is String) {
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
      'content': [content], // API expects single-element list
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }
}
