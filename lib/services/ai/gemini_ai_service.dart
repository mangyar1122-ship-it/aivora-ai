import 'package:firebase_ai/firebase_ai.dart';

import 'ai_service.dart';

class GeminiAiService implements AiService {
  late final GenerativeModel _model;

  GeminiAiService() {
    final thinkingConfig = ThinkingConfig.withThinkingLevel(
      ThinkingLevel.minimal,
    );

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.8-flash',
      generationConfig: GenerationConfig(
        maxOutputTokens: 8000,
        thinkingConfig: thinkingConfig,
      ),
      tools: [
        Tool.urlContext(),
        Tool.googleSearch(),
      ],
    );
  }

  @override
  Future<AiResponse> generateText(String prompt) async {
    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      final text = response.text ?? '';

      if (text.isEmpty) {
        return AiResponse.failure('AI returned an empty response.');
      }

      return AiResponse.success(text);
    } catch (e) {
      return AiResponse.failure(e.toString());
    }
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }
}
