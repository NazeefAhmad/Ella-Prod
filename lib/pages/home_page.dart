import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import '../services/chat_service.dart';
import '../services/chat_cache_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../models/chat_user.dart' as model;
import '../models/chat_media.dart' as model;
import '../models/chat_message.dart' as model;
import '../consts.dart';
import '../services/profile_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/back_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late ChatService _chatService;
  late ChatCacheService _chatCacheService;
  late model.ChatUser currentUser;
  late model.ChatUser botUser;
  bool isApiHealthy = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  List<model.ChatMessage> messages = [];
  bool hasChatStarted = false;
  bool isBotTyping = false;
  final ProfileService _profileService = ProfileService();
  int currentOffset = 0;
  static const int messagesPerPage = 50;
  bool hasMoreMessages = true;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _typingController;
  late Animation<double> _dot1Anim;
  late Animation<double> _dot2Anim;
  late Animation<double> _dot3Anim;

  @override
  void initState() {
    super.initState();
    _initializeChatService();
    _setupScrollController();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot1Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _dot2Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );
    _dot3Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        if (!isLoadingMore && hasMoreMessages) {
          _loadMoreMessages();
        }
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (!isApiHealthy || isLoadingMore) return;

    setState(() => isLoadingMore = true);
    try {
      final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      print('📱 Loading more messages for chat ID: $chatId, offset: $currentOffset');

      // Need to fetch from server
      final response = await _chatService.getChatHistory(
        chatId,
        limit: messagesPerPage,
        offset: currentOffset,
      );

      if (response.messages.isNotEmpty) {
        final newMessages = response.messages.map((msg) => model.ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
          text: msg.content,
        )).toList();

        setState(() {
          // Add new messages to the end of the list
          messages = [...messages, ...newMessages];
          currentOffset += newMessages.length;
          hasMoreMessages = newMessages.length == messagesPerPage;
        });

        // Update cache in background
        _chatCacheService.saveMessages(chatId, messages).then((_) {
          print('📱 Successfully cached ${messages.length} messages');
        });
        print('📱 Successfully loaded ${newMessages.length} more messages from server');
      } else {
        setState(() => hasMoreMessages = false);
        print('📱 No more messages to load');
      }
    } catch (e) {
      print('📱 Error loading more messages: $e');
      Get.snackbar('Error', 'Failed to load more messages.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  Future<void> _loadMessages() async {
    try {
      final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      print('📱 Loading chat history for chat ID: $chatId');

      // Check if this is a refresh operation
      final isRefresh = currentOffset == 0;

      if (isRefresh && isApiHealthy) {
        // Always fetch from server on refresh
        print('📱 Refreshing messages from server...');
        await _refreshFromServer(chatId);
        return;
      }

      // For normal loading, try cache first
      print('📱 Loading from cache...');
      final cachedMessages = await _chatCacheService.getMessages(chatId);
      
      if (cachedMessages.isNotEmpty) {
        print('📱 Found ${cachedMessages.length} messages in cache');
        setState(() {
          messages = cachedMessages;
          hasChatStarted = true;
          currentOffset = messages.length;
          hasMoreMessages = messages.length >= messagesPerPage;
        });
        
        // Only fetch from server if we're online and cache is older than 5 minutes
        if (isApiHealthy) {
          final lastMessageTime = cachedMessages.first.createdAt;
          final cacheAge = DateTime.now().difference(lastMessageTime);
          
          if (cacheAge.inMinutes > 5) {
            print('📱 Cache is older than 5 minutes, refreshing from server...');
            _refreshFromServer(chatId);
          } else {
            print('📱 Using cached data (age: ${cacheAge.inMinutes} minutes)');
          }
        }
      } else {
        print('📱 No cached messages found');
        // Only fetch from server if we're online
        if (isApiHealthy) {
          await _refreshFromServer(chatId);
        } else {
          setState(() {
            hasChatStarted = false;
            messages = [];
            currentOffset = 0;
            hasMoreMessages = false;
          });
        }
      }
      
      if (!hasChatStarted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _focusInput());
      }
    } catch (e) {
      print('📱 Error loading messages: $e');
      setState(() {
        hasChatStarted = false;
        messages = [];
        currentOffset = 0;
        hasMoreMessages = false;
      });
      Get.snackbar('Info', 'Starting a new chat.',
          snackPosition: SnackPosition.BOTTOM);
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusInput());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshFromServer(String chatId) async {
    try {
      setState(() => isLoading = true);
      print('📱 Fetching from server...');
      
      final response = await _chatService.getChatHistory(
        chatId,
        limit: messagesPerPage,
        offset: 0,
      );

      if (response.messages.isNotEmpty) {
        final newMessages = response.messages.map((msg) => model.ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
          text: msg.content,
        )).toList();

        setState(() {
          messages = newMessages;
          hasChatStarted = messages.isNotEmpty;
          currentOffset = messages.length;
          hasMoreMessages = messages.length >= messagesPerPage;
        });

        // Update cache in background
        _chatCacheService.saveMessages(chatId, newMessages).then((_) {
          print('📱 Successfully updated cache with ${newMessages.length} messages');
        });
        print('📱 Successfully updated with ${messages.length} messages from server');
      } else {
        print('📱 No messages found from server');
        if (messages.isEmpty) {
          setState(() {
            hasChatStarted = false;
            messages = [];
            currentOffset = 0;
            hasMoreMessages = false;
          });
        }
      }
    } catch (e) {
      print('📱 Error fetching from server: $e');
      Get.snackbar('Error', 'Failed to refresh messages.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _focusInput() {
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  Future<void> _initializeChatService() async {
    try {
      setState(() {
        _chatService = ChatService(
          baseUrl: AppConstants.baseUrl,
          userId: AppConstants.userId,
          userName: AppConstants.userName,
        );
        _chatCacheService = ChatCacheService();
        
        // Get character information from arguments
        final args = Get.arguments as Map<String, dynamic>?;
        final characterName = args?['characterName'] as String? ?? 'Ella';
        final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
        final characterBio = args?['characterBio'] as String? ?? '';

        currentUser = model.ChatUser(id: AppConstants.userId, firstName: AppConstants.userName);
        botUser = model.ChatUser(
          id: "bot",
          firstName: characterName,
          profileImage: characterImage,
        );
      });

      _initializeChat();
    } catch (e) {
      print('Error initializing chat service: $e');
      // Fallback to guest user if there's an error
      setState(() {
        _chatService = ChatService(
          baseUrl: AppConstants.baseUrl,
          userId: "Guest",
          userName: "Guest",
        );
        _chatCacheService = ChatCacheService();
        
        currentUser = model.ChatUser(id: "Guest", firstName: "Guest");
        botUser = model.ChatUser(
          id: "bot",
          firstName: "Ella",
          profileImage: "assets/images/Ella-Bot.jpeg",
        );
      });
      _initializeChat();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    print('📱 Initializing chat...');
    await _checkApiHealth();
    
    // Always try to load messages, even if API is not healthy
    // This ensures we show cached messages when offline
    await _loadMessages();
  }

  Future<void> _checkApiHealth() async {
    try {
      print('📱 Checking API health...');
      isApiHealthy = await _chatService.checkHealth();
      if (!isApiHealthy) {
        print('📱 API health check failed');
        Get.snackbar('Connection Error', 'Chat server is offline.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        print('📱 API health check passed');
      }
    } catch (e) {
      print('📱 API health check error: $e');
      isApiHealthy = false;
      Get.snackbar('Connection Error', 'Failed to connect to chat server.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _sendMessage(model.ChatMessage chatMessage) async {
    if (!isApiHealthy) {
      Get.snackbar('Error', 'Server unavailable. Try again later.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // Create a message with sending status
    final sendingMessage = model.ChatMessage(
      user: chatMessage.user,
      createdAt: chatMessage.createdAt,
      text: chatMessage.text,
      medias: chatMessage.medias,
      status: model.MessageStatus.sending,
    );

    // Update UI immediately with sending status
    setState(() {
      messages.insert(0, sendingMessage);
      hasChatStarted = true;
    });

    // Start status progression timers
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          messages[0] = model.ChatMessage(
            user: chatMessage.user,
            createdAt: chatMessage.createdAt,
            text: chatMessage.text,
            medias: chatMessage.medias,
            status: model.MessageStatus.sent,
          );
        });
      }
    });

    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          messages[0] = model.ChatMessage(
            user: chatMessage.user,
            createdAt: chatMessage.createdAt,
            text: chatMessage.text,
            medias: chatMessage.medias,
            status: model.MessageStatus.delivered,
          );
          // Show typing indicator after message is delivered
          isBotTyping = true;
        });
      }
    });

    // Set a timeout for failed status
    Timer(const Duration(seconds: 15), () {
      if (mounted && messages.isNotEmpty && messages[0].status != model.MessageStatus.sent) {
        setState(() {
          messages[0] = model.ChatMessage(
            user: chatMessage.user,
            createdAt: chatMessage.createdAt,
            text: chatMessage.text,
            medias: chatMessage.medias,
            status: model.MessageStatus.failed,
          );
          isBotTyping = false;
        });
        Get.snackbar('Error', 'Message delivery failed.',
            snackPosition: SnackPosition.BOTTOM);
      }
    });

    try {
      // Send message and wait for response
      final response = await _chatService.sendMessage(chatMessage.text);

      // Update the message with sent status
      final sentMessage = model.ChatMessage(
        user: chatMessage.user,
        createdAt: chatMessage.createdAt,
        text: chatMessage.text,
        medias: chatMessage.medias,
        status: model.MessageStatus.sent,
        deliveredAt: DateTime.now(),
      );

      final botMessage = model.ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: response.response,
        status: model.MessageStatus.sent,
        deliveredAt: DateTime.now(),
      );

      // Update UI with sent status and bot response
      setState(() {
        messages[0] = sentMessage; // Update the sending message to sent
        messages.insert(0, botMessage);
        isBotTyping = false;
      });

      // Update cache in background
      _chatCacheService.saveMessages(chatId, messages).then((_) {
        print('📱 Successfully cached new messages');
      });
    } catch (e) {
      print('📱 Error sending message: $e');
      // Update the message with failed status
      final failedMessage = model.ChatMessage(
        user: chatMessage.user,
        createdAt: chatMessage.createdAt,
        text: chatMessage.text,
        medias: chatMessage.medias,
        status: model.MessageStatus.failed,
      );
      setState(() {
        messages[0] = failedMessage;
        isBotTyping = false;
      });
      Get.snackbar('Error', 'Failed to send message.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _sendMediaMessage() async {
    final picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final userText = _textEditingController.text.trim();

      final mediaMsg = model.ChatMessage(
        user: currentUser,
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
      _sendMessage(mediaMsg);
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

  Widget _buildWelcomeSection() {
    return SingleChildScrollView(
      // child: Padding(
      //   padding: const EdgeInsets.all(86.0),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       const Text(
      //         "Hello, Ask Me Anything...",
      //         style: TextStyle(
      //           fontSize: 34,
      //           fontWeight: FontWeight.bold,
      //           color: Colors.black,
      //           fontFamily: 'DM_sans',
      //         ),
      //         textAlign: TextAlign.center,
      //       ),
      //       const SizedBox(height: 8),
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: const [
      //           Icon(Icons.circle, color: Colors.green, size: 14),
      //           SizedBox(width: 6),
      //           Text(
      //             "Online",
      //             style: TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.w200,
      //               color: Colors.blueGrey,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) => Opacity(
              opacity: _dot1Anim.value,
              child: _buildDot(),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) => Opacity(
              opacity: _dot2Anim.value,
              child: _buildDot(),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) => Opacity(
              opacity: _dot3Anim.value,
              child: _buildDot(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF204E)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: messages.length + (isBotTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isBotTyping && index == 0) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundImage: botUser.profileImage != null
                      ? AssetImage(botUser.profileImage!)
                      : null,
                  child: botUser.profileImage == null
                      ? Text(botUser.firstName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 8),
                _buildTypingBubble(),
              ],
            ),
          );
        }

        // Calculate the actual message index
        final messageIndex = isBotTyping ? index - 1 : index;
        final msg = messages[messageIndex];
        final isCurrentUser = msg.user.id == currentUser.id;
        
        String statusIcon = '';
        Color statusColor = Colors.grey;
        
        if (isCurrentUser) {
          switch (msg.status) {
            case model.MessageStatus.sending:
              statusIcon = '⌛';
              statusColor = Colors.grey;
              break;
            case model.MessageStatus.sent:
              statusIcon = '✓';
              statusColor = Colors.grey;
              break;
            case model.MessageStatus.delivered:
              statusIcon = '✓✓';
              statusColor = Colors.grey;
              break;
            case model.MessageStatus.read:
              statusIcon = '✓✓';
              statusColor = Colors.blue;
              break;
            case model.MessageStatus.failed:
              statusIcon = '⚠';
              statusColor = Colors.red;
              break;
          }
        }

        // Add date separator if needed
        bool showDateSeparator = false;
        if (messageIndex < messages.length - 1) {
          final currentDate = msg.createdAt;
          final nextDate = messages[messageIndex + 1].createdAt;
          showDateSeparator = !_isSameDay(currentDate, nextDate);
        }

        return Column(
          children: [
            if (showDateSeparator)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatDate(msg.createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isCurrentUser) ...[
                    CircleAvatar(
                      backgroundImage: msg.user.profileImage != null
                          ? AssetImage(msg.user.profileImage!)
                          : null,
                      child: msg.user.profileImage == null
                          ? Text(msg.user.firstName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
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
                            msg.text,
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
                                DateFormat('HH:mm').format(msg.createdAt),
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
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundImage: msg.user.profileImage != null
                          ? AssetImage(msg.user.profileImage!)
                          : null,
                      child: msg.user.profileImage == null
                          ? Text(msg.user.firstName[0].toUpperCase())
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    // Get character information from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final characterName = args?['characterName'] as String? ?? 'Ella';
    final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
    final characterBio = args?['characterBio'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          characterName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: Stack(
        children: [
          _buildGradient(),
          if (isLoading)
            _buildLoadingIndicator()
          else if (!hasChatStarted)
            _buildWelcomeSection()
          else
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  currentOffset = 0;
                  hasMoreMessages = true;
                });
                await _loadMessages();
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
                          if (isLoadingMore)
                            Positioned(
                              bottom: 80,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF204E)),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Loading more messages...',
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 0)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _sendMediaMessage,
                            icon: Image.asset(
                              'assets/images/camera.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              focusNode: _focusNode,
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
                            ),
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/images/send.png',
                              width: 32,
                              height: 32,
                            ),
                            onPressed: () {
                              if (_textEditingController.text.trim().isNotEmpty) {
                                final message = model.ChatMessage(
                                  user: currentUser,
                                  createdAt: DateTime.now(),
                                  text: _textEditingController.text.trim(),
                                );
                                _textEditingController.clear();
                                _sendMessage(message);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Conversion functions between our models and dash_chat_2
  ChatUser toDashChatUser(model.ChatUser user) => ChatUser(
    id: user.id,
    firstName: user.firstName,
    profileImage: user.profileImage,
  );

  model.ChatUser fromDashChatUser(ChatUser user) => model.ChatUser(
    id: user.id,
    firstName: user.firstName ?? '',
    profileImage: user.profileImage,
  );

  ChatMessage toDashChatMessage(model.ChatMessage msg) {
    String statusIcon = '';
    if (msg.user.id == currentUser.id) {
      switch (msg.status) {
        case model.MessageStatus.sending:
          statusIcon = ' ⌛'; // Hourglass for sending
          break;
        case model.MessageStatus.sent:
          statusIcon = ' ✓'; // Single tick for sent
          break;
        case model.MessageStatus.delivered:
          statusIcon = ' ✓✓'; // Double tick for delivered
          break;
        case model.MessageStatus.read:
          statusIcon = ' ✓✓'; // Double tick in blue for read
          break;
        case model.MessageStatus.failed:
          statusIcon = ' ⚠'; // Warning for failed
          break;
      }
    }

    return ChatMessage(
      user: toDashChatUser(msg.user),
      createdAt: msg.createdAt,
      text: msg.text + statusIcon,
      medias: msg.medias?.map((m) => ChatMedia(
        url: m.url,
        fileName: m.fileName,
        type: MediaType.image,
      )).toList(),
    );
  }

  model.ChatMessage fromDashChatMessage(ChatMessage msg) => model.ChatMessage(
    user: fromDashChatUser(msg.user),
    createdAt: msg.createdAt,
    text: msg.text,
    medias: msg.medias?.map((m) => model.ChatMedia(
      url: m.url,
      fileName: m.fileName,
      type: model.MediaType.image,
    )).toList(),
  );
}
