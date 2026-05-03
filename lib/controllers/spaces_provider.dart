import 'package:flutter/material.dart';
import '../model/space_model.dart';
import 'spaces_repository.dart';

class SpacesProvider extends ChangeNotifier {
  final SpacesRepository _repository = SpacesRepository();
  
  List<SpaceModel> _spaces = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<SpaceModel> get spaces => _spaces;
  List<SpaceModel> get filteredSpaces {
    if (_searchQuery.isEmpty) return _spaces;
    return _spaces.where((space) {
      return space.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SpacesProvider() {
    fetchSpaces();
  }

  Future<void> fetchSpaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedSpaces = await _repository.getSpaces();
      // Add some dummy recent activity data to the mock spaces for demonstration
      _spaces = fetchedSpaces.map((space) {
        if (space.id == '1') {
          return SpaceModel(
            id: space.id,
            title: space.title,
            description: space.description,
            role: space.role,
            memberCount: space.memberCount,
            noteCount: space.noteCount,
            iconColor: space.iconColor,
            iconData: space.iconData,
            privacy: space.privacy,
            lastEditedBy: 'Sarah Khan',
            lastEditedAction: 'edited "Project Plan"',
            lastEditedAt: DateTime.now().subtract(const Duration(hours: 2)),
          );
        }
        return space;
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSpace(SpaceModel space) {
    _spaces.add(space);
    notifyListeners();
  }

  void searchSpaces(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void renameSpace(String spaceId, String newTitle) {
    final index = _spaces.indexWhere((s) => s.id == spaceId);
    if (index != -1) {
      final old = _spaces[index];
      _spaces[index] = SpaceModel(
        id: old.id,
        title: newTitle,
        description: old.description,
        role: old.role,
        memberCount: old.memberCount,
        noteCount: old.noteCount,
        iconColor: old.iconColor,
        iconData: old.iconData,
        privacy: old.privacy,
        lastEditedBy: old.lastEditedBy,
        lastEditedAction: old.lastEditedAction,
        lastEditedAt: old.lastEditedAt,
      );
      notifyListeners();
    }
  }

  void deleteSpace(String spaceId) {
    _spaces.removeWhere((s) => s.id == spaceId);
    notifyListeners();
  }
}
