import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../services/ai/gemini_ai_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GeminiAiService _aiService = GeminiAiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];


  bool _isLoading = false;


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
      // IMPORTANT:
      // sendMessageStream() returns a Stream.
      // Do NOT put "await" before it.
        final response = _aiService.generateTextStream(prompt);

        String fullReply = '';
        final webSources = <_WebSource>[];
        String? searchSuggestionsHtml;

        await for (final chunk in response) {
          final chunkText = chunk.text;

          for (final source in chunk.sources) {
            final webSource = _WebSource(
              title: source.title,
              uri: source.uri,
            );

            if (!webSources.any(
              (item) => item.uri == webSource.uri,
            )) {
              webSources.add(webSource);
            }
          }

          searchSuggestionsHtml ??= chunk.searchSuggestionsHtml;

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
              sources: List.unmodifiable(webSources),
              searchSuggestionsHtml: searchSuggestionsHtml,
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
          text: '$errorMessage\n\nAIVORA DEBUG ERROR:\n\n$e',
          isUser: false,
        );
      });
    }

    _scrollToBottom();
  }

  String _getFriendlyErrorMessage(Object error) {
    final errorText = error.toString().toLowerCase();

    if (errorText.contains('quota') ||
        errorText.contains('rate limit') ||
        errorText.contains('429') ||
        errorText.contains('resource exhausted')) {
      return '''
AIVORA AI is temporarily busy because the AI request limit has been reached.

Please wait a little and try again.

This is a Gemini API quota limit, not a problem with your message or
the AIVORA chat screen.
''';
    }

    if (errorText.contains('overloaded') ||
        errorText.contains('unavailable') ||
        errorText.contains('prefill queue')) {
      return '''
AIVORA AI is temporarily busy because the AI service is experiencing
high demand.

Please wait a few seconds and try again.
''';
    }

    if (errorText.contains('app check') ||
        errorText.contains('attestation') ||
        errorText.contains('403')) {
      return '''
AIVORA security verification failed.

Please make sure you are using the latest AIVORA AI build and try again.
''';
    }

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

  Future<void> _copyText(String text) async {
    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showPlusOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add to AIVORA AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _optionTile(
                  icon: Icons.image_rounded,
                  title: 'Image',
                  subtitle: 'Add an image',
                ),
                _optionTile(
                  icon: Icons.attach_file_rounded,
                  title: 'File',
                  subtitle: 'Add a document or file',
                ),
                _optionTile(
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'PDF',
                  subtitle: 'Chat with a PDF',
                ),
                _optionTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  subtitle: 'Take a photo',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: AppTheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title support is coming soon.'),
          ),
        );
      },
    );
  }

  void _showVoiceMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input is coming soon.'),
      ),
    );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cyan,
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyan.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AIVORA",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "AI COMPANION",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Premium",
            onPressed: () {},
            icon: const Icon(
              Icons.workspace_premium_rounded,
              color: AppTheme.cyan,
            ),
          ),
        ],
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cyan,
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyan.withValues(alpha: 0.20),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.18),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.cyan.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.cyan,
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Hello, I’m ",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: "AIVORA",
                    style: TextStyle(
                      color: AppTheme.cyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your smart AI assistant",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Ask me anything, create content,\nsolve problems, or explore powerful AI tools.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.20),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: AppTheme.cyan,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Ready to create something amazing?",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWebSource(String uri) async {
    final url = Uri.tryParse(uri);

    if (url == null) {
      return;
    }

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final isUser = message.isUser;

    if (message.text.isEmpty && isUser == false) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.cyan.withValues(alpha: 0.18),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.cyan,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "AIVORA is thinking...",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 360,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                )
              : null,
          color: isUser ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUser
                ? AppTheme.primary.withValues(alpha: 0.35)
                : AppTheme.cyan.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppTheme.primary.withValues(alpha: 0.16)
                  : AppTheme.cyan.withValues(alpha: 0.06),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser == false)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.cyan,
                            AppTheme.secondary,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      "AIVORA",
                      style: TextStyle(
                        color: AppTheme.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            SelectableText(
              message.text,
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: [
                    ...editableTextState.contextMenuButtonItems,
                    ContextMenuButtonItem(
                      onPressed: () {
                        editableTextState.hideToolbar();
                        _copyText(message.text);
                      },
                      label: "Copy all",
                    ),
                  ],
                );
              },
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : AppTheme.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (isUser == false && message.sources.isNotEmpty)
              ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.language_rounded,
                            color: AppTheme.cyan,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Sources",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...message.sources.map(
                        (source) => InkWell(
                          onTap: () => _openWebSource(source.uri),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.link_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    source.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  color: AppTheme.cyan,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            if (isUser == false)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: "Copy",
                    onPressed: () {
                      _copyText(message.text);
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppTheme.textSecondary,
                      size: 17,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.cyan.withValues(alpha: 0.18),
                ),
              ),
              child: IconButton(
                tooltip: "Add",
                onPressed: _isLoading ? null : _showPlusOptions,
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.cyan,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  enableInteractiveSelection: true,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    _sendMessage();
                  },
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Message AIVORA AI...",
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cyan,
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyan.withValues(alpha: 0.30),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                tooltip: "Send",
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

class _WebSource {
  final String title;
  final String uri;

  const _WebSource({
    required this.title,
    required this.uri,
  });
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<_WebSource> sources;
  final String? searchSuggestionsHtml;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.sources = const [],
    this.searchSuggestionsHtml,
  });
}
