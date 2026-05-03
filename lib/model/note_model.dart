import 'dart:convert';

class NoteModel {
  final String id;
  String title;
  String content;
  DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());
  factory NoteModel.fromJson(String source) => NoteModel.fromMap(json.decode(source));
}