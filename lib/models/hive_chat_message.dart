import 'package:hive/hive.dart';

part 'hive_chat_message.g.dart';

@HiveType(typeId: 0)
class HiveChatMessage extends HiveObject {
  @HiveField(0)
  final String sender;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool isUser;

  HiveChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isUser,
  });
} 