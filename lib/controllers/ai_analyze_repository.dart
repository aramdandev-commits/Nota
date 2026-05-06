import '../model/ai_analysis_model.dart';

/// Abstract contract for the AI analysis data source.
/// Swap [MockAiAnalyzeRepository] for [ApiAiAnalyzeRepository] when the
/// backend is ready — the provider and UI never need to change.
abstract class AiAnalyzeRepository {
  /// Analyse raw [text] and return a structured result.
  Future<AiAnalysisResult> analyzeText(String text);

  /// Analyse a saved note by its [noteId] and return a structured result.
  Future<AiAnalysisResult> analyzeNote(String noteId);
}

// ---------------------------------------------------------------------------
// Mock implementation — replace with real HTTP calls later
// ---------------------------------------------------------------------------

class MockAiAnalyzeRepository implements AiAnalyzeRepository {
  @override
  Future<AiAnalysisResult> analyzeText(String text) async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 2));

    final wordCount = text.trim().split(RegExp(r'\s+')).length;

    return AiAnalysisResult(
      summary: 'This text explores key concepts across $wordCount words. '
          'The content demonstrates a positive overall tone with clear '
          'structured ideas and well-organized arguments.',
      keyPoints: [
        'Contains $wordCount words with ~${(wordCount / 200).ceil()} minute read time',
        'Overall positive tone detected',
        'Detailed and comprehensive content structure',
        'Key themes: **External, and, internal, threats**',
      ],
    );
  }

  @override
  Future<AiAnalysisResult> analyzeNote(String noteId) async {
    await Future.delayed(const Duration(seconds: 2));

    return AiAnalysisResult(
      summary: 'This note explores key concepts across 184 words. '
          'The content demonstrates a positive overall tone with clear '
          'structured ideas and well-organized arguments.',
      keyPoints: [
        'Contains 184 words with ~1 minute read time',
        'Overall positive tone detected',
        'Detailed and comprehensive content structure',
        'Key themes: **External, and, internal, threats**',
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TODO: Real API implementation — uncomment and fill in when backend is ready
// ---------------------------------------------------------------------------
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ApiAiAnalyzeRepository implements AiAnalyzeRepository {
//   final String baseUrl;
//   final String authToken;
//
//   const ApiAiAnalyzeRepository({
//     required this.baseUrl,
//     required this.authToken,
//   });
//
//   @override
//   Future<AiAnalysisResult> analyzeText(String text) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/ai/analyze/text'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({'text': text}),
//     );
//     if (response.statusCode != 200) throw Exception('Analysis failed');
//     return AiAnalysisResult.fromMap(jsonDecode(response.body));
//   }
//
//   @override
//   Future<AiAnalysisResult> analyzeNote(String noteId) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/ai/analyze/note'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({'note_id': noteId}),
//     );
//     if (response.statusCode != 200) throw Exception('Analysis failed');
//     return AiAnalysisResult.fromMap(jsonDecode(response.body));
//   }
// }
