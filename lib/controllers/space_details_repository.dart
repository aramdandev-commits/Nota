import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/space_note_model.dart';
import '../model/space_member_model.dart';
import '../model/space_model.dart';

class SpaceDetailsRepository {
  static const String _baseUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1/spaces';
  static const String _globalUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': '69420',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SpaceNoteModel>> getNotesForSpace(String spaceId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/$spaceId/notes'), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
      return data.map((e) => SpaceNoteModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load space notes: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceNoteModel> createNote(String spaceId, String title, List<dynamic> content, String preview) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$spaceId/notes'),
      headers: headers,
      body: jsonEncode({'title': title, 'content': content, 'preview': preview}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return SpaceNoteModel.fromJson(data);
    } else {
      throw Exception('Failed to create space note: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceNoteModel> updateNote(String spaceId, String noteId, String title, List<dynamic> content, String preview) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_globalUrl/notes/$noteId'), // Shallow routing
      headers: headers,
      body: jsonEncode({'title': title, 'content': content, 'preview': preview}),
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
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_globalUrl/notes/$noteId'), // Shallow routing
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete space note: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<SpaceMemberModel>> getMembersForSpace(String spaceId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/$spaceId/users'), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
      return data.map((e) => SpaceMemberModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load space members: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, String>> inviteMember(String spaceId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$spaceId/invites'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return {
        'invite_url': data['invite_url']?.toString() ?? '',
        'expires_at': data['expires_at']?.toString() ?? '',
      };
    } else {
      throw Exception('Failed to generate invite: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> changeMemberRole(String spaceId, String userId, SpaceRole newRole) async {
    final headers = await _getHeaders();
    final String roleStr = newRole.toString().split('.').last;
    
    final response = await http.put(
      Uri.parse('$_baseUrl/$spaceId/users/$userId'),
      headers: headers,
      body: jsonEncode({'role': roleStr}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update member role: ${response.statusCode} ${response.body}');
    }
  }
}
