import 'package:get/get.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_cache_service.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;
import '../../../consts.dart';
import '../../../services/profile_service.dart';
import 'dart:async';
import '../../../services/local_chat_service.dart';
import '../../../models/chat_message.dart' as local_chat_model;
import '../../../models/hive_chat_message.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService(
    baseUrl: AppConstants.baseUrl,
    userName: AppConstants.userName, 
    userId: AppConstants.userId,
  );
  final ChatCacheService _chatCacheService = ChatCacheService();
  final ProfileService _profileService = ProfileService();
  final LocalChatService _localChatService = LocalChatService();

  final RxList<model.ChatMessage> messages = <model.ChatMessage>[].obs;
  final RxBool isApiHealthy = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasChatStarted = false.obs;
  final RxBool isBotTyping = false.obs;
  final RxInt currentOffset = 0.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxString lastSentMessageId = ''.obs;

  late model.ChatUser currentUser;
  late model.ChatUser botUser;

  static const int messagesPerPage = 50;

  // Add this list at the top of the ChatController class
  final List<String> funnyErrorMessages = [
    "She is sleeping, don't disturb!",
    "A rat bit the wires, we are fixing it 🐀🔌",
    "She went to make chai, please wait ☕",
    "Oops! I am on a coffee break.",
    "Our servers are dancing, please try again soon!",
    "She is meditating, try again in a moment 🧘‍♀️",
    "The internet hamsters are running slow today.",
    "She is updating her diary, please wait...",
    "A pigeon is delivering your message, it might take a while 🕊️",
  ];

  // ✅ Get the correct chat ID - use user ID from ChatService if available, otherwise fallback
  String get chatId {
    final serviceUserId = _chatService.userId;
    if (serviceUserId.isNotEmpty) {
      return serviceUserId;
    }
    // Fallback to AppConstants.userId if ChatService doesn't have it
    if (AppConstants.userId.isNotEmpty) {
      return AppConstants.userId;
    }
    // Only use guest ID if no user ID is available
    return 'guest_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeChatService();
  }

  Future<void> _initializeChatService() async {
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      final characterName = args?['characterName'] as String? ?? 'Ella';
      final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
      final characterBio = args?['characterBio'] as String? ?? '';

      currentUser = model.ChatUser(id: chatId, firstName: AppConstants.userName);
      botUser = model.ChatUser(
        id: "bot",
        firstName: characterName,
        profileImage: characterImage,
      );

      await _initializeChat();
    } catch (e) {
      print('Error initializing chat service: $e');
      currentUser = model.ChatUser(id: chatId, firstName: "Guest");
      botUser = model.ChatUser(
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
    
    // ✅ Refresh user data if we don't have a valid user ID
    if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
      print('📱 No user ID found, refreshing user data...');
      await _chatService.refreshUserData();
    }
    
    await loadMessages();
  }

  Future<void> _checkApiHealth() async {
    try {
      print('📱 Checking API health...');
      isApiHealthy.value = await _chatService.checkHealth();
      if (!isApiHealthy.value) {
        print('📱 API health check failed');
        Get.snackbar('Connection Error', 'Chat server is offline.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        print('📱 API health check passed');
      }
    } catch (e) {
      print('📱 API health check error: $e');
      isApiHealthy.value = false;
      Get.snackbar('Connection Error', 'Failed to connect to chat server.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loadMessages() async {
    try {
      final chatId = this.chatId;
      print('📱 Loading chat history for chat ID: $chatId');

      // Load recent messages with caching for instant display
      final localMessages = _localChatService.getRecentMessages(count: 20);
      if (localMessages.isNotEmpty) {
        print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
        // Convert Hive messages to UI messages
        messages.value = localMessages.map((msg) => model.ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: msg.timestamp,
          text: msg.message,
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

  // Load more local messages (pagination)
  Future<void> loadMoreLocalMessages() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final moreMessages = _localChatService.getMessages(
        limit: LocalChatService.pageSize,
        offset: currentOffset.value,
      );

      if (moreMessages.isNotEmpty) {
        final newMessages = moreMessages.map((msg) => model.ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: msg.timestamp,
          text: msg.message,
        )).toList();

        messages.addAll(newMessages);
        currentOffset.value += newMessages.length;
        hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

        print('📱 Loaded ${newMessages.length} more local messages');
        print('📱 Total local messages: ${messages.length}');
      } else {
        hasMoreMessages.value = false;
        print('📱 No more local messages available');
      }
    } catch (e) {
      print('📱 Error loading more local messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    // First try to load more local messages
    if (_localChatService.hasMoreMessages(currentOffset.value)) {
      await loadMoreLocalMessages();
      return;
    }

    // If no more local messages, fetch from server
    if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

    isLoadingMore.value = true;
    try {
      final chatId = this.chatId;
      print('📱 Loading more messages from server for chat ID: $chatId, offset: ${currentOffset.value}');

      final response = await _chatService.getChatHistory(
        chatId,
        limit: messagesPerPage,
        offset: currentOffset.value,
      );

      if (response.messages.isNotEmpty) {
        final newMessages = response.messages.map((msg) => model.ChatMessage(
          user: msg.isUser ? currentUser : botUser,
          createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
          text: msg.content,
        )).toList();

        // Add new messages to the beginning (older messages)
        messages.addAll(newMessages);
        currentOffset.value += newMessages.length;
        hasMoreMessages.value = newMessages.length == messagesPerPage;

        // Save new messages to Hive local storage
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
        print('📱 Total messages now: ${messages.length}');
      } else {
        hasMoreMessages.value = false;
        print('📱 No more messages available on server');
      }
    } catch (e) {
      print('📱 Error loading more messages: $e');
      Get.snackbar('Error', 'Failed to load more messages.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> sendMessage(model.ChatMessage chatMessage) async {
    if (!isApiHealthy.value) {
      Get.snackbar('Error', 'Server unavailable. Try again later.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    if (lastSentMessageId.value == messageId) {
      return;
    }
    lastSentMessageId.value = messageId;

    final chatId = this.chatId;

    final sendingMessage = model.ChatMessage(
      user: chatMessage.user,
      createdAt: chatMessage.createdAt,
      text: chatMessage.text,
      medias: chatMessage.medias,
      status: model.MessageStatus.sending,
      id: messageId,
    );

    messages.insert(0, sendingMessage);
    hasChatStarted.value = true;
    isBotTyping.value = true;

    // Save user message to Hive local storage immediately
    final localMsg = HiveChatMessage(
      sender: chatMessage.user.firstName,
      message: chatMessage.text,
      timestamp: chatMessage.createdAt,
      isUser: chatMessage.user.id == currentUser.id,
    );
    await _localChatService.saveMessage(localMsg);

    try {
      final response = await _chatService.sendMessage(chatMessage.text);

      // Handle multiple responses from the backend
      final botMessage = model.ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: response.response,
        status: model.MessageStatus.sent,
        deliveredAt: DateTime.now(),
        id: '${messageId}_bot',
      );

      if (messages.isNotEmpty && messages[0].id == messageId) {
        messages[0] = model.ChatMessage(
          user: chatMessage.user,
          createdAt: chatMessage.createdAt,
          text: chatMessage.text,
          medias: chatMessage.medias,
          status: model.MessageStatus.sent,
          id: messageId,
        );
        messages.insert(0, botMessage);
      }
      isBotTyping.value = false;

      // Save bot message to Hive local storage
      final localBotMsg = HiveChatMessage(
        sender: botUser.firstName,
        message: response.response,
        timestamp: DateTime.now(),
        isUser: false,
      );
      await _localChatService.saveMessage(localBotMsg);

      print('📱 Message sent and saved to local storage');

      // Debugging: Log all messages in the list
      print('📱 Current messages in the list:');
      for (var msg in messages) {
        print('Message ID: ${msg.id}, Text: ${msg.text}, User: ${msg.user.firstName}');
      }
    } catch (e) {
      print('📱 Error sending message: $e');
      // Update message status to failed
      if (messages.isNotEmpty && messages[0].id == messageId) {
        messages[0] = model.ChatMessage(
          user: chatMessage.user,
          createdAt: chatMessage.createdAt,
          text: chatMessage.text,
          medias: chatMessage.medias,
          status: model.MessageStatus.failed,
          id: messageId,
        );
        // Inject a funny error message as a bot reply
        final random = DateTime.now().millisecondsSinceEpoch;
        final funnyMessage = funnyErrorMessages[random % funnyErrorMessages.length];
        final botErrorMessage = model.ChatMessage(
          user: botUser,
          createdAt: DateTime.now(),
          text: funnyMessage,
          status: model.MessageStatus.sent,
          deliveredAt: DateTime.now(),
          id: '${messageId}_bot_error',
        );
        messages.insert(0, botErrorMessage);
        // Save bot error message to Hive local storage
        final localBotMsg = HiveChatMessage(
          sender: botUser.firstName,
          message: funnyMessage,
          timestamp: DateTime.now(),
          isUser: false,
        );
        await _localChatService.saveMessage(localBotMsg);
      }
      isBotTyping.value = false;
    }
  }

  Future<void> clearLocalChat() async {
    await _localChatService.clearMessages();
    print('📱 Local chat history cleared');
  }

  // Get storage information
  Map<String, dynamic> getStorageInfo() {
    return _localChatService.getStorageInfo();
  }

  // Manual cleanup - keep only last N messages
  Future<void> keepLastMessages(int count) async {
    await _localChatService.keepLastMessages(count);
    await loadMessages(); // Reload messages after cleanup
  }

  // Delete messages older than specific date
  Future<void> deleteMessagesOlderThan(DateTime date) async {
    await _localChatService.deleteMessagesOlderThan(date);
    await loadMessages(); // Reload messages after cleanup
  }

  // Search messages in local storage
  List<model.ChatMessage> searchLocalMessages(String query) {
    final searchResults = _localChatService.searchMessages(query);
    return searchResults.map((msg) => model.ChatMessage(
      user: msg.isUser ? currentUser : botUser,
      createdAt: msg.timestamp,
      text: msg.message,
    )).toList();
  }

  // Get storage statistics
  Map<String, dynamic> getStorageStats() {
    final info = _localChatService.getStorageInfo();
    return {
      ...info,
      'localMessageCount': _localChatService.getMessageCount(),
      'displayedMessages': messages.length,
    };
  }
}