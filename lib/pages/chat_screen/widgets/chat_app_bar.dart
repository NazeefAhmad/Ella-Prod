import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/chat_service.dart';
import '../../../widgets/back_button.dart';
import '../controllers/chat_controller.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String characterName;
  final String characterImage;
  final RxBool isBotTyping;
  final String currentChatId;

  const ChatAppBar({
    super.key,
    required this.characterName,
    required this.characterImage,
    required this.isBotTyping,
    required this.currentChatId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnimation;
  final ChatService _chatService = Get.find<ChatService>(); // ✅ Automatically injects ChatService

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      toolbarHeight: 80,
      leading: const CustomBackButton(),
      title: Row(
        children: [
          Obx(() {
            final isTyping = widget.isBotTyping.value;
            return AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isTyping ? _pulseAnimation.value : 1.0,
                  child: _buildGradientAvatar(isTyping),
                );
              },
            );
          }),
          const SizedBox(width: 12),
          Expanded(child: _buildNameAndTypingIndicator()),
        ],
      ),
      actions: [_buildPopupMenu()],
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.shade200, height: 1),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) => _handleMenuSelection(value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
        PopupMenuItem(value: 'mute', child: Text('Mute')),
        PopupMenuItem(value: 'report', child: Text('Report Chat')),
      ],
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'clear') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Chat?'),
          content: const Text('Are you sure you want to clear this chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await _chatService.clearChatHistory(widget.currentChatId);
        if (success) {
          Get.snackbar('Success', 'Chat cleared.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade50,
              colorText: Colors.black);
          // Clear local UI messages and refresh chat screen
          final controller = Get.find<ChatController>();
          controller.messages.clear();
          controller.hasChatStarted.value = false;
        } else {
          Get.snackbar('Failed', 'Could not clear chat.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade50,
              colorText: Colors.black);
        }
      }
    } else if (value == 'mute') {
      debugPrint("Mute selected");
      // Implement mute logic here
    } else if (value == 'report') {
      debugPrint("Report selected");
      // Implement report logic here
    }
  }

  Widget _buildGradientAvatar(bool isTyping) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isTyping ? const LinearGradient(colors: [Colors.purple, Colors.blue]) : null,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.asset(
            widget.characterImage,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                widget.characterName.isNotEmpty ? widget.characterName[0].toUpperCase() : '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndTypingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.characterName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        Obx(() => widget.isBotTyping.value
            ? Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'typing',
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    _buildTypingDots(),
                  ],
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTypingDots() {
    return Row(
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5 + (value * 0.5)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
