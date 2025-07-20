import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input.dart';
import '../widgets/loading_indicators.dart';
import '../../../models/chat_message.dart' as model;
import '../../../models/chat_media.dart' as model;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _controller = Get.put(ChatController());
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        if (!_controller.isLoadingMore.value && _controller.hasMoreMessages.value) {
          _controller.loadMoreMessages();
        }
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMediaMessage() async {
    try {
      final picker = ImagePicker();
      XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (file != null) {
        // Check file size (5MB limit)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) { // 5MB in bytes
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Check file extension
        final extension = file.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid image format. Please use JPG, JPEG, PNG, or GIF'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final userText = _textEditingController.text.trim();

        final mediaMsg = model.ChatMessage(
          user: _controller.currentUser,
          createdAt: DateTime.now(),
          text: userText.isEmpty ? " " : userText,
          medias: [
            model.ChatMedia(
              url: file.path,
              fileName: file.name,
              type: model.MediaType.image,
            ),
          ],
        );

        _textEditingController.clear();
        _controller.sendMessage(mediaMsg);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(250, 251, 254, 1),
            Color.fromRGBO(218, 229, 249, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      return ListView.builder(
        reverse: true,
        controller: _scrollController,
        itemCount: _controller.messages.length + (_controller.isBotTyping.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (_controller.isBotTyping.value && index == 0) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundImage: _controller.botUser.profileImage != null
                        ? AssetImage(_controller.botUser.profileImage!)
                        : null,
                    child: _controller.botUser.profileImage == null
                        ? Text(_controller.botUser.firstName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const TypingIndicator(),
                ],
              ),
            );
          }

          final messageIndex = _controller.isBotTyping.value ? index - 1 : index;
          final msg = _controller.messages[messageIndex];
          final isCurrentUser = msg.user.id == _controller.currentUser.id;
          
         String statusIcon = '';
Color statusColor = Colors.grey.shade600;

if (isCurrentUser) {
  switch (msg.status) {
    case model.MessageStatus.sending:
      statusIcon = ''; // optionally use ⏳ or a shimmer dot
      statusColor = Colors.grey.shade400;
      break;
    case model.MessageStatus.sent:
      statusIcon = '✓';
      statusColor = Colors.grey.shade600;
      break;
    case model.MessageStatus.delivered:
      statusIcon = '✓';
      statusColor = Colors.blue.shade500;
      break;
    case model.MessageStatus.read:
      statusIcon = '✓';
      statusColor = Colors.blue.shade500;
      break;
    case model.MessageStatus.failed:
      statusIcon = '!';
      statusColor = Colors.red.shade400;
      break;
  }
}

          
          bool showDateSeparator = false;
          String? dateText;
          if (messageIndex < _controller.messages.length - 1) {
            final currentDate = msg.createdAt;
            final nextDate = _controller.messages[messageIndex + 1].createdAt;
            showDateSeparator = !_isSameDay(currentDate, nextDate);
            if (showDateSeparator) {
              dateText = _formatDate(msg.createdAt);
            }
          }

          return MessageBubble(
            message: msg,
            isCurrentUser: isCurrentUser,
            statusIcon: statusIcon,
            statusColor: statusColor,
            showDateSeparator: showDateSeparator,
            dateText: dateText,
          );
        },
      );
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return ChatAppBar(
      characterName: _controller.botUser.firstName,
      characterImage: _controller.botUser.profileImage ?? 'assets/images/Ella-Bot.jpeg',
      isBotTyping: _controller.isBotTyping,
      currentChatId: _controller.chatId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGradient(),
          Obx(() {
            if (_controller.isLoading.value) {
              return LoadingIndicators.buildMainLoading();
            }
            return RefreshIndicator(
              onRefresh: () async {
                _controller.currentOffset.value = 0;
                _controller.hasMoreMessages.value = true;
                await _controller.loadMessages();
              },
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/chat_bg2.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: _buildMessageList(),
                          ),
                          Obx(() {
                            if (_controller.isLoadingMore.value) {
                              return LoadingIndicators.buildMoreLoading();
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                    ChatInput(
                      textController: _textEditingController,
                      focusNode: _focusNode,
                      currentUser: _controller.currentUser,
                      onSendMessage: _controller.sendMessage,
                      onSendMedia: _sendMediaMessage,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
} 