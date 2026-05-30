import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/space_note_model.dart';
import '../model/space_member_model.dart';
import '../model/space_model.dart';

class SpaceDetailsRepository {
  static const String _baseUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1/spaces';
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': '69420',
    'Authorization': 'Bearer 5|luSv7vcNqYuYeawhAmm7MRAqOKl24wmDPj6JLtHabdbd7e03',
  };

  Future<List<SpaceNoteModel>> getNotesForSpace(String spaceId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$spaceId/notes'), headers: _headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
      return data.map((e) => SpaceNoteModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load space notes: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceNoteModel> createNote(String spaceId, String title, String content) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$spaceId/notes'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return SpaceNoteModel.fromJson(data);
    } else {
      throw Exception('Failed to create space note: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceNoteModel> updateNote(String spaceId, String noteId, String title, String content) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$spaceId/notes/$noteId'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return SpaceNoteModel.fromJson(data);
    } else {
      throw Exception('Failed to update space note: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteNote(String spaceId, String noteId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$spaceId/notes/$noteId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete space note: ${response.statusCode} ${response.body}');
    }
  }


  Future<List<SpaceMemberModel>> getMembersForSpace(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final Map<String, List<SpaceMemberModel>> members = {
      '1': [
        SpaceMemberModel(
          id: 'm1',
          name: 'You',
          email: 'you@nota.app',
          role: SpaceRole.admin,
          joinedAt: DateTime(2024, 10, 1),
          isCurrentUser: true,
          avatarColor: const Color(0xFFD838B5),
        ),
        SpaceMemberModel(
          id: 'm2',
          name: 'Sarah Khan',
          email: 'sarah@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 5),
          avatarColor: const Color(0xFF238EFA),
        ),
        SpaceMemberModel(
          id: 'm3',
          name: 'Ahmed Ali',
          email: 'ahmed@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 12),
          avatarColor: const Color(0xFF07C168),
        ),
        SpaceMemberModel(
          id: 'm4',
          name: 'Maria Garcia',
          email: 'maria@team.com',
          role: SpaceRole.viewer,
          joinedAt: DateTime(2024, 10, 18),
          avatarColor: const Color(0xFFFF5621),
        ),
      ],
      '2': [
        SpaceMemberModel(
          id: 'm5',
          name: 'Alex Chen',
          email: 'alex@team.com',
          role: SpaceRole.admin,
          joinedAt: DateTime(2024, 9, 10),
          avatarColor: const Color(0xFF238EFA),
        ),
        SpaceMemberModel(
          id: 'm6',
          name: 'You',
          email: 'you@nota.app',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 9, 20),
          isCurrentUser: true,
          avatarColor: const Color(0xFFD838B5),
        ),
        SpaceMemberModel(
          id: 'm7',
          name: 'Lisa Wang',
          email: 'lisa@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 1),
          avatarColor: const Color(0xFF9B59B6),
        ),
      ],
    };

    return members[spaceId] ?? [];
  }
}
