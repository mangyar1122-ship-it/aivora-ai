import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final String preview;
  final DateTime createdAt;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "preview": preview,
        "createdAt": createdAt.toIso8601String(),
      };

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json["id"] as String,
      title: json["title"] as String,
      preview: json["preview"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
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
    );

    history.insert(0, item);

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
