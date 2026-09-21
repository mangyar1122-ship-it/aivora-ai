class AiResponse {
  final String text;
  final bool success;
  final String? error;

  const AiResponse({
    required this.text,
    required this.success,
    this.error,
  });

  factory AiResponse.success(String text) {
    return AiResponse(
      text: text,
      success: true,
    );
  }

  factory AiResponse.failure(String error) {
    return AiResponse(
      text: '',
      success: false,
      error: error,
    );
  }
}

/// Common AI service contract.
///
/// Every AI provider used by AIVORA should follow this interface.
abstract class AiService {
  /// Sends a text prompt to the AI.
  Future<AiResponse> generateText(String prompt);
  Stream<AiStreamChunk> generateTextStream(String prompt);

  /// Checks whether the AI service is ready.
  Future<bool> isAvailable();
}

class AiSource {
  final String title;
  final String uri;

  const AiSource({
    required this.title,
    required this.uri,
  });
}

class AiStreamChunk {
  final String text;
  final List<AiSource> sources;
  final String? searchSuggestionsHtml;

  const AiStreamChunk({
    required this.text,
    this.sources = const [],
    this.searchSuggestionsHtml,
  });
}
