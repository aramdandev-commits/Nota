import 'package:flutter/material.dart';
import '../model/space_model.dart';
import 'spaces_repository.dart';

class SpacesProvider extends ChangeNotifier {
  final SpacesRepository _repository = SpacesRepository();
  
  List<SpaceModel> _spaces = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
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
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  SpacesProvider() {
    fetchSpaces();
  }

  Future<void> fetchSpaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _spaces = await _repository.fetchSpaces();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSpace(String name, String description) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSpace = await _repository.createSpace(name, description);
      _spaces.insert(0, newSpace);
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> updateSpace(String id, String name, String description) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSpace = await _repository.updateSpace(id, name, description);
      final index = _spaces.indexWhere((s) => s.id == id);
      if (index != -1) {
        _spaces[index] = updatedSpace;
      }
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteSpace(String id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteSpace(id);
      _spaces.removeWhere((s) => s.id == id);
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void searchSpaces(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
