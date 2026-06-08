import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/space_model.dart';

class SpacesRepository {
  static const String _baseUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev/api/v1/spaces';

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

  Future<List<SpaceModel>> fetchSpaces() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(_baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
      return data.map((e) => SpaceModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load spaces: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceModel> createSpace(String name, String description) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode({'name': name, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return SpaceModel.fromJson(data);
    } else {
      throw Exception('Failed to create space: ${response.statusCode} ${response.body}');
    }
  }

  Future<SpaceModel> updateSpace(String id, String name, String description) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: jsonEncode({'name': name, 'description': description}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return SpaceModel.fromJson(data);
    } else {
      throw Exception('Failed to update space: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteSpace(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete space: ${response.statusCode} ${response.body}');
    }
  }
}
