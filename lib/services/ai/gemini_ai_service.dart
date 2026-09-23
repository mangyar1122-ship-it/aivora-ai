import 'package:firebase_ai/firebase_ai.dart';

import 'ai_service.dart';
import 'prompts/aivora_system_prompt.dart';

class GeminiAiService implements AiService {
  late final GenerativeModel _model;

  GeminiAiService() {
    final thinkingConfig = ThinkingConfig.withThinkingLevel(
      ThinkingLevel.minimal,
    );

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash-lite',
      generationConfig: GenerationConfig(
        maxOutputTokens: 8000,
        thinkingConfig: thinkingConfig,
      ),
      tools: [
        Tool.urlContext(),
        Tool.googleSearch(),
      ],
      systemInstruction: Content.system(aivoraSystemPrompt),
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
  Stream<AiStreamChunk> generateTextStream(String prompt) async* {
    try {
      final response = _model.generateContentStream([Content.text(prompt)]);
      await for (final chunk in response) {
        final text = chunk.text ?? "";
        final sources = <AiSource>[];
        String? searchSuggestionsHtml;

        final groundingMetadata =
            chunk.candidates.first.groundingMetadata;

        if (groundingMetadata != null) {
          searchSuggestionsHtml =
              groundingMetadata.searchEntryPoint?.renderedContent;

          for (final groundingChunk
              in groundingMetadata.groundingChunks) {
            final web = groundingChunk.web;

            if (web != null &&
                web.uri != null &&
                web.uri!.isNotEmpty) {
              final source = AiSource(
                title: web.title ?? web.uri!,
                uri: web.uri!,
              );

              if (!sources.any(
                (item) => item.uri == source.uri,
              )) {
                sources.add(source);
              }
            }
          }
        }

        if (text.isNotEmpty || sources.isNotEmpty) {
          yield AiStreamChunk(
            text: text,
            sources: List.unmodifiable(sources),
            searchSuggestionsHtml: searchSuggestionsHtml,
          );
        }
      }
    } catch (e) {
      yield AiStreamChunk(text: "[AI_ERROR] $e");
    }
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }
}
