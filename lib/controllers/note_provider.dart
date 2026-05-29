import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/note_model.dart';

class NoteProvider extends ChangeNotifier {
  final String baseUrl =
      'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1';
  String? currentAuthToken =
      '5|luSv7vcNqYuYeawhAmm7MRAqOKl24wmDPj6JLtHabdbd7e03';
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  NoteProvider() {
    loadNotes();
  }

  List<NoteModel> getRecentNotes({int count = 5}) {
    return _notes.take(count).toList();
  }

  Future<void> loadNotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (currentAuthToken != null)
            'Authorization': 'Bearer $currentAuthToken',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> list =
            responseBody is Map && responseBody.containsKey('data')
                ? responseBody['data']
                : responseBody;

        _notes = list.map((item) => NoteModel.fromMap(item)).toList();
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load notes from API: $e');
    }
  }

  Future<String> saveNote(NoteModel note, {bool isNew = false}) async {
    // Add optimistic UI temporarily
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      final url = isNew
          ? Uri.parse('$baseUrl/notes')
          : Uri.parse('$baseUrl/notes/${note.id}');
      debugPrint('🚀 Yjs Base64 Payload: ${note.content}');
      final response = await (isNew ? http.post : http.put)(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (currentAuthToken != null)
            'Authorization': 'Bearer $currentAuthToken',
        },
        body: note.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        final String backendId = data['id'].toString();

        // Update the note ID with the backend ID
        final finalNote = note.copyWith(id: backendId);

        final updateIndex = _notes.indexWhere((n) => n.id == note.id);
        if (updateIndex >= 0) {
          _notes[updateIndex] = finalNote;
        } else {
          // Fallback if somehow it wasn't added optimally
          _notes.add(finalNote);
        }

        notifyListeners();
        return backendId;
      } else {
        throw Exception('Failed to save note via API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (currentAuthToken != null)
            'Authorization': 'Bearer $currentAuthToken',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Failed to delete note via API: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete note via API: $e');
    }
  }
}
