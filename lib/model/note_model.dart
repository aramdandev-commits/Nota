import 'dart:convert';

class NoteModel {
  final String id;

  String title;
  String content;

  final DateTime createdAt;
  DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Object -> Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert Map -> Object
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    final parsedUpdatedAt = map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now();
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : parsedUpdatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  // Convert Object -> JSON
  String toJson() => json.encode(toMap());

  // Convert JSON -> Object
  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source));

  // Copy With (مفيد جدًا للتعديل)
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NoteModel('
        'id: $id, '
        'title: $title, '
        'content: $content, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
