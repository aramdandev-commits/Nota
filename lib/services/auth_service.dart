import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

/// Thrown when the API returns an error response.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _baseUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev';

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Client-Type': 'mobile',
  };

  /// POST /api/v1/login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  /// POST /api/v1/register
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    return _handleResponse(response);
  }

  /// POST /api/v1/forgot-password
  Future<String> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    final body = _decodeBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['message'] as String? ?? 'Reset link sent successfully';
    }

    throw AuthException(_extractError(body, response.statusCode));
  }

  UserModel _handleResponse(http.Response response) {
    final body = _decodeBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserModel.fromJson(body);
    }

    // Try to extract a human-readable message from the API error body
    final message = _extractError(body, response.statusCode);
    throw AuthException(message);
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  String _extractError(Map<String, dynamic> body, int statusCode) {
    // Laravel / common API error shapes
    if (body['message'] is String) return body['message'] as String;
    if (body['error'] is String) return body['error'] as String;

    // Validation errors: { "errors": { "email": ["..."] } }
    if (body['errors'] is Map) {
      final errors = body['errors'] as Map;
      final first = errors.values.firstOrNull;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
    }

    return 'Something went wrong (HTTP $statusCode)';
  }
}
