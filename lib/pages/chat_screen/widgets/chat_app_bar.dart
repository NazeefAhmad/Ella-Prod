import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/chat_service.dart';
import '../../../widgets/back_button.dart';
import '../controllers/chat_controller.dart';
import 'package:hoocup/services/api_service.dart'; // Added for ApiService

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
          // Clear local Hive storage
          final controller = Get.find<ChatController>();
          await controller.clearLocalChat();
          
          // Clear local UI messages
          controller.messages.clear();
          controller.hasChatStarted.value = false;
          
          Get.snackbar('Success', 'Chat cleared successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade50,
              colorText: Colors.black);
        } else {
          Get.snackbar('Failed', 'Could not clear chat.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade50,
              colorText: Colors.black);
        }
      }
    }else if (value == 'mute') {
  debugPrint("Mute selected");

  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mute Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure? You will no longer receive notifications from this chat.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Mute',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFFF204E),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);


  // If user confirms
  if (confirmed == true) {
    // Show beautiful top snackbar
    Get.snackbar(
      'Muted',
      'Your chats will be muted from now on.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 12,
      icon: const Icon(Icons.volume_off, color: Colors.black54),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
    );

    // 🔇 Implement your mute logic here
    // e.g. mutedChats.add(widget.currentChatId);
  }
}

 else if (value == 'report') {
      debugPrint("Report selected");
      // Show dialog to collect reason and send last 10 messages
      showDialog(
        context: context,
        builder: (context) => _ReportLastMessagesDialog(
          chatId: widget.currentChatId,
        ),
      );
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

class _ReportLastMessagesDialog extends StatefulWidget {
  final String chatId;
  const _ReportLastMessagesDialog({Key? key, required this.chatId}) : super(key: key);

  @override
  State<_ReportLastMessagesDialog> createState() => _ReportLastMessagesDialogState();
}

class _ReportLastMessagesDialogState extends State<_ReportLastMessagesDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Reason required', 'Please enter a reason for reporting.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _isLoading = true);
    final controller = Get.find<ChatController>();
    final messages = controller.messages.take(10).toList();
    final reporterId = controller.currentUser.id;
    final apiService = ApiService();
    final success = await apiService.reportLastMessages(
      chatId: widget.chatId,
      reporterId: reporterId,
      reason: reason,
      messages: messages,
    );
    setState(() => _isLoading = false);
    if (success) {
      Get.back();
      Get.snackbar('Reported', 'Thank you for your report. Our team will review it.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade50, colorText: Colors.black);
    } else {
      Get.snackbar('Failed', 'Could not submit report. Please try again later.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade50, colorText: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Report Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
