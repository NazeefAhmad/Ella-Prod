import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;

class MessageBubble extends StatelessWidget {
  final model.ChatMessage message;
  final bool isCurrentUser;
  final String statusIcon;
  final Color statusColor;
  final bool showDateSeparator;
  final String? dateText;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.statusIcon,
    required this.statusColor,
    required this.showDateSeparator,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          if (showDateSeparator && dateText != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateText!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) ...[
                _buildAvatar(message.user),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: _buildMessageContent(),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                _buildAvatar(message.user),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(model.ChatUser user) {
    return CircleAvatar(
      backgroundImage: user.profileImage != null
          ? AssetImage(user.profileImage!)
          : null,
      child: user.profileImage == null
          ? Text(user.firstName[0].toUpperCase())
          : null,
    );
  }

  Widget _buildMessageContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFFF204E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: isCurrentUser ? Colors.white : const Color(0xFF989898),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(
                  color: isCurrentUser ? Colors.white70 : Colors.grey,
                  fontSize: 12,
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 4),
                Text(
                  statusIcon,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
} 