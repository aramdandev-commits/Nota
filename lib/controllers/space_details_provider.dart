import 'package:flutter/material.dart';
import '../model/space_model.dart';
import '../model/space_note_model.dart';
import '../model/space_member_model.dart';
import '../model/space_settings_model.dart';
import 'space_details_repository.dart';

class SpaceDetailsProvider extends ChangeNotifier {
  final SpaceDetailsRepository _repository = SpaceDetailsRepository();

  // ── Notes state ─────────────────────────────────────────────────────────────
  List<SpaceNoteModel> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _noteSearchQuery = '';

  // ── Members state ────────────────────────────────────────────────────────────
  List<SpaceMemberModel> _members = [];
  bool _isMembersLoading = false;
  String _memberSearchQuery = '';

  // ── Settings state ───────────────────────────────────────────────────────────
  bool _allowMembersToEdit = true;
  bool _isPublic = false;
  bool _isSaving = false;

  // ── Tab state ────────────────────────────────────────────────────────────────
  String _activeTab = 'notes';

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<SpaceNoteModel> get notes => _notes;
  List<SpaceNoteModel> get filteredNotes {
    if (_noteSearchQuery.isEmpty) return _notes;
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(_noteSearchQuery.toLowerCase()))
        .toList();
  }

  List<SpaceMemberModel> get members => _members;
  List<SpaceMemberModel> get filteredMembers {
    if (_memberSearchQuery.isEmpty) return _members;
    return _members
        .where((m) =>
            m.name.toLowerCase().contains(_memberSearchQuery.toLowerCase()) ||
            m.email.toLowerCase().contains(_memberSearchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get activeTab => _activeTab;
  bool get allowMembersToEdit => _allowMembersToEdit;
  bool get isPublic => _isPublic;

  // ── Notes actions ─────────────────────────────────────────────────────────────
  Future<void> fetchNotes(String spaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _notes = await _repository.getNotesForSpace(spaceId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchNotes(String query) {
    _noteSearchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(String noteId) {
    final i = _notes.indexWhere((n) => n.id == noteId);
    if (i != -1) {
      _notes[i].isFavorite = !_notes[i].isFavorite;
      notifyListeners();
    }
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
  }

  void addNote(SpaceNoteModel note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void editNote(String id, String newName, String newDescription, List<String> tags) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].title = newName;
      _notes[index].content = newDescription;
      _notes[index].updatedAt = DateTime.now();
      _notes[index].tags.clear();
      _notes[index].tags.addAll(tags);
      notifyListeners();
    }
  }

  // ── Members actions ───────────────────────────────────────────────────────────
  Future<void> fetchMembers(String spaceId) async {
    _isMembersLoading = true;
    notifyListeners();
    try {
      _members = await _repository.getMembersForSpace(spaceId);
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  void searchMembers(String query) {
    _memberSearchQuery = query;
    notifyListeners();
  }

  void changeMemberRole(String memberId, SpaceRole newRole) {
    final i = _members.indexWhere((m) => m.id == memberId);
    if (i != -1) {
      _members[i].role = newRole;
      notifyListeners();
    }
  }

  void removeMember(String memberId) {
    _members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  void inviteMember(String email) {
    // Simulate adding a pending member
    final pending = SpaceMemberModel(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      role: SpaceRole.viewer,
      joinedAt: DateTime.now(),
      avatarColor: const Color(0xFF6B58FF),
    );
    _members.add(pending);
    notifyListeners();
  }

  // ── Settings actions ──────────────────────────────────────────────────────────
  void setAllowMembersToEdit(bool value) {
    _allowMembersToEdit = value;
    notifyListeners();
  }

  void setIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  /// Simulates PATCH /api/spaces/{id} — replace body with http.patch() later.
  Future<void> updateSpaceSettings(SpaceSettingsModel data) async {
    _isSaving = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API
    _isSaving = false;
    notifyListeners();
    // On success, Laravel returns the updated space — update local state here.
  }

  // ── Tab ───────────────────────────────────────────────────────────────────────
  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void reset() {
    _notes = [];
    _members = [];
    _noteSearchQuery = '';
    _memberSearchQuery = '';
    _activeTab = 'notes';
    _isLoading = true;
  }
}
