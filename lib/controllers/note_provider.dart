import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/note_model.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  NoteProvider() {
    loadNotes();
  }

  List<NoteModel> getRecentNotes({int count = 5}) {
    return _notes.take(count).toList();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('saved_notes');

    if (notesString != null) {
      final List<dynamic> decoded = json.decode(notesString);
      _notes = decoded.map((item) => NoteModel.fromMap(item)).toList();

      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    }
  }

  Future<void> _saveNotesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedNotes =
        _notes.map((note) => note.toMap()).toList();
    await prefs.setString('saved_notes', json.encode(mappedNotes));
  }

  void saveNote(NoteModel note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _saveNotesToStorage();
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotesToStorage();
    notifyListeners();
  }
}
