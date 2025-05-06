import 'chat_user.dart';
import 'chat_media.dart';

class ChatMessage {
  final ChatUser user;
  final DateTime createdAt;
  final String text;
  final List<ChatMedia>? medias;

  ChatMessage({
    required this.user,
    required this.createdAt,
    required this.text,
    this.medias,
  });
} 