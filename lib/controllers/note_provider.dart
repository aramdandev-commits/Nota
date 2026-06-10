import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/note_model.dart';
import '../services/pusher_service.dart';

class NoteProvider extends ChangeNotifier {
  final String baseUrl =
      'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1';
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  // AI Summary State
  bool _isSummarizing = false;
  String? _summarizedText;
  bool _isEditingSummary = false;

  bool get isSummarizing => _isSummarizing;
  String? get summarizedText => _summarizedText;
  bool get isEditingSummary => _isEditingSummary;

  set isEditingSummary(bool value) {
    _isEditingSummary = value;
    notifyListeners();
  }

  set summarizedText(String? value) {
    _summarizedText = value;
    notifyListeners();
  }

  void resetSummaryState() {
    _isSummarizing = false;
    _summarizedText = null;
    _isEditingSummary = false;
    notifyListeners();
  }

  // ── PDF extraction state ──────────────────────────────────────────────────

  bool _isPdfProcessing = false;
  String? _pdfError;
  NoteModel? _pdfNote; // set when pdf.extracted fires

  bool get isPdfProcessing => _isPdfProcessing;
  String? get pdfError => _pdfError;
  NoteModel? get pdfNote => _pdfNote;

  void startPdfProcessing() {
    debugPrint('📄 NoteProvider: startPdfProcessing called');
    _isPdfProcessing = true;
    _pdfError = null;
    _pdfNote = null;
    notifyListeners();
  }

  void resetPdfState() {
    debugPrint('📄 NoteProvider: resetPdfState called');
    _isPdfProcessing = false;
    _pdfError = null;
    _pdfNote = null;
    notifyListeners();
  }

  void onPdfExtracted(Map<String, dynamic> eventData) {
    debugPrint('📄 NoteProvider: onPdfExtracted called — data: $eventData');
    try {
      final note = NoteModel.fromMap(
        eventData.containsKey('data')
            ? eventData['data'] as Map<String, dynamic>
            : eventData,
      );
      debugPrint(
          '📄 NoteProvider: parsed note id=${note.id} title="${note.title}"');
      _notes.removeWhere((n) => n.id == note.id);
      _notes.insert(0, note);
      _pdfNote = note;
    } catch (e) {
      debugPrint('📄 NoteProvider: ❌ onPdfExtracted parse error: $e');
      _pdfError = 'Failed to parse extracted note.';
    }
    _isPdfProcessing = false;
    notifyListeners();
  }

  void onPdfExtractionFailed(Map<String, dynamic> eventData) {
    debugPrint(
        '📄 NoteProvider: onPdfExtractionFailed called — data: $eventData');
    _pdfError = eventData['message'] as String? ?? 'PDF extraction failed.';
    _isPdfProcessing = false;
    notifyListeners();
  }

  NoteProvider() {
    loadNotes();
    // Register callbacks to PusherService
    PusherService().onNoteSummarized = onSummaryEventReceived;
    PusherService().onNoteSummarizationFailed = onSummaryEventFailed;
    PusherService().onPdfExtracted = onPdfExtracted;
    PusherService().onPdfExtractionFailed = onPdfExtractionFailed;
  }

  List<NoteModel> getRecentNotes({int count = 5}) {
    return _notes.take(count).toList();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> loadNotes() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notes'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
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
      _notes.insert(0, note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      final url = isNew
          ? Uri.parse('$baseUrl/notes')
          : Uri.parse('$baseUrl/notes/${note.id}');
      debugPrint('🚀 Yjs Base64 Payload: ${note.content}');

      final token = await _getToken();
      final response = await (isNew ? http.post : http.put)(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: note.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        final NoteModel returnedNote = NoteModel.fromMap(data);

        final updateIndex = _notes.indexWhere(
            (n) => n.id == returnedNote.id || (isNew && n.id == note.id));
        if (updateIndex >= 0) {
          _notes[updateIndex] = returnedNote;
        } else {
          _notes.insert(0, returnedNote);
        }

        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        notifyListeners();
        return returnedNote.id;
      } else {
        throw Exception('Failed to save note via API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavorite(String noteId) async {
    final noteIndex = _notes.indexWhere((n) => n.id == noteId);
    if (noteIndex == -1) return;

    final currentNote = _notes[noteIndex];
    final newStatus = !currentNote.isFavorite;

    // Optimistic UI update
    _notes[noteIndex] = currentNote.copyWith(isFavorite: newStatus);
    notifyListeners();

    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/notes/$noteId/favorites');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'is_favorite': newStatus}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      // Revert if API fails
      _notes[noteIndex] = currentNote.copyWith(isFavorite: !newStatus);
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> moveNoteToTrash(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(isDeleted: true);
      notifyListeners();
    }
    // TODO: Connect to actual backend endpoint for soft delete when ready.
    // For now, it just updates local state.
  }

  Future<void> restoreNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(isDeleted: false, content: []);
      notifyListeners();
    }

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/notes/$id/restore'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('Failed to restore note via API: ${response.statusCode}');
        // Do NOT revert on server errors (like 404 or 500) to prevent UI stuttering
        // if the backend is not fully implemented yet.
      }
    } catch (e) {
      debugPrint('Critical network error restoring note via API: $e');
      if (index >= 0) {
        // Only revert on critical network errors
        _notes[index] = _notes[index].copyWith(isDeleted: true);
        notifyListeners();
      }
    }
  }

  Future<void> permanentlyDeleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('Failed to delete note via API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to delete note via API: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    await permanentlyDeleteNote(id);
  }

  Future<void> generateSummary(String noteId) async {
    _isSummarizing = true;
    _summarizedText = null;
    _isEditingSummary = false;
    notifyListeners();

    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/notes/$noteId/summarize');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        _isSummarizing = false;
        notifyListeners();
        throw Exception('Failed to request summary: ${response.statusCode}');
      }
    } catch (e) {
      _isSummarizing = false;
      notifyListeners();
      debugPrint('Error generating summary: $e');
      rethrow;
    }
  }

  void onSummaryEventReceived(Map<String, dynamic> eventData) {
    String? extractedText;

    try {
      if (eventData.containsKey('content') &&
          eventData['content'] is List &&
          (eventData['content'] as List).isNotEmpty) {
        final firstElement = (eventData['content'] as List).first;
        if (firstElement is Map && firstElement.containsKey('insert')) {
          extractedText = firstElement['insert']?.toString();
        }
      }
    } catch (e) {
      debugPrint('Error parsing summary content: $e');
    }

    // Fallback to title if extraction failed or is empty
    if (extractedText == null || extractedText.isEmpty) {
      extractedText = eventData['title']?.toString() ?? '';
    }

    _summarizedText = extractedText;
    _isSummarizing = false;
    notifyListeners();
  }

  void onSummaryEventFailed(Map<String, dynamic> eventData) {
    _isSummarizing = false;
    notifyListeners();
  }
}
