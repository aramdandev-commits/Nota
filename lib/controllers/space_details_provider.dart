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
  bool _isActionRunning = false;
  String? _inviteUrl;
  SpaceRole _currentUserRole = SpaceRole.viewer;

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
  bool get isActionRunning => _isActionRunning;
  String? get errorMessage => _errorMessage;
  String get activeTab => _activeTab;
  bool get allowMembersToEdit => _allowMembersToEdit;
  bool get isPublic => _isPublic;
  String? get inviteUrl => _inviteUrl;
  SpaceRole get currentUserRole => _currentUserRole;

  void initCurrentUserRole(SpaceRole initialRole) {
    _currentUserRole = initialRole;
  }

  void _calculateCurrentUserRole(String? currentUserId) {
    if (currentUserId == null) return;
    try {
      final me = _members.firstWhere((m) => m.id == currentUserId || m.isCurrentUser);
      _currentUserRole = me.role;
    } catch (e) {
      if (_currentUserRole != SpaceRole.owner) {
        _currentUserRole = SpaceRole.viewer;
      }
    }
  }

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

  Future<void> deleteNote(String spaceId, String noteId) async {
    _isActionRunning = true;
    notifyListeners();
    try {
      await _repository.deleteNote(spaceId, noteId);
      _notes.removeWhere((n) => n.id == noteId);
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isActionRunning = false;
      notifyListeners();
    }
  }

  Future<void> createNote(String spaceId, String title, List<dynamic> content, String preview) async {
    _isActionRunning = true;
    notifyListeners();
    try {
      final newNote = await _repository.createNote(spaceId, title, content, preview);
      _notes.insert(0, newNote);
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isActionRunning = false;
      notifyListeners();
    }
  }

  void removeNoteLocally(String noteId) {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
  }

  Future<void> updateNote(
      String spaceId, String noteId, String title, List<dynamic> content, String preview) async {
    _isActionRunning = true;
    notifyListeners();
    try {
      final updatedNote =
          await _repository.updateNote(spaceId, noteId, title, content, preview);
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = updatedNote;
      }
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isActionRunning = false;
      notifyListeners();
    }
  }

  // ── Members actions ───────────────────────────────────────────────────────────
  Future<void> fetchMembers(String spaceId, {String? currentUserId}) async {
    _isMembersLoading = true;
    notifyListeners();
    try {
      _members = await _repository.getMembersForSpace(spaceId);
      if (currentUserId != null) {
        _calculateCurrentUserRole(currentUserId);
      }
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  void searchMembers(String query) {
    _memberSearchQuery = query;
    notifyListeners();
  }

  Future<void> changeMemberRole(String spaceId, String memberId, SpaceRole newRole) async {
    _isActionRunning = true;
    notifyListeners();
    try {
      await _repository.changeMemberRole(spaceId, memberId, newRole);
      final i = _members.indexWhere((m) => m.id == memberId);
      if (i != -1) {
        _members[i].role = newRole;
      }
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isActionRunning = false;
      notifyListeners();
    }
  }

  void removeMember(String memberId) {
    _members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  Future<void> inviteMember(String spaceId) async {
    _isActionRunning = true;
    notifyListeners();
    try {
      final result = await _repository.inviteMember(spaceId);
      _inviteUrl = result['invite_url'];
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isActionRunning = false;
      notifyListeners();
    }
  }

  void clearInviteUrl() {
    _inviteUrl = null;
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
    _inviteUrl = null;
  }
}
