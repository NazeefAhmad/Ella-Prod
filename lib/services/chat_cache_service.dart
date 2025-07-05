import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/chat_media.dart';
import 'shared_preferences_clear_service.dart';

class ChatCacheService {
  static const String _messagesPrefix = 'chat_messages_';

  Future<void> saveMessages(String chatId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages.map((msg) => {
      'user': {
        'id': msg.user.id,
        'firstName': msg.user.firstName,
        'profileImage': msg.user.profileImage,
      },
      'createdAt': msg.createdAt.toIso8601String(),
      'text': msg.text,
      'medias': msg.medias?.map((m) => {
        'url': m.url,
        'fileName': m.fileName,
        'type': m.type.toString(),
      }).toList(),
      'status': msg.status.toString(),
      'deliveredAt': msg.deliveredAt?.toIso8601String(),
      'readAt': msg.readAt?.toIso8601String(),
    }).toList();
    
    await prefs.setString(_messagesPrefix + chatId, jsonEncode(messagesJson));
  }

  Future<List<ChatMessage>> getMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString(_messagesPrefix + chatId);
    
    if (messagesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded.map((msg) => ChatMessage(
        user: ChatUser(
          id: msg['user']['id'],
          firstName: msg['user']['firstName'],
          profileImage: msg['user']['profileImage'],
        ),
        createdAt: DateTime.parse(msg['createdAt']),
        text: msg['text'],
        medias: msg['medias']?.map<ChatMedia>((m) => ChatMedia(
          url: m['url'],
          fileName: m['fileName'],
          type: MediaType.values.firstWhere(
            (e) => e.toString() == m['type'],
            orElse: () => MediaType.image,
          ),
        )).toList(),
        status: MessageStatus.values.firstWhere(
          (e) => e.toString() == msg['status'],
          orElse: () => MessageStatus.sent,
        ),
        deliveredAt: msg['deliveredAt'] != null ? DateTime.parse(msg['deliveredAt']) : null,
        readAt: msg['readAt'] != null ? DateTime.parse(msg['readAt']) : null,
      )).toList();
    } catch (e) {
      print('Error parsing cached messages: $e');
      return [];
    }
  }

  Future<void> clearMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesPrefix + chatId);
  }

  // Clear all chat messages using the dedicated service
  Future<void> clearAllChatMessages() async {
    final clearService = SharedPreferencesClearService();
    await clearService.clearAllUserData();
    print('All chat messages cleared');
  }
} 