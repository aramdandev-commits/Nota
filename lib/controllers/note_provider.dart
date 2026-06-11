import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/note_model.dart';
import '../services/pusher_service.dart';
import 'notification_provider.dart';

class NoteProvider extends ChangeNotifier {
  final NotificationProvider notificationProvider;
  final String baseUrl =
      'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1';
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  // AI Summary State
  bool _isSummarizing = false;
  bool _isSummarizeSuccess = false;

  bool get isSummarizing => _isSummarizing;
  bool get isSummarizeSuccess => _isSummarizeSuccess;

  void resetSummaryState() {
    _isSummarizing = false;
    _isSummarizeSuccess = false;
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

    // Dedup — if we already processed this, ignore
    if (!_isPdfProcessing) {
      debugPrint('📄 NoteProvider: onPdfExtracted ignored — not processing');
      return;
    }

    try {
      // Unwrap data wrapper if present
      final rawMap = eventData.containsKey('data')
          ? eventData['data'] as Map<String, dynamic>
          : eventData;

      // content may arrive as a JSON string from Pusher — decode it
      final decoded = Map<String, dynamic>.from(rawMap);
      if (decoded['content'] is String) {
        try {
          decoded['content'] = jsonDecode(decoded['content'] as String);
        } catch (_) {}
      }

      // Build preview from content if backend sent null
      if (decoded['preview'] == null && decoded['content'] is List) {
        final ops = decoded['content'] as List;
        final buffer = StringBuffer();
        for (final op in ops) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert'] as String);
          }
        }
        final raw = buffer.toString().replaceAll('\n', ' ').trim();
        decoded['preview'] = raw.length > 120 ? raw.substring(0, 120) : raw;
      }

      final note = NoteModel.fromMap(decoded);
      debugPrint(
          '📄 NoteProvider: parsed note id=${note.id} title="${note.title}" preview="${note.preview?.substring(0, note.preview!.length.clamp(0, 60))}..."');

      _notes.removeWhere((n) => n.id == note.id);
      _notes.insert(0, note);
      _pdfNote = note;

      notificationProvider.addNotification(
        'PDF Imported ✅',
        '"${note.title.isNotEmpty ? note.title : 'Untitled'}" has been saved to your notes.',
      );
    } catch (e) {
      debugPrint('📄 NoteProvider: ❌ onPdfExtracted parse error: $e');
      _pdfError = 'Failed to parse extracted note.';
    }
    _isPdfProcessing = false;
    notifyListeners();
    // Refresh from server to get the fully persisted note with all fields
    loadNotes();
  }

  void onPdfExtractionFailed(Map<String, dynamic> eventData) {
    debugPrint(
        '📄 NoteProvider: onPdfExtractionFailed called — data: $eventData');

    // Dedup
    if (!_isPdfProcessing) return;

    final msg = eventData['message'] as String? ?? 'PDF extraction failed.';
    _pdfError = msg;
    _isPdfProcessing = false;

    // Add failure notification
    notificationProvider.addNotification(
      'PDF Import Failed ❌',
      msg,
    );

    notifyListeners();
  }

  NoteProvider(this.notificationProvider) {
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
    _isSummarizeSuccess = false;
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

  Future<void> summarizeText(String text) async {
    _isSummarizing = true;
    _isSummarizeSuccess = false;
    notifyListeners();

    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/summarize');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final noteData =
            data is Map<String, dynamic> && data.containsKey('data')
                ? data['data']
                : data;
        final note = NoteModel.fromMap(noteData);

        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index >= 0) {
          _notes[index] = note;
        } else {
          _notes.insert(0, note);
        }
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        _isSummarizeSuccess = true;

        notificationProvider.addNotification(
          'Text Summarized',
          'Your pasted text has been successfully summarized.',
        );
      } else {
        debugPrint(
            'Failed to request text summary. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to request summary: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating summary from text: $e');
      rethrow;
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  void onSummaryEventReceived(Map<String, dynamic> eventData) {
    debugPrint('Received summary event: $eventData');
    try {
      final rawMap = eventData.containsKey('data')
          ? eventData['data'] as Map<String, dynamic>
          : eventData;

      final decoded = Map<String, dynamic>.from(rawMap);

      // content may arrive as a JSON string from Pusher — decode it
      if (decoded['content'] is String) {
        try {
          decoded['content'] = jsonDecode(decoded['content'] as String);
        } catch (_) {}
      }

      // Build preview from content ops if backend sent null
      if (decoded['preview'] == null && decoded['content'] is List) {
        final ops = decoded['content'] as List;
        final buffer = StringBuffer();
        for (final op in ops) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert'] as String);
          }
        }
        final raw = buffer.toString().replaceAll('\n', ' ').trim();
        decoded['preview'] = raw.length > 120 ? raw.substring(0, 120) : raw;
      }

      final note = NoteModel.fromMap(decoded);

      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        _notes[index] = note;
      } else {
        _notes.insert(0, note);
      }
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      _isSummarizeSuccess = true;

      notificationProvider.addNotification(
        'Note Summarized ✅',
        '"${note.title.isNotEmpty ? note.title : 'Untitled'}" has been successfully summarized.',
      );
    } catch (e) {
      debugPrint('Error parsing summary content: $e');
    }

    _isSummarizing = false;
    notifyListeners();
  }

  void onSummaryEventFailed(Map<String, dynamic> eventData) {
    _isSummarizing = false;
    notifyListeners();
  }
}
