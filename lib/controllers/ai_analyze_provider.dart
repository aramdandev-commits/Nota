import 'package:flutter/material.dart';
import '../model/ai_analysis_model.dart';
import '../model/note_model.dart';
import 'ai_analyze_repository.dart';

enum AiAnalyzeMode { pasteText, fromNote }

enum AiAnalyzeStatus { idle, loading, success, error }

class AiAnalyzeProvider extends ChangeNotifier {
  AiAnalyzeProvider({AiAnalyzeRepository? repository})
      : _repository = repository ?? MockAiAnalyzeRepository();

  final AiAnalyzeRepository _repository;

  // ── UI state ──────────────────────────────────────────────────────────────
  AiAnalyzeMode _mode = AiAnalyzeMode.pasteText;
  AiAnalyzeStatus _status = AiAnalyzeStatus.idle;
  AiAnalysisResult? _result;
  String? _errorMessage;
  NoteModel? _selectedNote;
  bool _copied = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  AiAnalyzeMode get mode => _mode;
  AiAnalyzeStatus get status => _status;
  AiAnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;
  NoteModel? get selectedNote => _selectedNote;
  bool get copied => _copied;
  bool get hasResult => _result != null;

  // ── Actions ───────────────────────────────────────────────────────────────

  void setMode(AiAnalyzeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _result = null;
    _status = AiAnalyzeStatus.idle;
    _selectedNote = null;
    notifyListeners();
  }

  void selectNote(NoteModel note) {
    _selectedNote = note;
    notifyListeners();
  }

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) return;
    _startLoading();
    try {
      _result = await _repository.analyzeText(text.trim());
      _status = AiAnalyzeStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AiAnalyzeStatus.error;
    }
    notifyListeners();
  }

  Future<void> analyzeNote() async {
    if (_selectedNote == null) return;
    _startLoading();
    try {
      _result = await _repository.analyzeNote(_selectedNote!.id);
      _status = AiAnalyzeStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AiAnalyzeStatus.error;
    }
    notifyListeners();
  }

  /// Marks the result as copied and resets the flag after 2 seconds.
  void markCopied() {
    _copied = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _copied = false;
      notifyListeners();
    });
  }

  void reset() {
    _result = null;
    _status = AiAnalyzeStatus.idle;
    _errorMessage = null;
    _copied = false;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _startLoading() {
    _status = AiAnalyzeStatus.loading;
    _result = null;
    _errorMessage = null;
    _copied = false;
    notifyListeners();
  }
}
