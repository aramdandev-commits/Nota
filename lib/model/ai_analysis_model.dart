/// Model representing the result of an AI analysis.
/// Designed to map directly to the backend API response shape.
class AiAnalysisResult {
  final String summary;
  final List<String> keyPoints;

  const AiAnalysisResult({
    required this.summary,
    required this.keyPoints,
  });

  factory AiAnalysisResult.fromMap(Map<String, dynamic> map) {
    return AiAnalysisResult(
      summary: map['summary'] as String? ?? '',
      keyPoints: List<String>.from(map['key_points'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'summary': summary,
        'key_points': keyPoints,
      };
}
