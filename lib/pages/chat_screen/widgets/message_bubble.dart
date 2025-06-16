import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;
import 'dart:io';

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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                child: _buildMessageContent(context),
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
      radius: 16,
      backgroundImage: user.profileImage != null
          ? AssetImage(user.profileImage!)
          : null,
      child: user.profileImage == null
          ? Text(user.firstName[0].toUpperCase())
          : null,
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.medias != null && message.medias!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.medias!.first.url),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            if (message.text.trim().isNotEmpty) const SizedBox(height: 4),
          ],
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFFFF204E) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomLeft: Radius.circular(isCurrentUser ? 8 : 0),
                bottomRight: Radius.circular(isCurrentUser ? 0 : 8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.text.trim().isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Text(
                        statusIcon,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white70 : statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 