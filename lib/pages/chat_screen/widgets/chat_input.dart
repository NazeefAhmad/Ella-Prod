import 'package:flutter/material.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final model.ChatUser currentUser;
  final Function(model.ChatMessage) onSendMessage;
  final VoidCallback onSendMedia;

  const ChatInput({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.currentUser,
    required this.onSendMessage,
    required this.onSendMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 0)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onSendMedia,
            icon: Image.asset(
              'assets/images/camera.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: Color(0xFF989898),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  final message = model.ChatMessage(
                    user: currentUser,
                    createdAt: DateTime.now(),
                    text: text.trim(),
                  );
                  onSendMessage(message);
                  textController.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/send.png',
              width: 32,
              height: 32,
            ),
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                final message = model.ChatMessage(
                  user: currentUser,
                  createdAt: DateTime.now(),
                  text: text,
                );
                onSendMessage(message);
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
} 