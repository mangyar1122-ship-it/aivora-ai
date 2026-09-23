import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final String preview;
  final DateTime createdAt;
  final List<Map<String, dynamic>> messages;
  final String folder;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
    this.messages = const [],
    this.folder = 'General',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'preview': preview,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages,
    'folder': folder,
  };

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: json['messages'] is List
          ? List<Map<String, dynamic>>.from(
              (json['messages'] as List).map(
                (e) => Map<String, dynamic>.from(e),
              ),
            )
          : const [],
      folder: (json['folder'] ?? 'General').toString(),
    );
  }
}

class ChatHistoryService {
  static const String _key = 'aivora_chat_history';
  static const String _foldersKey = 'aivora_chat_folders';

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

  static Future<List<String>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_foldersKey) ?? [];
    return ['General', ...raw.where((e) => e.trim().isNotEmpty && e != 'General')];
  }

  static Future<void> createFolder(String name) async {
    final clean = name.trim();
    if (clean.isEmpty || clean == 'General') return;
    final folders = await getFolders();
    if (!folders.contains(clean)) {
      folders.add(clean);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_foldersKey, folders.skip(1).toList());
    }
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

    final oldFolder = index >= 0 ? history[index].folder : 'General';
    final item = ChatHistoryItem(
      id: id,
      title: title.trim().isEmpty ? 'New conversation' : title.trim(),
      preview: preview,
      createdAt: index >= 0 ? history[index].createdAt : DateTime.now(),
      messages: messages,
      folder: oldFolder,
    );

    if (index >= 0) {
      history[index] = item;
    } else {
      history.insert(0, item);
    }
    await _save(history);
  }

  static Future<void> renameConversation(String id, String newTitle) async {
    final title = newTitle.trim();
    if (title.isEmpty) return;
    final history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final old = history[index];
    history[index] = ChatHistoryItem(
      id: old.id,
      title: title,
      preview: old.preview,
      createdAt: old.createdAt,
      messages: old.messages,
      folder: old.folder,
    );
    await _save(history);
  }

  static Future<void> moveConversation(String id, String folder) async {
    final history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final old = history[index];
    history[index] = ChatHistoryItem(
      id: old.id,
      title: old.title,
      preview: old.preview,
      createdAt: old.createdAt,
      messages: old.messages,
      folder: folder,
    );
    await _save(history);
  }

  static Future<void> deleteConversation(String id) async {
    final history = await getHistory();
    history.removeWhere((item) => item.id == id);
    await _save(history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(List<ChatHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(history.take(50).map((item) => item.toJson()).toList()),
    );
  }
}
