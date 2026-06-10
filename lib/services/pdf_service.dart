import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_service.dart';

class PdfService {
  static const _baseUrl = 'https://synopsis-cursive-ethics.ngrok-free.dev';

  /// POST /api/v1/notes/read-pdf
  /// Sends the PDF as multipart/form-data with key "file".
  /// Returns the raw response body map on success.
  /// Throws [AuthException] on API errors.
  Future<Map<String, dynamic>> uploadPdf({
    required String filePath,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/notes/read-pdf');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': '69420',
      })
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('📤 PdfService: upload status = ${response.statusCode}');
    debugPrint('📤 PdfService: upload body   = ${response.body}');

    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Extract error message
    final message = body['message'] as String? ??
        body['error'] as String? ??
        'PDF upload failed (HTTP ${response.statusCode})';
    throw AuthException(message);
  }
}
