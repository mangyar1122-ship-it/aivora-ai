import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final String preview;
  final DateTime createdAt;
  final List<Map<String, dynamic>> messages;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "preview": preview,
        "createdAt": createdAt.toIso8601String(),
    "messages": messages,
      };

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json["id"] as String,
      title: json["title"] as String,
      preview: json["preview"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
      messages: json["messages"] is List ? List<Map<String, dynamic>>.from((json["messages"] as List).map((e) => Map<String, dynamic>.from(e))) : const [],
    );
  }
}

class ChatHistoryService {
  static const String _key = "aivora_chat_history";

  static Future<List<ChatHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((item) => ChatHistoryItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addConversation({
    required String title,
    required String preview,
  }) async {
    final history = await getHistory();

    final item = ChatHistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? "New conversation" : title.trim(),
      preview: preview.trim(),
      createdAt: DateTime.now(),
      messages: [
        {
          'text': title.trim(),
          'isUser': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'text': preview.trim(),
          'isUser': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
    );

    history.insert(0, item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(history.take(50).map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> saveConversation({
    required String id,
    required String title,
    required List<Map<String, dynamic>> messages,
  }) async {
    final history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);
    final preview = messages
        .where((m) => m['isUser'] == false)
        .map((m) => (m['text'] ?? '').toString())
        .where((text) => text.trim().isNotEmpty)
        .lastOrNull ?? '';

    final item = ChatHistoryItem(
      id: id,
      title: title.trim().isEmpty ? 'New conversation' : title.trim(),
      preview: preview,
      createdAt: index >= 0 ? history[index].createdAt : DateTime.now(),
      messages: messages,
    );

    if (index >= 0) {
      history[index] = item;
    } else {
      history.insert(0, item);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(history.take(50).map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
