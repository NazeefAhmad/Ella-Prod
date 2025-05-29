import 'chat_user.dart';
import 'chat_media.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

class ChatMessage {
  final ChatUser user;
  final DateTime createdAt;
  final String text;
  final List<ChatMedia>? medias;
  final MessageStatus status;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  ChatMessage({
    required this.user,
    required this.createdAt,
    required this.text,
    this.medias,
    this.status = MessageStatus.sent,
    this.deliveredAt,
    this.readAt,
  });
} 