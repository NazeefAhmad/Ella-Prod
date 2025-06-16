import 'package:flutter/material.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
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
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool hasText = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final newHasText = widget.textController.text.trim().isNotEmpty;
    if (newHasText != hasText) {
      setState(() {
        hasText = newHasText;
      });
    }
  }

  void _sendMessage() {
    final text = widget.textController.text.trim();
    if (text.isNotEmpty) {
      final message = model.ChatMessage(
        user: widget.currentUser,
        createdAt: DateTime.now(),
        text: text,
      );
      widget.onSendMessage(message);
      widget.textController.clear();
    }
  }

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
            onPressed: widget.onSendMedia,
            icon: Image.asset(
              'assets/images/camera.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.textController,
              focusNode: widget.focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/send.png',
              width: 32,
              height: 32,
              color: hasText ? const Color(0xFFFF204E) : Colors.grey,
            ),
            onPressed: hasText ? _sendMessage : null,
          ),
        ],
      ),
    );
  }
} 