import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  late final ChatSession _chat;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Speed optimization:
    // Gemini 3.x supports LOW thinking level.
    // This keeps normal chat responses faster.
    final thinkingConfig = ThinkingConfig.withThinkingLevel(
      ThinkingLevel.low,
    );

    final generationConfig = GenerationConfig(
      maxOutputTokens: 512,
      thinkingConfig: thinkingConfig,
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash-lite',
      generationConfig: generationConfig,
      systemInstruction: Content.system(
        '''
You are AIVORA AI, the AI assistant inside the AIVORA AI app.

Your name is AIVORA AI.
Do not introduce yourself as Gemini unless the user specifically asks
which underlying model is being used.

Be helpful, accurate, concise and natural.

IMPORTANT CURRENT-DATE RULE:

The app sends the current local date and time with every user message.

When the user asks about:
- today
- tomorrow
- yesterday
- current date
- current time
- day of the week
- how many days ago
- how many days remain

use the AIVORA runtime date/time provided in the message.

NEVER replace the provided current date with an older training date.

If the user asks for information that can change over time and you do
not have live web information available, clearly say that live/current
information is not available instead of inventing an answer.

For calculations involving dates, carefully calculate from the
AIVORA runtime date supplied with the message.

Keep normal answers reasonably concise unless the user asks for detail.

You are the assistant inside AIVORA AI.
''',
      ),
    );

    _chat = model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isLoading) {
      return;
    }

    _controller.clear();

    final now = DateTime.now();

    final currentDate =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final weekday = _weekdayName(now.weekday);

    final prompt = '''
User message:
$text

[AIVORA RUNTIME DATE/TIME]

Current date: $currentDate
Current time: $currentTime
Day: $weekday

IMPORTANT:

Treat the AIVORA runtime date/time above as the authoritative current
date and time for this conversation.

If the user asks "aaj ki date", "today", "kal", "yesterday",
"kitne din hue", or another relative-date question, calculate using
this runtime date.

Do not use an older training date as today's date.
''';

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _messages.add(
        const _ChatMessage(
          text: '',
          isUser: false,
        ),
      );

      _isLoading = true;
    });

    _scrollToBottom();

    final aiMessageIndex = _messages.length - 1;

    try {
      final response = await _chat.sendMessageStream(
        Content.text(prompt),
      );

      String fullReply = '';

      await for (final chunk in response) {
        final chunkText = chunk.text ?? '';

        if (chunkText.isEmpty) {
          continue;
        }

        fullReply += chunkText;

        if (!mounted) {
          return;
        }

        setState(() {
          _messages[aiMessageIndex] = _ChatMessage(
            text: fullReply,
            isUser: false,
          );
        });

        _scrollToBottom();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        if (fullReply.trim().isEmpty) {
          _messages[aiMessageIndex] = const _ChatMessage(
            text: 'I could not generate a response.',
            isUser: false,
          );
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final errorMessage = _getFriendlyErrorMessage(e);

      setState(() {
        _isLoading = false;

        _messages[aiMessageIndex] = _ChatMessage(
          text: errorMessage,
          isUser: false,
        );
      });
    }

    _scrollToBottom();
  }

  String _getFriendlyErrorMessage(Object error) {
    final errorText = error.toString().toLowerCase();

    // Gemini quota / rate-limit errors.
    if (errorText.contains('quota') ||
        errorText.contains('rate limit') ||
        errorText.contains('429') ||
        errorText.contains('resource exhausted')) {
      return '''
AIVORA AI is temporarily busy because the AI request limit has been reached.

Please wait a little and try again.

This is a Gemini API quota limit, not a problem with your message or the AIVORA chat screen.
''';
    }

    // Temporary Gemini overload.
    if (errorText.contains('overloaded') ||
        errorText.contains('unavailable') ||
        errorText.contains('prefill queue')) {
      return '''
AIVORA AI is temporarily busy because the AI service is experiencing high demand.

Please wait a few seconds and try again.
''';
    }

    // Firebase App Check.
    if (errorText.contains('app check') ||
        errorText.contains('attestation') ||
        errorText.contains('403')) {
      return '''
AIVORA security verification failed.

Please make sure you are using the latest AIVORA AI build and try again.
''';
    }

    // Network errors.
    if (errorText.contains('network') ||
        errorText.contains('socket') ||
        errorText.contains('connection')) {
      return '''
AIVORA AI could not connect to the AI service.

Please check your internet connection and try again.
''';
    }

    return '''
AIVORA ERROR:

Something went wrong while generating the response.

Please try again.
''';
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[weekday - 1];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AIVORA AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(
                        _messages[index],
                      );
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AIVORA AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How can I help you today?',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 330,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: message.text.isEmpty && !isUser
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : null,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  _sendMessage();
                },
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Message AIVORA AI...',
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
