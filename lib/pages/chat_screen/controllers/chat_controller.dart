
import 'package:get/get.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_cache_service.dart';
import '../../../models/chat_user.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_media.dart';
import '../../../consts.dart';
import '../../../services/profile_service.dart';
import 'dart:async';
import '../../../services/local_chat_service.dart';
import '../../../models/hive_chat_message.dart';
import 'dart:collection';
import 'dart:math';

// ✅ Extension for ChatMessage copyWith method
extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    ChatUser? user,
    DateTime? createdAt,
    String? text,
    List<ChatMedia>? medias,
    MessageStatus? status,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? id,
  }) {
    return ChatMessage(
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      medias: medias ?? this.medias,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      id: id ?? this.id,
    );
  }
}

class ChatController extends GetxController {
  final ChatService _chatService = ChatService(
    baseUrl: AppConstants.baseUrl,
    userName: AppConstants.userName, 
    userId: AppConstants.userId,
  );
  final ChatCacheService _chatCacheService = ChatCacheService();
  final ProfileService _profileService = ProfileService();
  final LocalChatService _localChatService = LocalChatService();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isApiHealthy = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasChatStarted = false.obs;
  final RxBool isBotTyping = false.obs;
  final RxInt currentOffset = 0.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxString lastSentMessageId = ''.obs;
  
  // Removed: Message queue system, retry, and server down state

  DateTime? _lastMessageSent;
  static const int MIN_MESSAGE_INTERVAL_MS = 500; // Minimum 500ms between messages

  late ChatUser currentUser;
  late ChatUser botUser;

  static const int messagesPerPage = 50;

  // Enhanced error messages with server status
  // final List<String> serverDownMessages = [
  //   "The server is taking a quick nap 😴 Your message will be sent when it wakes up!",
  //   "Server overload detected! 🚨 Don't worry, your message is safe in the queue.",
  //   "The hamsters powering our servers need a break 🐹 Retrying automatically...",
  //   "Server maintenance in progress 🔧 Your message will be delivered shortly!",
  //   "Traffic jam on the server highway 🚗💨 Please hold on!",
  // ];

  // final List<String> funnyErrorMessages = [
  //   "She is sleeping, don't disturb!",
  //   "A rat bit the wires, we are fixing it 🐀🔌",
  //   "She went to make chai, please wait ☕",
  //   "Oops! I am on a coffee break.",
  //   "Our servers are dancing, please try again soon!",
  //   "She is meditating, try again in a moment 🧘‍♀️",
  //   "The internet hamsters are running slow today.",
  //   "She is updating her diary, please wait...",
  //   "A pigeon is delivering your message, it might take a while 🕊️",
  // ];

  // ✅ Get the correct chat ID
  String get chatId {
    final serviceUserId = _chatService.userId;
    if (serviceUserId.isNotEmpty) {
      return serviceUserId;
    }
    if (AppConstants.userId.isNotEmpty) {
      return AppConstants.userId;
    }
    return 'guest_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Removed: queueSize, isProcessingQueue, isServerDown, consecutiveFailures, _messageQueue, _isProcessingQueue, _queueSize, _isServerDown, _consecutiveFailures, _currentRetryDelay, _retryTimer, _healthCheckTimer, MAX_RETRY_ATTEMPTS, MAX_RETRY_DELAY_MS, HEALTH_CHECK_INTERVAL_MS

  @override
  void onInit() {
    super.onInit();
    _initializeChatService();
    // Removed: _startPeriodicHealthCheck();
  }

  // Removed: _startPeriodicHealthCheck, _onServerRecovered, _handleServerDown, _consecutiveFailures, _isServerDown, _currentRetryDelay, _retryTimer, _healthCheckTimer

  Future<void> _initializeChatService() async {
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      final characterName = args?['characterName'] as String? ?? 'Ella';
      final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
      final characterBio = args?['characterBio'] as String? ?? '';

      currentUser = ChatUser(id: chatId, firstName: AppConstants.userName);
      botUser = ChatUser(
        id: "bot",
        firstName: characterName,
        profileImage: characterImage,
      );

      await _initializeChat();
    } catch (e) {
      print('Error initializing chat service: $e');
      currentUser = ChatUser(id: chatId, firstName: "Guest");
      botUser = ChatUser(
        id: "bot",
        firstName: "Ella",
        profileImage: "assets/images/Ella-Bot.jpeg",
      );
      await _initializeChat();
    }
  }

