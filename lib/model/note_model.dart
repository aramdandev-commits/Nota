import 'dart:convert';

class NoteModel {
  final String id;
  final String? spaceId;

  String title;
  String? preview;
  List<dynamic> content;

  final DateTime createdAt;
  DateTime updatedAt;

  NoteModel({
    required this.id,
    this.spaceId,
    required this.title,
    this.preview,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Object -> Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'space_id': spaceId,
      'title': title,
      'preview': preview,
      'content': content, // Already a list, API expects array
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert Map -> Object
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    // Handle data wrapper
    final data = map.containsKey('data') ? map['data'] : map;

    final parsedUpdatedAt = data['updated_at'] != null
        ? DateTime.parse(data['updated_at'].toString())
        : DateTime.now();

    List<dynamic> parsedContent = [];
    final rawContent = data['content'];
    if (rawContent is List) {
      parsedContent = rawContent;
    }

    // Fallback logic for preview if it's null
    String? parsedPreview = data['preview']?.toString();
    if (parsedPreview == null && rawContent is List) {
      final buffer = StringBuffer();
      for (var element in rawContent) {
        if (element is Map && element.containsKey('insert')) {
          buffer.write(element['insert']?.toString() ?? '');
        }
      }
      if (buffer.isNotEmpty) {
        parsedPreview = buffer.toString();
      }
    }

    return NoteModel(
      id: data['id']?.toString() ?? '',
      spaceId: data['space_id']?.toString(),
      title: data['title']?.toString() ?? '',
      preview: parsedPreview,
      content: parsedContent,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : parsedUpdatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  // Convert Object -> JSON
  String toJson() => json.encode(toMap());

  // Convert JSON -> Object
  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source));

  // Copy With
  NoteModel copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? preview,
    List<dynamic>? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NoteModel('
        'id: $id, '
        'spaceId: $spaceId, '
        'title: $title, '
        'preview: $preview, '
        'content: $content, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
