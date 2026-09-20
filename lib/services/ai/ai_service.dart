/// AIVORA AI - Core AI Service
///
/// This file defines the common interface for all AI providers.
/// Gemini, OpenAI, Claude, and other providers can be connected
/// later without changing the rest of the application.

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

  /// Checks whether the AI service is ready.
  Future<bool> isAvailable();
}