  Future<void> _initializeChat() async {
    print('📱 Initializing chat...');
    await _checkApiHealth();
    
    if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
      print('📱 No user ID found, refreshing user data...');
      try {
        await _chatService.refreshUserData();
      } catch (e) {
        print('📱 Failed to refresh user data: $e');
      }
    }
    
    await loadMessages();
  }

  // ✅ Enhanced API health check with better error handling
  Future<void> _checkApiHealth() async {
    try {
      print('📱 Checking API health...');
      isApiHealthy.value = await _chatService.checkHealth();
      
      if (!isApiHealthy.value) {
        // Removed: _handleServerDown();
      } else {
        print('📱 API health check passed');
        // Removed: if (_isServerDown.value) { _onServerRecovered(); }
      }
    } catch (e) {
      print('📱 API health check error: $e');
      isApiHealthy.value = false;
      // Removed: _handleServerDown();
    }
  }

  // Removed: _handleServerDown

  Future<void> loadMessages() async {
    try {
      final chatId = this.chatId;
      print('📱 Loading chat history for chat ID: $chatId');

      final localMessages = _localChatService.getRecentMessages(count: 20);
      if (localMessages.isNotEmpty) {
        print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
        messages.value = localMessages.map((msg) => ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: msg.timestamp,
          text: msg.message,
          status: MessageStatus.sent,
          id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
        )).toList();
        hasChatStarted.value = true;
        currentOffset.value = messages.length;
        hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);
        print('📱 Using cached local data - ${messages.length} messages loaded instantly');
        return;
      } else {
        print('📱 No local messages found - starting fresh chat');
        hasChatStarted.value = false;
        messages.clear();
        currentOffset.value = 0;
        hasMoreMessages.value = false;
      }
    } catch (e) {
      print('📱 Error loading local messages: $e');
      hasChatStarted.value = false;
      messages.clear();
      currentOffset.value = 0;
      hasMoreMessages.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreLocalMessages() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final moreMessages = _localChatService.getMessages(
        limit: LocalChatService.pageSize,
        offset: currentOffset.value,
      );

      if (moreMessages.isNotEmpty) {
        final newMessages = moreMessages.map((msg) => ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: msg.timestamp,
          text: msg.message,
          status: MessageStatus.sent,
          id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
        )).toList();

        messages.addAll(newMessages);
        currentOffset.value += newMessages.length;
        hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

        print('📱 Loaded ${newMessages.length} more local messages');
      } else {
        hasMoreMessages.value = false;
      }
    } catch (e) {
      print('📱 Error loading more local messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (_localChatService.hasMoreMessages(currentOffset.value)) {
      await loadMoreLocalMessages();
      return;
    }

    if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

    isLoadingMore.value = true;
    try {
      final chatId = this.chatId;
      final response = await _chatService.getChatHistory(
        chatId,
        limit: messagesPerPage,
        offset: currentOffset.value,
      );

      if (response.messages.isNotEmpty) {
        final newMessages = response.messages.map((msg) => ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
          text: msg.content,
          status: MessageStatus.sent,
          id: '${msg.timestamp ?? DateTime.now().millisecondsSinceEpoch}_${msg.content.hashCode}',
        )).toList();

        messages.addAll(newMessages);
        currentOffset.value += newMessages.length;
        hasMoreMessages.value = newMessages.length == messagesPerPage;

        for (var msg in newMessages) {
          final localMsg = HiveChatMessage(
            sender: msg.user.firstName,
            message: msg.text,
            timestamp: msg.createdAt,
            isUser: msg.user.id == currentUser.id,
          );
          await _localChatService.saveMessage(localMsg);
        }

        print('📱 Successfully loaded ${newMessages.length} more messages from server');
      } else {
        hasMoreMessages.value = false;
      }
    } catch (e) {
      print('📱 Error loading more messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ✅ Enhanced sendMessage with rate limiting
  Future<void> sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.text.trim().isEmpty) {
      print('📱 Empty message, skipping...');
      return;
    }

    // ✅ Rate limiting check
    final now = DateTime.now();
    if (_lastMessageSent != null) {
      final timeSinceLastMessage = now.difference(_lastMessageSent!).inMilliseconds;
      if (timeSinceLastMessage < MIN_MESSAGE_INTERVAL_MS) {
        final waitMs = MIN_MESSAGE_INTERVAL_MS - timeSinceLastMessage;
        print('📱 Rate limiting: Too fast! Waiting ${waitMs}ms');
        await Future.delayed(Duration(milliseconds: waitMs));
      }
    }
    _lastMessageSent = DateTime.now();

    // ✅ Create unique message ID
    final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';
    
    // ✅ Prevent exact duplicate messages
    if (lastSentMessageId.value == messageId) {
      print('📱 Duplicate message detected, skipping...');
      return;
    }
    lastSentMessageId.value = messageId;

    // ✅ Create message with unique ID
    final messageWithId = chatMessage.copyWith(id: messageId);

    // ✅ Add message to UI immediately
    final sendingMessage = messageWithId.copyWith(
      status: MessageStatus.sending
    );
    messages.insert(0, sendingMessage);
    hasChatStarted.value = true;
    messages.refresh();
    
    print('📱 Message added to UI: ${chatMessage.text}');
    
    // Save user message to local storage immediately
    final localMsg = HiveChatMessage(
      sender: chatMessage.user.firstName,
      message: chatMessage.text,
      timestamp: chatMessage.createdAt,
      isUser: chatMessage.user.id == currentUser.id,
    );
    await _localChatService.saveMessage(localMsg);

    // Directly call backend API (no queue)
    try {
      isBotTyping.value = true;
      final response = await _chatService.sendMessage(chatMessage.text);
      print('📱 Received response: ${response.response}');

      // Update the user message status to sent
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(
          status: MessageStatus.sent,
          deliveredAt: DateTime.now(),
        );
        messages.refresh();
      }

      // Create bot response message
      final botMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: response.response,
        status: MessageStatus.sent,
        deliveredAt: DateTime.now(),
        id: '${messageId}_bot',
      );

      isBotTyping.value = false;
      messages.insert(0, botMessage);
      messages.refresh();

      // Save bot message to local storage
      final localBotMsg = HiveChatMessage(
        sender: botUser.firstName,
        message: response.response,
        timestamp: DateTime.now(),
        isUser: false,
      );
      await _localChatService.saveMessage(localBotMsg);

      print('📱 Message sent successfully');
    } catch (e) {
      print('📱 Error sending message: $e');
      // Mark as failed
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(
          status: MessageStatus.failed,
        );
        messages.refresh();
      }
      isBotTyping.value = false;
    }
  }

  // Removed: _processMessageQueue, _processSingleMessage, retryAllFailedMessages, clearMessageQueue

  // ✅ Convenience method for sending text messages
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final message = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text.trim(),
      status: MessageStatus.sending,
    );
    
    await sendMessage(message);
  }

  // Removed: retryAllFailedMessages, clearMessageQueue

  Future<void> clearLocalChat() async {
    await _localChatService.clearMessages();
    messages.clear();
    hasChatStarted.value = false;
    lastSentMessageId.value = '';
    print('📱 Local chat history cleared');
  }

  Map<String, dynamic> getStorageStats() {
    final info = _localChatService.getStorageInfo();
    return {
      ...info,
      'localMessageCount': _localChatService.getMessageCount(),
      'displayedMessages': messages.length,
      'queueSize': 0, // Removed queueSize
      'isProcessingQueue': false, // Removed isProcessingQueue
      'isServerDown': false, // Removed isServerDown
      'consecutiveFailures': 0, // Removed consecutiveFailures
      'currentRetryDelay': 1000, // Removed currentRetryDelay
    };
  }

  @override
  void onClose() {
    // Removed: _retryTimer?.cancel(); _healthCheckTimer?.cancel(); clearMessageQueue(); _isProcessingQueue.value = false;
    super.onClose();
  }
}