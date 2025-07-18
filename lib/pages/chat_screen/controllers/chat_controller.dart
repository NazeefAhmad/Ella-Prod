// // import 'package:get/get.dart';
// // import '../../../services/chat_service.dart';
// // import '../../../services/chat_cache_service.dart';
// // import '../../../models/chat_user.dart' as model;
// // import '../../../models/chat_message.dart' as model;
// // import '../../../consts.dart';
// // import '../../../services/profile_service.dart';
// // import 'dart:async';
// // import '../../../services/local_chat_service.dart';
// // import '../../../models/chat_message.dart' as local_chat_model;
// // import '../../../models/hive_chat_message.dart';

// // class ChatController extends GetxController {
// //   final ChatService _chatService = ChatService(
// //     baseUrl: AppConstants.baseUrl,
// //     userName: AppConstants.userName, 
// //     userId: AppConstants.userId,
// //   );
// //   final ChatCacheService _chatCacheService = ChatCacheService();
// //   final ProfileService _profileService = ProfileService();
// //   final LocalChatService _localChatService = LocalChatService();

// //   final RxList<model.ChatMessage> messages = <model.ChatMessage>[].obs;
// //   final RxBool isApiHealthy = true.obs;
// //   final RxBool isLoading = false.obs;
// //   final RxBool isLoadingMore = false.obs;
// //   final RxBool hasChatStarted = false.obs;
// //   final RxBool isBotTyping = false.obs;
// //   final RxInt currentOffset = 0.obs;
// //   final RxBool hasMoreMessages = true.obs;
// //   final RxString lastSentMessageId = ''.obs;

// //   late model.ChatUser currentUser;
// //   late model.ChatUser botUser;

// //   static const int messagesPerPage = 50;

// //   // Add this list at the top of the ChatController class
// //   final List<String> funnyErrorMessages = [
// //     "She is sleeping, don't disturb!",
// //     "A rat bit the wires, we are fixing it 🐀🔌",
// //     "She went to make chai, please wait ☕",
// //     "Oops! I am on a coffee break.",
// //     "Our servers are dancing, please try again soon!",
// //     "She is meditating, try again in a moment 🧘‍♀️",
// //     "The internet hamsters are running slow today.",
// //     "She is updating her diary, please wait...",
// //     "A pigeon is delivering your message, it might take a while 🕊️",
// //   ];

// //   // ✅ Get the correct chat ID - use user ID from ChatService if available, otherwise fallback
// //   String get chatId {
// //     final serviceUserId = _chatService.userId;
// //     if (serviceUserId.isNotEmpty) {
// //       return serviceUserId;
// //     }
// //     // Fallback to AppConstants.userId if ChatService doesn't have it
// //     if (AppConstants.userId.isNotEmpty) {
// //       return AppConstants.userId;
// //     }
// //     // Only use guest ID if no user ID is available
// //     return 'guest_${DateTime.now().millisecondsSinceEpoch}';
// //   }

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _initializeChatService();
// //   }

// //   Future<void> _initializeChatService() async {
// //     try {
// //       final args = Get.arguments as Map<String, dynamic>?;
// //       final characterName = args?['characterName'] as String? ?? 'Ella';
// //       final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
// //       final characterBio = args?['characterBio'] as String? ?? '';

// //       currentUser = model.ChatUser(id: chatId, firstName: AppConstants.userName);
// //       botUser = model.ChatUser(
// //         id: "bot",
// //         firstName: characterName,
// //         profileImage: characterImage,
// //       );

// //       await _initializeChat();
// //     } catch (e) {
// //       print('Error initializing chat service: $e');
// //       currentUser = model.ChatUser(id: chatId, firstName: "Guest");
// //       botUser = model.ChatUser(
// //         id: "bot",
// //         firstName: "Ella",
// //         profileImage: "assets/images/Ella-Bot.jpeg",
// //       );
// //       await _initializeChat();
// //     }
// //   }

// //   Future<void> _initializeChat() async {
// //     print('📱 Initializing chat...');
// //     await _checkApiHealth();
    
// //     // ✅ Refresh user data if we don't have a valid user ID
// //     if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
// //       print('📱 No user ID found, refreshing user data...');
// //       await _chatService.refreshUserData();
// //     }
    
// //     await loadMessages();
// //   }

// //   Future<void> _checkApiHealth() async {
// //     try {
// //       print('📱 Checking API health...');
// //       isApiHealthy.value = await _chatService.checkHealth();
// //       if (!isApiHealthy.value) {
// //         print('📱 API health check failed');
// //         Get.snackbar('Connection Error', 'Chat server is offline.',
// //             snackPosition: SnackPosition.BOTTOM);
// //       } else {
// //         print('📱 API health check passed');
// //       }
// //     } catch (e) {
// //       print('📱 API health check error: $e');
// //       isApiHealthy.value = false;
// //       Get.snackbar('Connection Error', 'Failed to connect to chat server.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     }
// //   }

// //   Future<void> loadMessages() async {
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading chat history for chat ID: $chatId');

// //       // Load recent messages with caching for instant display
// //       final localMessages = _localChatService.getRecentMessages(count: 20);
// //       if (localMessages.isNotEmpty) {
// //         print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
// //         // Convert Hive messages to UI messages
// //         messages.value = localMessages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //         )).toList();
// //         hasChatStarted.value = true;
// //         currentOffset.value = messages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);
// //         print('📱 Using cached local data - ${messages.length} messages loaded instantly');
// //         return;
// //       } else {
// //         print('📱 No local messages found - starting fresh chat');
// //         hasChatStarted.value = false;
// //         messages.clear();
// //         currentOffset.value = 0;
// //         hasMoreMessages.value = false;
// //       }
// //     } catch (e) {
// //       print('📱 Error loading local messages: $e');
// //       hasChatStarted.value = false;
// //       messages.clear();
// //       currentOffset.value = 0;
// //       hasMoreMessages.value = false;
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Load more local messages (pagination)
// //   Future<void> loadMoreLocalMessages() async {
// //     if (isLoadingMore.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final moreMessages = _localChatService.getMessages(
// //         limit: LocalChatService.pageSize,
// //         offset: currentOffset.value,
// //       );

// //       if (moreMessages.isNotEmpty) {
// //         final newMessages = moreMessages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //         )).toList();

// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

// //         print('📱 Loaded ${newMessages.length} more local messages');
// //         print('📱 Total local messages: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more local messages available');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more local messages: $e');
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// //   Future<void> loadMoreMessages() async {
// //     // First try to load more local messages
// //     if (_localChatService.hasMoreMessages(currentOffset.value)) {
// //       await loadMoreLocalMessages();
// //       return;
// //     }

// //     // If no more local messages, fetch from server
// //     if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading more messages from server for chat ID: $chatId, offset: ${currentOffset.value}');

// //       final response = await _chatService.getChatHistory(
// //         chatId,
// //         limit: messagesPerPage,
// //         offset: currentOffset.value,
// //       );

// //       if (response.messages.isNotEmpty) {
// //         final newMessages = response.messages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
// //           text: msg.content,
// //         )).toList();

// //         // Add new messages to the beginning (older messages)
// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = newMessages.length == messagesPerPage;

// //         // Save new messages to Hive local storage
// //         for (var msg in newMessages) {
// //           final localMsg = HiveChatMessage(
// //             sender: msg.user.firstName,
// //             message: msg.text,
// //             timestamp: msg.createdAt,
// //             isUser: msg.user.id == currentUser.id,
// //           );
// //           await _localChatService.saveMessage(localMsg);
// //         }

// //         print('📱 Successfully loaded ${newMessages.length} more messages from server');
// //         print('📱 Total messages now: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more messages available on server');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more messages: $e');
// //       Get.snackbar('Error', 'Failed to load more messages.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// // // Fixed sendMessage method for ChatController
// // Future<void> sendMessage(model.ChatMessage chatMessage) async {
// //   if (!isApiHealthy.value) {
// //     Get.snackbar('Error', 'Server unavailable. Try again later.',
// //         snackPosition: SnackPosition.BOTTOM);
// //     return;
// //   }

// //   final messageId = DateTime.now().millisecondsSinceEpoch.toString();

// //   // Prevent duplicate messages
// //   if (lastSentMessageId.value == messageId) {
// //     return;
// //   }
// //   lastSentMessageId.value = messageId;

// //   final chatId = this.chatId;

// //   final sendingMessage = model.ChatMessage(
// //     user: chatMessage.user,
// //     createdAt: chatMessage.createdAt,
// //     text: chatMessage.text,
// //     medias: chatMessage.medias,
// //     status: model.MessageStatus.sending,
// //     id: messageId,
// //   );

// //   // Add user message to UI immediately
// //   messages.insert(0, sendingMessage);
// //   hasChatStarted.value = true;
// //   isBotTyping.value = true;

// //   // Save user message to local storage immediately
// //   final localMsg = HiveChatMessage(
// //     sender: chatMessage.user.firstName,
// //     message: chatMessage.text,
// //     timestamp: chatMessage.createdAt,
// //     isUser: chatMessage.user.id == currentUser.id,
// //   );
// //   await _localChatService.saveMessage(localMsg);

// //   try {
// //     final response = await _chatService.sendMessage(chatMessage.text);

// //     // Create bot response message
// //     final botMessage = model.ChatMessage(
// //       user: botUser,
// //       createdAt: DateTime.now(),
// //       text: response.response,
// //       status: model.MessageStatus.sent,
// //       deliveredAt: DateTime.now(),
// //       id: '${messageId}_bot',
// //     );

// //     // ✅ FIXED: Find the specific message by ID and update it
// //     final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //     if (messageIndex != -1) {
// //       // Update the user message status to sent
// //       messages[messageIndex] = model.ChatMessage(
// //         user: chatMessage.user,
// //         createdAt: chatMessage.createdAt,
// //         text: chatMessage.text,
// //         medias: chatMessage.medias,
// //         status: model.MessageStatus.sent,
// //         id: messageId,
// //       );
      
// //       // Insert bot response right after the user message (at index 0)
// //       messages.insert(0, botMessage);
// //     } else {
// //       // Fallback: if somehow we can't find the message, just add both
// //       messages.insert(0, botMessage);
// //     }

// //     isBotTyping.value = false;

// //     // Save bot message to local storage
// //     final localBotMsg = HiveChatMessage(
// //       sender: botUser.firstName,
// //       message: response.response,
// //       timestamp: DateTime.now(),
// //       isUser: false,
// //     );
// //     await _localChatService.saveMessage(localBotMsg);

// //     print('📱 Message sent and saved to local storage');
// //     print('📱 Bot response: ${response.response}');

// //     // Debugging: Log all messages in the list
// //     print('📱 Current messages in the list:');
// //     for (var msg in messages) {
// //       print('Message ID: ${msg.id}, Text: ${msg.text}, User: ${msg.user.firstName}');
// //     }
// //   } catch (e) {
// //     print('📱 Error sending message: $e');
    
// //     // ✅ FIXED: Find the specific message by ID and update it
// //     final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //     if (messageIndex != -1) {
// //       // Update message status to failed
// //       messages[messageIndex] = model.ChatMessage(
// //         user: chatMessage.user,
// //         createdAt: chatMessage.createdAt,
// //         text: chatMessage.text,
// //         medias: chatMessage.medias,
// //         status: model.MessageStatus.failed,
// //         id: messageId,
// //       );
      
// //       // Add funny error message
// //       final random = DateTime.now().millisecondsSinceEpoch;
// //       final funnyMessage = funnyErrorMessages[random % funnyErrorMessages.length];
// //       final botErrorMessage = model.ChatMessage(
// //         user: botUser,
// //         createdAt: DateTime.now(),
// //         text: funnyMessage,
// //         status: model.MessageStatus.sent,
// //         deliveredAt: DateTime.now(),
// //         id: '${messageId}_bot_error',
// //       );
// //       messages.insert(0, botErrorMessage);
      
// //       // Save bot error message to local storage
// //       final localBotMsg = HiveChatMessage(
// //         sender: botUser.firstName,
// //         message: funnyMessage,
// //         timestamp: DateTime.now(),
// //         isUser: false,
// //       );
// //       await _localChatService.saveMessage(localBotMsg);
// //     }
// //     isBotTyping.value = false;
// //   }
// // }

// //   Future<void> clearLocalChat() async {
// //     await _localChatService.clearMessages();
// //     print('📱 Local chat history cleared');
// //   }

// //   // Get storage information
// //   Map<String, dynamic> getStorageInfo() {
// //     return _localChatService.getStorageInfo();
// //   }

// //   // Manual cleanup - keep only last N messages
// //   Future<void> keepLastMessages(int count) async {
// //     await _localChatService.keepLastMessages(count);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Delete messages older than specific date
// //   Future<void> deleteMessagesOlderThan(DateTime date) async {
// //     await _localChatService.deleteMessagesOlderThan(date);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Search messages in local storage
// //   List<model.ChatMessage> searchLocalMessages(String query) {
// //     final searchResults = _localChatService.searchMessages(query);
// //     return searchResults.map((msg) => model.ChatMessage(
// //       user: msg.isUser ? currentUser : botUser,
// //       createdAt: msg.timestamp,
// //       text: msg.message,
// //     )).toList();
// //   }

// //   // Get storage statistics
// //   Map<String, dynamic> getStorageStats() {
// //     final info = _localChatService.getStorageInfo();
// //     return {
// //       ...info,
// //       'localMessageCount': _localChatService.getMessageCount(),
// //       'displayedMessages': messages.length,
// //     };
// //   }
// // }
// // import 'package:get/get.dart';
// // import '../../../services/chat_service.dart';
// // import '../../../services/chat_cache_service.dart';
// // import '../../../models/chat_user.dart' as model;
// // import '../../../models/chat_message.dart' as model;
// // import '../../../consts.dart';
// // import '../../../services/profile_service.dart';
// // import 'dart:async';
// // import '../../../services/local_chat_service.dart';
// // import '../../../models/chat_message.dart' as local_chat_model;
// // import '../../../models/hive_chat_message.dart';

// // class ChatController extends GetxController {
// //   final ChatService _chatService = ChatService(
// //     baseUrl: AppConstants.baseUrl,
// //     userName: AppConstants.userName, 
// //     userId: AppConstants.userId,
// //   );
// //   final ChatCacheService _chatCacheService = ChatCacheService();
// //   final ProfileService _profileService = ProfileService();
// //   final LocalChatService _localChatService = LocalChatService();

// //   final RxList<model.ChatMessage> messages = <model.ChatMessage>[].obs;
// //   final RxBool isApiHealthy = true.obs;
// //   final RxBool isLoading = false.obs;
// //   final RxBool isLoadingMore = false.obs;
// //   final RxBool hasChatStarted = false.obs;
// //   final RxBool isBotTyping = false.obs;
// //   final RxInt currentOffset = 0.obs;
// //   final RxBool hasMoreMessages = true.obs;
// //   final RxString lastSentMessageId = ''.obs;
  
// //   // ✅ Add message processing queue to handle rapid messages
// //   final RxBool _isProcessingMessage = false.obs;
// //   final List<model.ChatMessage> _messageQueue = [];

// //   late model.ChatUser currentUser;
// //   late model.ChatUser botUser;

// //   static const int messagesPerPage = 50;

// //   // Add this list at the top of the ChatController class
// //   final List<String> funnyErrorMessages = [
// //     "She is sleeping, don't disturb!",
// //     "A rat bit the wires, we are fixing it 🐀🔌",
// //     "She went to make chai, please wait ☕",
// //     "Oops! I am on a coffee break.",
// //     "Our servers are dancing, please try again soon!",
// //     "She is meditating, try again in a moment 🧘‍♀️",
// //     "The internet hamsters are running slow today.",
// //     "She is updating her diary, please wait...",
// //     "A pigeon is delivering your message, it might take a while 🕊️",
// //   ];

// //   // ✅ Get the correct chat ID - use user ID from ChatService if available, otherwise fallback
// //   String get chatId {
// //     final serviceUserId = _chatService.userId;
// //     if (serviceUserId.isNotEmpty) {
// //       return serviceUserId;
// //     }
// //     // Fallback to AppConstants.userId if ChatService doesn't have it
// //     if (AppConstants.userId.isNotEmpty) {
// //       return AppConstants.userId;
// //     }
// //     // Only use guest ID if no user ID is available
// //     return 'guest_${DateTime.now().millisecondsSinceEpoch}';
// //   }

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _initializeChatService();
// //   }

// //   Future<void> _initializeChatService() async {
// //     try {
// //       final args = Get.arguments as Map<String, dynamic>?;
// //       final characterName = args?['characterName'] as String? ?? 'Ella';
// //       final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
// //       final characterBio = args?['characterBio'] as String? ?? '';

// //       currentUser = model.ChatUser(id: chatId, firstName: AppConstants.userName);
// //       botUser = model.ChatUser(
// //         id: "bot",
// //         firstName: characterName,
// //         profileImage: characterImage,
// //       );

// //       await _initializeChat();
// //     } catch (e) {
// //       print('Error initializing chat service: $e');
// //       currentUser = model.ChatUser(id: chatId, firstName: "Guest");
// //       botUser = model.ChatUser(
// //         id: "bot",
// //         firstName: "Ella",
// //         profileImage: "assets/images/Ella-Bot.jpeg",
// //       );
// //       await _initializeChat();
// //     }
// //   }

// //   Future<void> _initializeChat() async {
// //     print('📱 Initializing chat...');
// //     await _checkApiHealth();
    
// //     // ✅ Refresh user data if we don't have a valid user ID
// //     if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
// //       print('📱 No user ID found, refreshing user data...');
// //       await _chatService.refreshUserData();
// //     }
    
// //     await loadMessages();
// //   }

// //   Future<void> _checkApiHealth() async {
// //     try {
// //       print('📱 Checking API health...');
// //       isApiHealthy.value = await _chatService.checkHealth();
// //       if (!isApiHealthy.value) {
// //         print('📱 API health check failed');
// //         Get.snackbar('Connection Error', 'Chat server is offline.',
// //             snackPosition: SnackPosition.BOTTOM);
// //       } else {
// //         print('📱 API health check passed');
// //       }
// //     } catch (e) {
// //       print('📱 API health check error: $e');
// //       isApiHealthy.value = false;
// //       Get.snackbar('Connection Error', 'Failed to connect to chat server.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     }
// //   }

// //   Future<void> loadMessages() async {
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading chat history for chat ID: $chatId');

// //       // Load recent messages with caching for instant display
// //       final localMessages = _localChatService.getRecentMessages(count: 20);
// //       if (localMessages.isNotEmpty) {
// //         print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
// //         // Convert Hive messages to UI messages
// //         messages.value = localMessages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //         )).toList();
// //         hasChatStarted.value = true;
// //         currentOffset.value = messages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);
// //         print('📱 Using cached local data - ${messages.length} messages loaded instantly');
// //         return;
// //       } else {
// //         print('📱 No local messages found - starting fresh chat');
// //         hasChatStarted.value = false;
// //         messages.clear();
// //         currentOffset.value = 0;
// //         hasMoreMessages.value = false;
// //       }
// //     } catch (e) {
// //       print('📱 Error loading local messages: $e');
// //       hasChatStarted.value = false;
// //       messages.clear();
// //       currentOffset.value = 0;
// //       hasMoreMessages.value = false;
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Load more local messages (pagination)
// //   Future<void> loadMoreLocalMessages() async {
// //     if (isLoadingMore.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final moreMessages = _localChatService.getMessages(
// //         limit: LocalChatService.pageSize,
// //         offset: currentOffset.value,
// //       );

// //       if (moreMessages.isNotEmpty) {
// //         final newMessages = moreMessages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //         )).toList();

// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

// //         print('📱 Loaded ${newMessages.length} more local messages');
// //         print('📱 Total local messages: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more local messages available');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more local messages: $e');
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// //   Future<void> loadMoreMessages() async {
// //     // First try to load more local messages
// //     if (_localChatService.hasMoreMessages(currentOffset.value)) {
// //       await loadMoreLocalMessages();
// //       return;
// //     }

// //     // If no more local messages, fetch from server
// //     if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading more messages from server for chat ID: $chatId, offset: ${currentOffset.value}');

// //       final response = await _chatService.getChatHistory(
// //         chatId,
// //         limit: messagesPerPage,
// //         offset: currentOffset.value,
// //       );

// //       if (response.messages.isNotEmpty) {
// //         final newMessages = response.messages.map((msg) => model.ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
// //           text: msg.content,
// //         )).toList();

// //         // Add new messages to the beginning (older messages)
// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = newMessages.length == messagesPerPage;

// //         // Save new messages to Hive local storage
// //         for (var msg in newMessages) {
// //           final localMsg = HiveChatMessage(
// //             sender: msg.user.firstName,
// //             message: msg.text,
// //             timestamp: msg.createdAt,
// //             isUser: msg.user.id == currentUser.id,
// //           );
// //           await _localChatService.saveMessage(localMsg);
// //         }

// //         print('📱 Successfully loaded ${newMessages.length} more messages from server');
// //         print('📱 Total messages now: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more messages available on server');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more messages: $e');
// //       Get.snackbar('Error', 'Failed to load more messages.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// //   // ✅ FIXED: Complete sendMessage method with proper message handling
// //   Future<void> sendMessage(model.ChatMessage chatMessage) async {
// //     if (!isApiHealthy.value) {
// //       Get.snackbar('Error', 'Server unavailable. Try again later.',
// //           snackPosition: SnackPosition.BOTTOM);
// //       return;
// //     }

// //     // ✅ Create unique message ID with timestamp + hash to prevent duplicates
// //     final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';

// //     // ✅ Prevent duplicate messages
// //     if (lastSentMessageId.value == messageId) {
// //       print('📱 Duplicate message detected, skipping...');
// //       return;
// //     }
// //     lastSentMessageId.value = messageId;

// //     // ✅ Add message to queue for processing
// //     _messageQueue.add(chatMessage);
// //     await _processMessageQueue();
// //   }

// //   // ✅ Process messages in queue to handle rapid consecutive messages
// //   Future<void> _processMessageQueue() async {
// //     if (_isProcessingMessage.value || _messageQueue.isEmpty) {
// //       return;
// //     }

// //     _isProcessingMessage.value = true;

// //     try {
// //       while (_messageQueue.isNotEmpty) {
// //         final chatMessage = _messageQueue.removeAt(0);
// //         await _processSingleMessage(chatMessage);
        
// //         // Small delay to prevent overwhelming the server
// //         await Future.delayed(Duration(milliseconds: 100));
// //       }
// //     } finally {
// //       _isProcessingMessage.value = false;
// //     }
// //   }

// //   // ✅ Process a single message
// //   Future<void> _processSingleMessage(model.ChatMessage chatMessage) async {
// //     final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';
// //     final chatId = this.chatId;

// //     print('📱 Processing message: ${chatMessage.text}');
// //     print('📱 Message ID: $messageId');

// //     final sendingMessage = model.ChatMessage(
// //       user: chatMessage.user,
// //       createdAt: chatMessage.createdAt,
// //       text: chatMessage.text,
// //       medias: chatMessage.medias,
// //       status: model.MessageStatus.sending,
// //       id: messageId,
// //     );

// //     // Add user message to UI immediately
// //     messages.insert(0, sendingMessage);
// //     hasChatStarted.value = true;
// //     isBotTyping.value = true;

// //     // Save user message to local storage immediately
// //     final localMsg = HiveChatMessage(
// //       sender: chatMessage.user.firstName,
// //       message: chatMessage.text,
// //       timestamp: chatMessage.createdAt,
// //       isUser: chatMessage.user.id == currentUser.id,
// //     );
// //     await _localChatService.saveMessage(localMsg);

// //     try {
// //       print('📱 Sending message to server...');
// //       final response = await _chatService.sendMessage(chatMessage.text);
// //       print('📱 Received response: ${response.response}');

// //       // Create bot response message
// //       final botMessage = model.ChatMessage(
// //         user: botUser,
// //         createdAt: DateTime.now(),
// //         text: response.response,
// //         status: model.MessageStatus.sent,
// //         deliveredAt: DateTime.now(),
// //         id: '${messageId}_bot',
// //       );

// //       // ✅ FIXED: Find the specific message by ID and update it
// //       final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //       if (messageIndex != -1) {
// //         print('📱 Found message at index: $messageIndex');
        
// //         // Update the user message status to sent
// //         messages[messageIndex] = model.ChatMessage(
// //           user: chatMessage.user,
// //           createdAt: chatMessage.createdAt,
// //           text: chatMessage.text,
// //           medias: chatMessage.medias,
// //           status: model.MessageStatus.sent,
// //           id: messageId,
// //         );
        
// //         // Insert bot response at the beginning of the list
// //         messages.insert(0, botMessage);
// //         print('📱 Bot response added successfully');
// //       } else {
// //         print('📱 Warning: Could not find message with ID: $messageId');
// //         // Fallback: if somehow we can't find the message, just add bot response
// //         messages.insert(0, botMessage);
// //       }

// //       isBotTyping.value = false;

// //       // Save bot message to local storage
// //       final localBotMsg = HiveChatMessage(
// //         sender: botUser.firstName,
// //         message: response.response,
// //         timestamp: DateTime.now(),
// //         isUser: false,
// //       );
// //       await _localChatService.saveMessage(localBotMsg);

// //       print('📱 Message sent and saved to local storage');
// //       print('📱 Bot response: ${response.response}');

// //       // Debugging: Log current messages
// //       print('📱 Current messages in the list (${messages.length} total):');
// //       for (int i = 0; i < messages.length && i < 5; i++) {
// //         final msg = messages[i];
// //         print('  [$i] ID: ${msg.id}, Text: ${msg.text.substring(0, msg.text.length > 50 ? 50 : msg.text.length)}..., User: ${msg.user.firstName}');
// //       }
// //     } catch (e) {
// //       print('📱 Error sending message: $e');
      
// //       // ✅ FIXED: Find the specific message by ID and update it
// //       final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //       if (messageIndex != -1) {
// //         // Update message status to failed
// //         messages[messageIndex] = model.ChatMessage(
// //           user: chatMessage.user,
// //           createdAt: chatMessage.createdAt,
// //           text: chatMessage.text,
// //           medias: chatMessage.medias,
// //           status: model.MessageStatus.failed,
// //           id: messageId,
// //         );
        
// //         // Add funny error message
// //         final random = DateTime.now().millisecondsSinceEpoch;
// //         final funnyMessage = funnyErrorMessages[random % funnyErrorMessages.length];
// //         final botErrorMessage = model.ChatMessage(
// //           user: botUser,
// //           createdAt: DateTime.now(),
// //           text: funnyMessage,
// //           status: model.MessageStatus.sent,
// //           deliveredAt: DateTime.now(),
// //           id: '${messageId}_bot_error',
// //         );
// //         messages.insert(0, botErrorMessage);
        
// //         // Save bot error message to local storage
// //         final localBotMsg = HiveChatMessage(
// //           sender: botUser.firstName,
// //           message: funnyMessage,
// //           timestamp: DateTime.now(),
// //           isUser: false,
// //         );
// //         await _localChatService.saveMessage(localBotMsg);
// //       }
// //       isBotTyping.value = false;
// //     }
// //   }

// //   Future<void> clearLocalChat() async {
// //     await _localChatService.clearMessages();
// //     messages.clear();
// //     _messageQueue.clear();
// //     hasChatStarted.value = false;
// //     print('📱 Local chat history cleared');
// //   }

// //   // Get storage information
// //   Map<String, dynamic> getStorageInfo() {
// //     return _localChatService.getStorageInfo();
// //   }

// //   // Manual cleanup - keep only last N messages
// //   Future<void> keepLastMessages(int count) async {
// //     await _localChatService.keepLastMessages(count);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Delete messages older than specific date
// //   Future<void> deleteMessagesOlderThan(DateTime date) async {
// //     await _localChatService.deleteMessagesOlderThan(date);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Search messages in local storage
// //   List<model.ChatMessage> searchLocalMessages(String query) {
// //     final searchResults = _localChatService.searchMessages(query);
// //     return searchResults.map((msg) => model.ChatMessage(
// //       user: msg.isUser ? currentUser : botUser,
// //       createdAt: msg.timestamp,
// //       text: msg.message,
// //     )).toList();
// //   }

// //   // Get storage statistics
// //   Map<String, dynamic> getStorageStats() {
// //     final info = _localChatService.getStorageInfo();
// //     return {
// //       ...info,
// //       'localMessageCount': _localChatService.getMessageCount(),
// //       'displayedMessages': messages.length,
// //       'queuedMessages': _messageQueue.length,
// //       'isProcessing': _isProcessingMessage.value,
// //     };
// //   }

// //   @override
// //   void onClose() {
// //     _messageQueue.clear();
// //     super.onClose();
// //   }
// // }


// // import 'package:get/get.dart';
// // import '../../../services/chat_service.dart';
// // import '../../../services/chat_cache_service.dart';
// // import '../../../models/chat_user.dart';
// // import '../../../models/chat_message.dart';
// // import '../../../models/chat_media.dart';
// // import '../../../consts.dart';
// // import '../../../services/profile_service.dart';
// // import 'dart:async';
// // import '../../../services/local_chat_service.dart';
// // import '../../../models/hive_chat_message.dart';

// // // ✅ Extension for ChatMessage copyWith method
// // extension ChatMessageExtension on ChatMessage {
// //   ChatMessage copyWith({
// //     ChatUser? user,
// //     DateTime? createdAt,
// //     String? text,
// //     List<ChatMedia>? medias,
// //     MessageStatus? status,
// //     DateTime? deliveredAt,
// //     DateTime? readAt,
// //     String? id,
// //   }) {
// //     return ChatMessage(
// //       user: user ?? this.user,
// //       createdAt: createdAt ?? this.createdAt,
// //       text: text ?? this.text,
// //       medias: medias ?? this.medias,
// //       status: status ?? this.status,
// //       deliveredAt: deliveredAt ?? this.deliveredAt,
// //       readAt: readAt ?? this.readAt,
// //       id: id ?? this.id,
// //     );
// //   }
// // }

// // class ChatController extends GetxController {
// //   final ChatService _chatService = ChatService(
// //     baseUrl: AppConstants.baseUrl,
// //     userName: AppConstants.userName, 
// //     userId: AppConstants.userId,
// //   );
// //   final ChatCacheService _chatCacheService = ChatCacheService();
// //   final ProfileService _profileService = ProfileService();
// //   final LocalChatService _localChatService = LocalChatService();

// //   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
// //   final RxBool isApiHealthy = true.obs;
// //   final RxBool isLoading = false.obs;
// //   final RxBool isLoadingMore = false.obs;
// //   final RxBool hasChatStarted = false.obs;
// //   final RxBool isBotTyping = false.obs;
// //   final RxInt currentOffset = 0.obs;
// //   final RxBool hasMoreMessages = true.obs;
// //   final RxString lastSentMessageId = ''.obs;
  
// //   // ✅ Simplified - removed complex queue system for better UX
// //   final RxBool _isProcessingMessage = false.obs;

// //   late ChatUser currentUser;
// //   late ChatUser botUser;

// //   static const int messagesPerPage = 50;

// //   // Funny error messages
// //   final List<String> funnyErrorMessages = [
// //     "She is sleeping, don't disturb!",
// //     "A rat bit the wires, we are fixing it 🐀🔌",
// //     "She went to make chai, please wait ☕",
// //     "Oops! I am on a coffee break.",
// //     "Our servers are dancing, please try again soon!",
// //     "She is meditating, try again in a moment 🧘‍♀️",
// //     "The internet hamsters are running slow today.",
// //     "She is updating her diary, please wait...",
// //     "A pigeon is delivering your message, it might take a while 🕊️",
// //   ];

// //   // ✅ Get the correct chat ID - use user ID from ChatService if available, otherwise fallback
// //   String get chatId {
// //     final serviceUserId = _chatService.userId;
// //     if (serviceUserId.isNotEmpty) {
// //       return serviceUserId;
// //     }
// //     // Fallback to AppConstants.userId if ChatService doesn't have it
// //     if (AppConstants.userId.isNotEmpty) {
// //       return AppConstants.userId;
// //     }
// //     // Only use guest ID if no user ID is available
// //     return 'guest_${DateTime.now().millisecondsSinceEpoch}';
// //   }

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _initializeChatService();
// //   }

// //   Future<void> _initializeChatService() async {
// //     try {
// //       final args = Get.arguments as Map<String, dynamic>?;
// //       final characterName = args?['characterName'] as String? ?? 'Ella';
// //       final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
// //       final characterBio = args?['characterBio'] as String? ?? '';

// //       currentUser = ChatUser(id: chatId, firstName: AppConstants.userName);
// //       botUser = ChatUser(
// //         id: "bot",
// //         firstName: characterName,
// //         profileImage: characterImage,
// //       );

// //       await _initializeChat();
// //     } catch (e) {
// //       print('Error initializing chat service: $e');
// //       currentUser = ChatUser(id: chatId, firstName: "Guest");
// //       botUser = ChatUser(
// //         id: "bot",
// //         firstName: "Ella",
// //         profileImage: "assets/images/Ella-Bot.jpeg",
// //       );
// //       await _initializeChat();
// //     }
// //   }

// //   Future<void> _initializeChat() async {
// //     print('📱 Initializing chat...');
// //     await _checkApiHealth();
    
// //     // ✅ Refresh user data if we don't have a valid user ID
// //     if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
// //       print('📱 No user ID found, refreshing user data...');
// //       await _chatService.refreshUserData();
// //     }
    
// //     await loadMessages();
// //   }

// //   Future<void> _checkApiHealth() async {
// //     try {
// //       print('📱 Checking API health...');
// //       isApiHealthy.value = await _chatService.checkHealth();
// //       if (!isApiHealthy.value) {
// //         print('📱 API health check failed');
// //         Get.snackbar('Connection Error', 'Chat server is offline.',
// //             snackPosition: SnackPosition.BOTTOM);
// //       } else {
// //         print('📱 API health check passed');
// //       }
// //     } catch (e) {
// //       print('📱 API health check error: $e');
// //       isApiHealthy.value = false;
// //       Get.snackbar('Connection Error', 'Failed to connect to chat server.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     }
// //   }

// //   Future<void> loadMessages() async {
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading chat history for chat ID: $chatId');

// //       // Load recent messages with caching for instant display
// //       final localMessages = _localChatService.getRecentMessages(count: 20);
// //       if (localMessages.isNotEmpty) {
// //         print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
// //         // Convert Hive messages to UI messages
// //         messages.value = localMessages.map((msg) => ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //           status: MessageStatus.sent,
// //           id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
// //         )).toList();
// //         hasChatStarted.value = true;
// //         currentOffset.value = messages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);
// //         print('📱 Using cached local data - ${messages.length} messages loaded instantly');
// //         return;
// //       } else {
// //         print('📱 No local messages found - starting fresh chat');
// //         hasChatStarted.value = false;
// //         messages.clear();
// //         currentOffset.value = 0;
// //         hasMoreMessages.value = false;
// //       }
// //     } catch (e) {
// //       print('📱 Error loading local messages: $e');
// //       hasChatStarted.value = false;
// //       messages.clear();
// //       currentOffset.value = 0;
// //       hasMoreMessages.value = false;
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Load more local messages (pagination)
// //   Future<void> loadMoreLocalMessages() async {
// //     if (isLoadingMore.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final moreMessages = _localChatService.getMessages(
// //         limit: LocalChatService.pageSize,
// //         offset: currentOffset.value,
// //       );

// //       if (moreMessages.isNotEmpty) {
// //         final newMessages = moreMessages.map((msg) => ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: msg.timestamp,
// //           text: msg.message,
// //           status: MessageStatus.sent,
// //           id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
// //         )).toList();

// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

// //         print('📱 Loaded ${newMessages.length} more local messages');
// //         print('📱 Total local messages: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more local messages available');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more local messages: $e');
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// //   Future<void> loadMoreMessages() async {
// //     // First try to load more local messages
// //     if (_localChatService.hasMoreMessages(currentOffset.value)) {
// //       await loadMoreLocalMessages();
// //       return;
// //     }

// //     // If no more local messages, fetch from server
// //     if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

// //     isLoadingMore.value = true;
// //     try {
// //       final chatId = this.chatId;
// //       print('📱 Loading more messages from server for chat ID: $chatId, offset: ${currentOffset.value}');

// //       final response = await _chatService.getChatHistory(
// //         chatId,
// //         limit: messagesPerPage,
// //         offset: currentOffset.value,
// //       );

// //       if (response.messages.isNotEmpty) {
// //         final newMessages = response.messages.map((msg) => ChatMessage(
// //           user: msg.isUser ? currentUser : botUser,
// //           createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
// //           text: msg.content,
// //           status: MessageStatus.sent,
// //           id: '${msg.timestamp ?? DateTime.now().millisecondsSinceEpoch}_${msg.content.hashCode}',
// //         )).toList();

// //         // Add new messages to the beginning (older messages)
// //         messages.addAll(newMessages);
// //         currentOffset.value += newMessages.length;
// //         hasMoreMessages.value = newMessages.length == messagesPerPage;

// //         // Save new messages to Hive local storage
// //         for (var msg in newMessages) {
// //           final localMsg = HiveChatMessage(
// //             sender: msg.user.firstName,
// //             message: msg.text,
// //             timestamp: msg.createdAt,
// //             isUser: msg.user.id == currentUser.id,
// //           );
// //           await _localChatService.saveMessage(localMsg);
// //         }

// //         print('📱 Successfully loaded ${newMessages.length} more messages from server');
// //         print('📱 Total messages now: ${messages.length}');
// //       } else {
// //         hasMoreMessages.value = false;
// //         print('📱 No more messages available on server');
// //       }
// //     } catch (e) {
// //       print('📱 Error loading more messages: $e');
// //       Get.snackbar('Error', 'Failed to load more messages.',
// //           snackPosition: SnackPosition.BOTTOM);
// //     } finally {
// //       isLoadingMore.value = false;
// //     }
// //   }

// //   // ✅ FIXED: Simplified sendMessage method for immediate UI response
// //   Future<void> sendMessage(ChatMessage chatMessage) async {
// //     if (!isApiHealthy.value) {
// //       Get.snackbar('Error', 'Server unavailable. Try again later.',
// //           snackPosition: SnackPosition.BOTTOM);
// //       return;
// //     }

// //     // ✅ Prevent multiple simultaneous messages
// //     if (_isProcessingMessage.value) {
// //       print('📱 Already processing a message, please wait...');
// //       return;
// //     }

// //     // ✅ Create unique message ID
// //     final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';

// //     // ✅ Prevent duplicate messages
// //     if (lastSentMessageId.value == messageId) {
// //       print('📱 Duplicate message detected, skipping...');
// //       return;
// //     }
// //     lastSentMessageId.value = messageId;

// //     // ✅ FIXED: Process message immediately instead of queueing for better UX
// //     await _processSingleMessage(chatMessage);
// //   }

// //   // ✅ FIXED: Process a single message with immediate UI updates
// //   Future<void> _processSingleMessage(ChatMessage chatMessage) async {
// //     if (_isProcessingMessage.value) return;
    
// //     _isProcessingMessage.value = true;
    
// //     try {
// //       final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';
// //       final chatId = this.chatId;

// //       print('📱 Processing message: ${chatMessage.text}');
// //       print('📱 Message ID: $messageId');

// //       final sendingMessage = ChatMessage(
// //         user: chatMessage.user,
// //         createdAt: chatMessage.createdAt,
// //         text: chatMessage.text,
// //         medias: chatMessage.medias,
// //         status: MessageStatus.sending,
// //         id: messageId,
// //       );

// //       // ✅ FIXED: Add user message to UI immediately and force UI update
// //       messages.insert(0, sendingMessage);
// //       hasChatStarted.value = true;
      
// //       // ✅ Force UI update immediately
// //       messages.refresh();
      
// //       print('📱 User message added to UI immediately');

// //       // Save user message to local storage immediately
// //       final localMsg = HiveChatMessage(
// //         sender: chatMessage.user.firstName,
// //         message: chatMessage.text,
// //         timestamp: chatMessage.createdAt,
// //         isUser: chatMessage.user.id == currentUser.id,
// //       );
// //       await _localChatService.saveMessage(localMsg);

// //       // ✅ Show bot typing indicator after user message is visible
// //       await Future.delayed(Duration(milliseconds: 100));
// //       isBotTyping.value = true;

// //       try {
// //         print('📱 Sending message to server...');
// //         final response = await _chatService.sendMessage(chatMessage.text);
// //         print('📱 Received response: ${response.response}');

// //         // ✅ FIXED: Update the existing message in-place instead of replacing
// //         final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //         if (messageIndex != -1) {
// //           // Update the user message status to sent
// //           messages[messageIndex] = messages[messageIndex].copyWith(
// //             status: MessageStatus.sent,
// //             deliveredAt: DateTime.now(),
// //           );
          
// //           // Force UI update for status change
// //           messages.refresh();
          
// //           print('📱 Updated message status to sent at index: $messageIndex');
// //         }

// //         // Create bot response message
// //         final botMessage = ChatMessage(
// //           user: botUser,
// //           createdAt: DateTime.now(),
// //           text: response.response,
// //           status: MessageStatus.sent,
// //           deliveredAt: DateTime.now(),
// //           id: '${messageId}_bot',
// //         );

// //         // ✅ Stop typing indicator before adding bot message
// //         isBotTyping.value = false;
        
// //         // ✅ Add bot response and force UI update
// //         messages.insert(0, botMessage);
// //         messages.refresh();
        
// //         print('📱 Bot response added successfully');

// //         // Save bot message to local storage
// //         final localBotMsg = HiveChatMessage(
// //           sender: botUser.firstName,
// //           message: response.response,
// //           timestamp: DateTime.now(),
// //           isUser: false,
// //         );
// //         await _localChatService.saveMessage(localBotMsg);

// //         print('📱 Message sent and saved to local storage');

// //       } catch (e) {
// //         print('📱 Error sending message: $e');
        
// //         // ✅ FIXED: Update message status to failed in-place
// //         final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //         if (messageIndex != -1) {
// //           messages[messageIndex] = messages[messageIndex].copyWith(
// //             status: MessageStatus.failed,
// //           );
          
// //           // Force UI update for failed status
// //           messages.refresh();
// //         }
        
// //         // Stop typing indicator
// //         isBotTyping.value = false;
        
// //         // Add funny error message
// //         final random = DateTime.now().millisecondsSinceEpoch;
// //         final funnyMessage = funnyErrorMessages[random % funnyErrorMessages.length];
// //         final botErrorMessage = ChatMessage(
// //           user: botUser,
// //           createdAt: DateTime.now(),
// //           text: funnyMessage,
// //           status: MessageStatus.sent,
// //           deliveredAt: DateTime.now(),
// //           id: '${messageId}_bot_error',
// //         );
        
// //         messages.insert(0, botErrorMessage);
// //         messages.refresh();
        
// //         // Save bot error message to local storage
// //         final localBotMsg = HiveChatMessage(
// //           sender: botUser.firstName,
// //           message: funnyMessage,
// //           timestamp: DateTime.now(),
// //           isUser: false,
// //         );
// //         await _localChatService.saveMessage(localBotMsg);
// //       }
// //     } finally {
// //       _isProcessingMessage.value = false;
// //     }
// //   }

// //   // ✅ Convenience method for sending text messages
// //   Future<void> sendTextMessage(String text) async {
// //     if (text.trim().isEmpty) return;
    
// //     final message = ChatMessage(
// //       user: currentUser,
// //       createdAt: DateTime.now(),
// //       text: text.trim(),
// //       status: MessageStatus.sending,
// //     );
    
// //     await sendMessage(message);
// //   }

// //   // ✅ Convenience method for sending media messages
// //   Future<void> sendMediaMessage(String text, List<ChatMedia> medias) async {
// //     if (text.trim().isEmpty && medias.isEmpty) return;
    
// //     final message = ChatMessage(
// //       user: currentUser,
// //       createdAt: DateTime.now(),
// //       text: text.trim(),
// //       medias: medias,
// //       status: MessageStatus.sending,
// //     );
    
// //     await sendMessage(message);
// //   }

// //   Future<void> clearLocalChat() async {
// //     await _localChatService.clearMessages();
// //     messages.clear();
// //     hasChatStarted.value = false;
// //     _isProcessingMessage.value = false;
// //     lastSentMessageId.value = '';
// //     print('📱 Local chat history cleared');
// //   }

// //   // Get storage information
// //   Map<String, dynamic> getStorageInfo() {
// //     return _localChatService.getStorageInfo();
// //   }

// //   // Manual cleanup - keep only last N messages
// //   Future<void> keepLastMessages(int count) async {
// //     await _localChatService.keepLastMessages(count);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Delete messages older than specific date
// //   Future<void> deleteMessagesOlderThan(DateTime date) async {
// //     await _localChatService.deleteMessagesOlderThan(date);
// //     await loadMessages(); // Reload messages after cleanup
// //   }

// //   // Search messages in local storage
// //   List<ChatMessage> searchLocalMessages(String query) {
// //     final searchResults = _localChatService.searchMessages(query);
// //     return searchResults.map((msg) => ChatMessage(
// //       user: msg.isUser ? currentUser : botUser,
// //       createdAt: msg.timestamp,
// //       text: msg.message,
// //       status: MessageStatus.sent,
// //       id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
// //     )).toList();
// //   }

// //   // Get storage statistics
// //   Map<String, dynamic> getStorageStats() {
// //     final info = _localChatService.getStorageInfo();
// //     return {
// //       ...info,
// //       'localMessageCount': _localChatService.getMessageCount(),
// //       'displayedMessages': messages.length,
// //       'isProcessing': _isProcessingMessage.value,
// //       'lastSentMessageId': lastSentMessageId.value,
// //     };
// //   }

// //   // ✅ Method to retry failed messages
// //   Future<void> retryMessage(String messageId) async {
// //     final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
// //     if (messageIndex != -1) {
// //       final failedMessage = messages[messageIndex];
// //       if (failedMessage.status == MessageStatus.failed) {
// //         // Update status to sending
// //         messages[messageIndex] = failedMessage.copyWith(
// //           status: MessageStatus.sending,
// //         );
// //         messages.refresh();
        
// //         // Retry sending
// //         await _processSingleMessage(failedMessage);
// //       }
// //     }
// //   }

// //   // ✅ Method to mark messages as read
// //   void markMessagesAsRead() {
// //     bool hasUnreadMessages = false;
    
// //     for (int i = 0; i < messages.length; i++) {
// //       if (messages[i].user.id != currentUser.id && 
// //           messages[i].status != MessageStatus.read) {
// //         messages[i] = messages[i].copyWith(
// //           status: MessageStatus.read,
// //           readAt: DateTime.now(),
// //         );
// //         hasUnreadMessages = true;
// //       }
// //     }
    
// //     if (hasUnreadMessages) {
// //       messages.refresh();
// //     }
// //   }

// //   @override
// //   void onClose() {
// //     _isProcessingMessage.value = false;
// //     super.onClose();
// //   }
// // }
// import 'package:get/get.dart';
// import '../../../services/chat_service.dart';
// import '../../../services/chat_cache_service.dart';
// import '../../../models/chat_user.dart';
// import '../../../models/chat_message.dart';
// import '../../../models/chat_media.dart';
// import '../../../consts.dart';
// import '../../../services/profile_service.dart';
// import 'dart:async';
// import '../../../services/local_chat_service.dart';
// import '../../../models/hive_chat_message.dart';
// import 'dart:collection';

// // ✅ Extension for ChatMessage copyWith method
// extension ChatMessageExtension on ChatMessage {
//   ChatMessage copyWith({
//     ChatUser? user,
//     DateTime? createdAt,
//     String? text,
//     List<ChatMedia>? medias,
//     MessageStatus? status,
//     DateTime? deliveredAt,
//     DateTime? readAt,
//     String? id,
//   }) {
//     return ChatMessage(
//       user: user ?? this.user,
//       createdAt: createdAt ?? this.createdAt,
//       text: text ?? this.text,
//       medias: medias ?? this.medias,
//       status: status ?? this.status,
//       deliveredAt: deliveredAt ?? this.deliveredAt,
//       readAt: readAt ?? this.readAt,
//       id: id ?? this.id,
//     );
//   }
// }

// class ChatController extends GetxController {
//   final ChatService _chatService = ChatService(
//     baseUrl: AppConstants.baseUrl,
//     userName: AppConstants.userName, 
//     userId: AppConstants.userId,
//   );
//   final ChatCacheService _chatCacheService = ChatCacheService();
//   final ProfileService _profileService = ProfileService();
//   final LocalChatService _localChatService = LocalChatService();

//   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
//   final RxBool isApiHealthy = true.obs;
//   final RxBool isLoading = false.obs;
//   final RxBool isLoadingMore = false.obs;
//   final RxBool hasChatStarted = false.obs;
//   final RxBool isBotTyping = false.obs;
//   final RxInt currentOffset = 0.obs;
//   final RxBool hasMoreMessages = true.obs;
//   final RxString lastSentMessageId = ''.obs;
  
//   // ✅ NEW: Message queue system for handling multiple messages
//   final Queue<ChatMessage> _messageQueue = Queue<ChatMessage>();
//   final RxBool _isProcessingQueue = false.obs;
//   final RxInt _queueSize = 0.obs;

//   late ChatUser currentUser;
//   late ChatUser botUser;

//   static const int messagesPerPage = 50;

//   // Funny error messages
//   final List<String> funnyErrorMessages = [
//     "She is sleeping, don't disturb!",
//     "A rat bit the wires, we are fixing it 🐀🔌",
//     "She went to make chai, please wait ☕",
//     "Oops! I am on a coffee break.",
//     "Our servers are dancing, please try again soon!",
//     "She is meditating, try again in a moment 🧘‍♀️",
//     "The internet hamsters are running slow today.",
//     "She is updating her diary, please wait...",
//     "A pigeon is delivering your message, it might take a while 🕊️",
//   ];

//   // ✅ Get the correct chat ID
//   String get chatId {
//     final serviceUserId = _chatService.userId;
//     if (serviceUserId.isNotEmpty) {
//       return serviceUserId;
//     }
//     if (AppConstants.userId.isNotEmpty) {
//       return AppConstants.userId;
//     }
//     return 'guest_${DateTime.now().millisecondsSinceEpoch}';
//   }

//   // ✅ Getter for queue size (for UI to show pending messages)
//   int get queueSize => _queueSize.value;
//   bool get isProcessingQueue => _isProcessingQueue.value;

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeChatService();
//   }

//   Future<void> _initializeChatService() async {
//     try {
//       final args = Get.arguments as Map<String, dynamic>?;
//       final characterName = args?['characterName'] as String? ?? 'Ella';
//       final characterImage = args?['characterImage'] as String? ?? 'assets/images/Ella-Bot.jpeg';
//       final characterBio = args?['characterBio'] as String? ?? '';

//       currentUser = ChatUser(id: chatId, firstName: AppConstants.userName);
//       botUser = ChatUser(
//         id: "bot",
//         firstName: characterName,
//         profileImage: characterImage,
//       );

//       await _initializeChat();
//     } catch (e) {
//       print('Error initializing chat service: $e');
//       currentUser = ChatUser(id: chatId, firstName: "Guest");
//       botUser = ChatUser(
//         id: "bot",
//         firstName: "Ella",
//         profileImage: "assets/images/Ella-Bot.jpeg",
//       );
//       await _initializeChat();
//     }
//   }

//   Future<void> _initializeChat() async {
//     print('📱 Initializing chat...');
//     await _checkApiHealth();
    
//     if (_chatService.userId.isEmpty && AppConstants.userId.isEmpty) {
//       print('📱 No user ID found, refreshing user data...');
//       await _chatService.refreshUserData();
//     }
    
//     await loadMessages();
//   }

//   Future<void> _checkApiHealth() async {
//     try {
//       print('📱 Checking API health...');
//       isApiHealthy.value = await _chatService.checkHealth();
//       if (!isApiHealthy.value) {
//         print('📱 API health check failed');
//         Get.snackbar('Connection Error', 'Chat server is offline.',
//             snackPosition: SnackPosition.BOTTOM);
//       } else {
//         print('📱 API health check passed');
//       }
//     } catch (e) {
//       print('📱 API health check error: $e');
//       isApiHealthy.value = false;
//       Get.snackbar('Connection Error', 'Failed to connect to chat server.',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   Future<void> loadMessages() async {
//     try {
//       final chatId = this.chatId;
//       print('📱 Loading chat history for chat ID: $chatId');

//       final localMessages = _localChatService.getRecentMessages(count: 20);
//       if (localMessages.isNotEmpty) {
//         print('📱 Loaded ${localMessages.length} recent messages from local Hive storage (cached)');
//         messages.value = localMessages.map((msg) => ChatMessage(
//           user: msg.isUser ? currentUser : botUser,
//           createdAt: msg.timestamp,
//           text: msg.message,
//           status: MessageStatus.sent,
//           id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
//         )).toList();
//         hasChatStarted.value = true;
//         currentOffset.value = messages.length;
//         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);
//         print('📱 Using cached local data - ${messages.length} messages loaded instantly');
//         return;
//       } else {
//         print('📱 No local messages found - starting fresh chat');
//         hasChatStarted.value = false;
//         messages.clear();
//         currentOffset.value = 0;
//         hasMoreMessages.value = false;
//       }
//     } catch (e) {
//       print('📱 Error loading local messages: $e');
//       hasChatStarted.value = false;
//       messages.clear();
//       currentOffset.value = 0;
//       hasMoreMessages.value = false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadMoreLocalMessages() async {
//     if (isLoadingMore.value) return;

//     isLoadingMore.value = true;
//     try {
//       final moreMessages = _localChatService.getMessages(
//         limit: LocalChatService.pageSize,
//         offset: currentOffset.value,
//       );

//       if (moreMessages.isNotEmpty) {
//         final newMessages = moreMessages.map((msg) => ChatMessage(
//           user: msg.isUser ? currentUser : botUser,
//           createdAt: msg.timestamp,
//           text: msg.message,
//           status: MessageStatus.sent,
//           id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
//         )).toList();

//         messages.addAll(newMessages);
//         currentOffset.value += newMessages.length;
//         hasMoreMessages.value = _localChatService.hasMoreMessages(currentOffset.value);

//         print('📱 Loaded ${newMessages.length} more local messages');
//         print('📱 Total local messages: ${messages.length}');
//       } else {
//         hasMoreMessages.value = false;
//         print('📱 No more local messages available');
//       }
//     } catch (e) {
//       print('📱 Error loading more local messages: $e');
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }

//   Future<void> loadMoreMessages() async {
//     if (_localChatService.hasMoreMessages(currentOffset.value)) {
//       await loadMoreLocalMessages();
//       return;
//     }

//     if (!isApiHealthy.value || isLoadingMore.value || !hasMoreMessages.value) return;

//     isLoadingMore.value = true;
//     try {
//       final chatId = this.chatId;
//       print('📱 Loading more messages from server for chat ID: $chatId, offset: ${currentOffset.value}');

//       final response = await _chatService.getChatHistory(
//         chatId,
//         limit: messagesPerPage,
//         offset: currentOffset.value,
//       );

//       if (response.messages.isNotEmpty) {
//         final newMessages = response.messages.map((msg) => ChatMessage(
//           user: msg.isUser ? currentUser : botUser,
//           createdAt: DateTime.parse(msg.timestamp ?? DateTime.now().toIso8601String()),
//           text: msg.content,
//           status: MessageStatus.sent,
//           id: '${msg.timestamp ?? DateTime.now().millisecondsSinceEpoch}_${msg.content.hashCode}',
//         )).toList();

//         messages.addAll(newMessages);
//         currentOffset.value += newMessages.length;
//         hasMoreMessages.value = newMessages.length == messagesPerPage;

//         for (var msg in newMessages) {
//           final localMsg = HiveChatMessage(
//             sender: msg.user.firstName,
//             message: msg.text,
//             timestamp: msg.createdAt,
//             isUser: msg.user.id == currentUser.id,
//           );
//           await _localChatService.saveMessage(localMsg);
//         }

//         print('📱 Successfully loaded ${newMessages.length} more messages from server');
//         print('📱 Total messages now: ${messages.length}');
//       } else {
//         hasMoreMessages.value = false;
//         print('📱 No more messages available on server');
//       }
//     } catch (e) {
//       print('📱 Error loading more messages: $e');
//       Get.snackbar('Error', 'Failed to load more messages.',
//           snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }

//   // ✅ NEW: Enhanced sendMessage method with queue system
//   Future<void> sendMessage(ChatMessage chatMessage) async {
//     if (!isApiHealthy.value) {
//       Get.snackbar('Error', 'Server unavailable. Try again later.',
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     if (chatMessage.text.trim().isEmpty) {
//       print('📱 Empty message, skipping...');
//       return;
//     }

//     // ✅ Create unique message ID
//     final messageId = '${DateTime.now().millisecondsSinceEpoch}_${chatMessage.text.hashCode}';
    
//     // ✅ Prevent exact duplicate messages (same text within 1 second)
//     if (lastSentMessageId.value == messageId) {
//       print('📱 Duplicate message detected, skipping...');
//       return;
//     }
//     lastSentMessageId.value = messageId;

//     // ✅ Create message with unique ID
//     final messageWithId = chatMessage.copyWith(id: messageId);

//     // ✅ Add message to UI immediately
//     final sendingMessage = messageWithId.copyWith(status: MessageStatus.sending);
//     messages.insert(0, sendingMessage);
//     hasChatStarted.value = true;
//     messages.refresh();
    
//     print('📱 Message added to UI: ${chatMessage.text}');
    
//     // Save user message to local storage immediately
//     final localMsg = HiveChatMessage(
//       sender: chatMessage.user.firstName,
//       message: chatMessage.text,
//       timestamp: chatMessage.createdAt,
//       isUser: chatMessage.user.id == currentUser.id,
//     );
//     await _localChatService.saveMessage(localMsg);

//     // ✅ Add to queue for processing
//     _messageQueue.add(messageWithId);
//     _queueSize.value = _messageQueue.length;
//     print('📱 Message added to queue. Queue size: ${_queueSize.value}');

//     // ✅ Start processing queue if not already processing
//     if (!_isProcessingQueue.value) {
//       _processMessageQueue();
//     }
//   }

//   // ✅ NEW: Process message queue one by one
//   Future<void> _processMessageQueue() async {
//     if (_isProcessingQueue.value) return;
    
//     _isProcessingQueue.value = true;
//     print('📱 Started processing message queue...');

//     while (_messageQueue.isNotEmpty) {
//       final message = _messageQueue.removeFirst();
//       _queueSize.value = _messageQueue.length;
      
//       await _processSingleMessage(message);
      
//       // ✅ Small delay between messages to avoid overwhelming the server
//       if (_messageQueue.isNotEmpty) {
//         await Future.delayed(Duration(milliseconds: 300));
//       }
//     }

//     _isProcessingQueue.value = false;
//     print('📱 Finished processing message queue');
//   }

//   // ✅ ENHANCED: Process a single message
//   Future<void> _processSingleMessage(ChatMessage chatMessage) async {
//     final messageId = chatMessage.id;
    
//     try {
//       print('📱 Processing message: ${chatMessage.text}');
//       print('📱 Message ID: $messageId');

//       // ✅ Show bot typing indicator
//       isBotTyping.value = true;

//       try {
//         print('📱 Sending message to server...');
//         final response = await _chatService.sendMessage(chatMessage.text);
//         print('📱 Received response: ${response.response}');

//         // ✅ Update the user message status to sent
//         final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
//         if (messageIndex != -1) {
//           messages[messageIndex] = messages[messageIndex].copyWith(
//             status: MessageStatus.sent,
//             deliveredAt: DateTime.now(),
//           );
//           messages.refresh();
//           print('📱 Updated message status to sent at index: $messageIndex');
//         }

//         // Create bot response message
//         final botMessage = ChatMessage(
//           user: botUser,
//           createdAt: DateTime.now(),
//           text: response.response,
//           status: MessageStatus.sent,
//           deliveredAt: DateTime.now(),
//           id: '${messageId}_bot',
//         );

//         // ✅ Stop typing indicator and add bot response
//         isBotTyping.value = false;
//         messages.insert(0, botMessage);
//         messages.refresh();
        
//         print('📱 Bot response added successfully');

//         // Save bot message to local storage
//         final localBotMsg = HiveChatMessage(
//           sender: botUser.firstName,
//           message: response.response,
//           timestamp: DateTime.now(),
//           isUser: false,
//         );
//         await _localChatService.saveMessage(localBotMsg);

//         print('📱 Message sent and saved to local storage');

//       } catch (e) {
//         print('📱 Error sending message: $e');
        
//         // ✅ Update message status to failed
//         final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
//         if (messageIndex != -1) {
//           messages[messageIndex] = messages[messageIndex].copyWith(
//             status: MessageStatus.failed,
//           );
//           messages.refresh();
//         }
        
//         // Stop typing indicator
//         isBotTyping.value = false;
        
//         // Add funny error message
//         final random = DateTime.now().millisecondsSinceEpoch;
//         final funnyMessage = funnyErrorMessages[random % funnyErrorMessages.length];
//         final botErrorMessage = ChatMessage(
//           user: botUser,
//           createdAt: DateTime.now(),
//           text: funnyMessage,
//           status: MessageStatus.sent,
//           deliveredAt: DateTime.now(),
//           id: '${messageId}_bot_error',
//         );
        
//         messages.insert(0, botErrorMessage);
//         messages.refresh();
        
//         // Save bot error message to local storage
//         final localBotMsg = HiveChatMessage(
//           sender: botUser.firstName,
//           message: funnyMessage,
//           timestamp: DateTime.now(),
//           isUser: false,
//         );
//         await _localChatService.saveMessage(localBotMsg);
//       }
//     } catch (e) {
//       print('📱 Critical error processing message: $e');
//       isBotTyping.value = false;
//     }
//   }

//   // ✅ Convenience method for sending text messages
//   Future<void> sendTextMessage(String text) async {
//     if (text.trim().isEmpty) return;
    
//     final message = ChatMessage(
//       user: currentUser,
//       createdAt: DateTime.now(),
//       text: text.trim(),
//       status: MessageStatus.sending,
//     );
    
//     await sendMessage(message);
//   }

//   // ✅ Convenience method for sending media messages
//   Future<void> sendMediaMessage(String text, List<ChatMedia> medias) async {
//     if (text.trim().isEmpty && medias.isEmpty) return;
    
//     final message = ChatMessage(
//       user: currentUser,
//       createdAt: DateTime.now(),
//       text: text.trim(),
//       medias: medias,
//       status: MessageStatus.sending,
//     );
    
//     await sendMessage(message);
//   }

//   // ✅ NEW: Send multiple messages at once
//   Future<void> sendMultipleMessages(List<String> messages) async {
//     for (String messageText in messages) {
//       if (messageText.trim().isNotEmpty) {
//         await sendTextMessage(messageText);
//       }
//     }
//   }

//   // ✅ NEW: Clear the message queue (useful for canceling pending messages)
//   void clearMessageQueue() {
//     _messageQueue.clear();
//     _queueSize.value = 0;
//     print('📱 Message queue cleared');
//   }

//   Future<void> clearLocalChat() async {
//     await _localChatService.clearMessages();
//     messages.clear();
//     hasChatStarted.value = false;
//     clearMessageQueue(); // Also clear any pending messages
//     lastSentMessageId.value = '';
//     print('📱 Local chat history cleared');
//   }

//   // Get storage information
//   Map<String, dynamic> getStorageInfo() {
//     return _localChatService.getStorageInfo();
//   }

//   // Manual cleanup - keep only last N messages
//   Future<void> keepLastMessages(int count) async {
//     await _localChatService.keepLastMessages(count);
//     await loadMessages();
//   }

//   // Delete messages older than specific date
//   Future<void> deleteMessagesOlderThan(DateTime date) async {
//     await _localChatService.deleteMessagesOlderThan(date);
//     await loadMessages();
//   }

//   // Search messages in local storage
//   List<ChatMessage> searchLocalMessages(String query) {
//     final searchResults = _localChatService.searchMessages(query);
//     return searchResults.map((msg) => ChatMessage(
//       user: msg.isUser ? currentUser : botUser,
//       createdAt: msg.timestamp,
//       text: msg.message,
//       status: MessageStatus.sent,
//       id: '${msg.timestamp.millisecondsSinceEpoch}_${msg.message.hashCode}',
//     )).toList();
//   }

//   // Get storage statistics
//   Map<String, dynamic> getStorageStats() {
//     final info = _localChatService.getStorageInfo();
//     return {
//       ...info,
//       'localMessageCount': _localChatService.getMessageCount(),
//       'displayedMessages': messages.length,
//       'queueSize': _queueSize.value,
//       'isProcessingQueue': _isProcessingQueue.value,
//       'lastSentMessageId': lastSentMessageId.value,
//     };
//   }

//   // ✅ Method to retry failed messages
//   Future<void> retryMessage(String messageId) async {
//     final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
//     if (messageIndex != -1) {
//       final failedMessage = messages[messageIndex];
//       if (failedMessage.status == MessageStatus.failed) {
//         // Update status to sending
//         messages[messageIndex] = failedMessage.copyWith(
//           status: MessageStatus.sending,
//         );
//         messages.refresh();
        
//         // Add back to queue for retry
//         _messageQueue.add(failedMessage);
//         _queueSize.value = _messageQueue.length;
        
//         // Start processing if not already processing
//         if (!_isProcessingQueue.value) {
//           _processMessageQueue();
//         }
//       }
//     }
//   }

//   // ✅ Method to mark messages as read
//   void markMessagesAsRead() {
//     bool hasUnreadMessages = false;
    
//     for (int i = 0; i < messages.length; i++) {
//       if (messages[i].user.id != currentUser.id && 
//           messages[i].status != MessageStatus.read) {
//         messages[i] = messages[i].copyWith(
//           status: MessageStatus.read,
//           readAt: DateTime.now(),
//         );
//         hasUnreadMessages = true;
//       }
//     }
    
//     if (hasUnreadMessages) {
//       messages.refresh();
//     }
//   }

//   @override
//   void onClose() {
//     clearMessageQueue();
//     _isProcessingQueue.value = false;
//     super.onClose();
//   }
// }
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
  
  // ✅ Message queue system for handling multiple messages
  final Queue<ChatMessage> _messageQueue = Queue<ChatMessage>();
  final RxBool _isProcessingQueue = false.obs;
  final RxInt _queueSize = 0.obs;
  
  // ✅ NEW: Retry and rate limiting system
  final RxBool _isServerDown = false.obs;
  final RxInt _consecutiveFailures = 0.obs;
  final RxInt _currentRetryDelay = 1000.obs; // Start with 1 second
  Timer? _retryTimer;
  Timer? _healthCheckTimer;
  
  // ✅ Rate limiting to prevent overwhelming the server
  DateTime? _lastMessageSent;
  static const int MIN_MESSAGE_INTERVAL_MS = 500; // Minimum 500ms between messages
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const int MAX_RETRY_DELAY_MS = 30000; // Max 30 seconds
  static const int HEALTH_CHECK_INTERVAL_MS = 10000; // Check every 10 seconds when down

  late ChatUser currentUser;
  late ChatUser botUser;

  static const int messagesPerPage = 50;

  // Enhanced error messages with server status
  final List<String> serverDownMessages = [
    "The server is taking a quick nap 😴 Your message will be sent when it wakes up!",
    "Server overload detected! 🚨 Don't worry, your message is safe in the queue.",
    "The hamsters powering our servers need a break 🐹 Retrying automatically...",
    "Server maintenance in progress 🔧 Your message will be delivered shortly!",
    "Traffic jam on the server highway 🚗💨 Please hold on!",
  ];

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

  // ✅ Getters for UI state
  int get queueSize => _queueSize.value;
  bool get isProcessingQueue => _isProcessingQueue.value;
  bool get isServerDown => _isServerDown.value;
  int get consecutiveFailures => _consecutiveFailures.value;

  @override
  void onInit() {
    super.onInit();
    _initializeChatService();
    _startPeriodicHealthCheck();
  }

  // ✅ NEW: Periodic health check when server is down
  void _startPeriodicHealthCheck() {
    _healthCheckTimer = Timer.periodic(
      Duration(milliseconds: HEALTH_CHECK_INTERVAL_MS),
      (timer) async {
        if (_isServerDown.value) {
          await _checkApiHealth();
          if (isApiHealthy.value) {
            _onServerRecovered();
          }
        }
      },
    );
  }

  // ✅ NEW: Handle server recovery
  void _onServerRecovered() {
    print('📱 🎉 Server recovered! Processing queued messages...');
    _isServerDown.value = false;
    _consecutiveFailures.value = 0;
    _currentRetryDelay.value = 1000;
    
    Get.snackbar(
      'Connection Restored! 🎉',
      'Server is back online. Processing your messages...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      //colorText: Get.theme.onPrimary,
    );
    
    // Resume processing queue
    if (!_isProcessingQueue.value && _messageQueue.isNotEmpty) {
      _processMessageQueue();
    }
  }

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
        _handleServerDown();
      } else {
        print('📱 API health check passed');
        if (_isServerDown.value) {
          _onServerRecovered();
        }
      }
    } catch (e) {
      print('📱 API health check error: $e');
      isApiHealthy.value = false;
      _handleServerDown();
    }
  }

  // ✅ NEW: Handle server down state
  void _handleServerDown() {
    print('📱 Server is down or overloaded');
    _isServerDown.value = true;
    _consecutiveFailures.value++;
    
    if (_consecutiveFailures.value == 1) {
      // First failure - show immediate feedback
      Get.snackbar(
        'Server Overloaded 🚨',
        'Don\'t worry! Your messages are safely queued and will be sent when the server recovers.',
        snackPosition: SnackPosition.BOTTOM,
         //backgroundColor: Colors.grey[300],

       // colorText: Get.theme.onErrorContainer,
        duration: Duration(seconds: 5),
      );
    }
  }

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
        print('📱 Rate limiting: Too fast! Waiting ${MIN_MESSAGE_INTERVAL_MS - timeSinceLastMessage}ms');
        await Future.delayed(Duration(milliseconds: MIN_MESSAGE_INTERVAL_MS - timeSinceLastMessage));
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
      status: _isServerDown.value ? MessageStatus.failed : MessageStatus.sending
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

    // ✅ Add to queue for processing
    _messageQueue.add(messageWithId);
    _queueSize.value = _messageQueue.length;
    print('📱 Message added to queue. Queue size: ${_queueSize.value}');

    // ✅ Show server status message if server is down
    if (_isServerDown.value) {
      final random = Random();
      final statusMessage = serverDownMessages[random.nextInt(serverDownMessages.length)];
      final statusBotMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: statusMessage,
        status: MessageStatus.sent,
        deliveredAt: DateTime.now(),
        id: '${messageId}_status',
      );
      
      messages.insert(0, statusBotMessage);
      messages.refresh();
    }

    // ✅ Start processing queue if not already processing
    if (!_isProcessingQueue.value) {
      _processMessageQueue();
    }
  }

  // ✅ Enhanced message queue processing with exponential backoff
  Future<void> _processMessageQueue() async {
    if (_isProcessingQueue.value) return;
    
    _isProcessingQueue.value = true;
    print('📱 Started processing message queue...');

    while (_messageQueue.isNotEmpty) {
      // ✅ Skip processing if server is down
      if (_isServerDown.value) {
        print('📱 Server is down, pausing queue processing...');
        break;
      }

      final message = _messageQueue.removeFirst();
      _queueSize.value = _messageQueue.length;
      
      final success = await _processSingleMessage(message);
      
      if (!success) {
        // ✅ Re-add message to front of queue for retry
        _messageQueue.addFirst(message);
        _queueSize.value = _messageQueue.length;
        
        // ✅ Exponential backoff
        await Future.delayed(Duration(milliseconds: _currentRetryDelay.value));
        _currentRetryDelay.value = min(_currentRetryDelay.value * 2, MAX_RETRY_DELAY_MS);
        break;
      } else {
        // ✅ Reset retry delay on success
        _currentRetryDelay.value = 1000;
      }
      
      // ✅ Delay between successful messages
      if (_messageQueue.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: MIN_MESSAGE_INTERVAL_MS));
      }
    }

    _isProcessingQueue.value = false;
    print('📱 Queue processing paused/finished. Remaining: ${_messageQueue.length}');
  }

  // ✅ Enhanced single message processing with retry logic
  Future<bool> _processSingleMessage(ChatMessage chatMessage) async {
    final messageId = chatMessage.id;
    
    try {
      print('📱 Processing message: ${chatMessage.text}');

      // ✅ Check server health before sending
      if (!isApiHealthy.value) {
        await _checkApiHealth();
        if (!isApiHealthy.value) {
          return false; // Server still down
        }
      }

      // ✅ Show bot typing indicator
      isBotTyping.value = true;

      try {
        print('📱 Sending message to server...');
        final response = await _chatService.sendMessage(chatMessage.text);
        print('📱 Received response: ${response.response}');

        // ✅ Reset failure count on success
        _consecutiveFailures.value = 0;

        // ✅ Update the user message status to sent
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

        // ✅ Stop typing indicator and add bot response
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
        return true;

      } catch (e) {
        print('📱 Error sending message: $e');
        
        // ✅ Check if it's a server error (502, 503, etc.)
        if (e.toString().contains('502') || 
            e.toString().contains('503') || 
            e.toString().contains('500') ||
            e.toString().contains('timeout')) {
          _handleServerDown();
          return false; // Will retry
        }
        
        // ✅ For other errors, mark as failed
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          messages[messageIndex] = messages[messageIndex].copyWith(
            status: MessageStatus.failed,
          );
          messages.refresh();
        }
        
        // Stop typing indicator
        isBotTyping.value = false;
        
        // Add error message
        final random = Random();
        final errorMessage = funnyErrorMessages[random.nextInt(funnyErrorMessages.length)];
        final botErrorMessage = ChatMessage(
          user: botUser,
          createdAt: DateTime.now(),
          text: errorMessage,
          status: MessageStatus.sent,
          deliveredAt: DateTime.now(),
          id: '${messageId}_bot_error',
        );
        
        messages.insert(0, botErrorMessage);
        messages.refresh();
        
        // Save bot error message to local storage
        final localBotMsg = HiveChatMessage(
          sender: botUser.firstName,
          message: errorMessage,
          timestamp: DateTime.now(),
          isUser: false,
        );
        await _localChatService.saveMessage(localBotMsg);
        
        return true; // Don't retry for non-server errors
      }
    } catch (e) {
      print('📱 Critical error processing message: $e');
      isBotTyping.value = false;
      return false;
    } finally {
      isBotTyping.value = false;
    }
  }

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

  // ✅ NEW: Force retry all failed messages
  Future<void> retryAllFailedMessages() async {
    print('📱 Retrying all failed messages...');
    
    // Find all failed messages
    final failedMessages = messages.where((msg) => 
      msg.status == MessageStatus.failed && 
      msg.user.id == currentUser.id
    ).toList();
    
    if (failedMessages.isEmpty) {
      Get.snackbar('Info', 'No failed messages to retry.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    // Add failed messages back to queue
    for (var msg in failedMessages.reversed) {
      _messageQueue.addFirst(msg);
    }
    _queueSize.value = _messageQueue.length;
    
    // Reset server state and try again
    _isServerDown.value = false;
    _consecutiveFailures.value = 0;
    
    // Start processing
    if (!_isProcessingQueue.value) {
      _processMessageQueue();
    }
    
    Get.snackbar('Retrying...', 'Attempting to resend ${failedMessages.length} failed messages',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ✅ NEW: Clear the message queue
  void clearMessageQueue() {
    _messageQueue.clear();
    _queueSize.value = 0;
    print('📱 Message queue cleared');
  }

  Future<void> clearLocalChat() async {
    await _localChatService.clearMessages();
    messages.clear();
    hasChatStarted.value = false;
    clearMessageQueue();
    lastSentMessageId.value = '';
    _consecutiveFailures.value = 0;
    _isServerDown.value = false;
    print('📱 Local chat history cleared');
  }

  Map<String, dynamic> getStorageStats() {
    final info = _localChatService.getStorageInfo();
    return {
      ...info,
      'localMessageCount': _localChatService.getMessageCount(),
      'displayedMessages': messages.length,
      'queueSize': _queueSize.value,
      'isProcessingQueue': _isProcessingQueue.value,
      'isServerDown': _isServerDown.value,
      'consecutiveFailures': _consecutiveFailures.value,
      'currentRetryDelay': _currentRetryDelay.value,
    };
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    _healthCheckTimer?.cancel();
    clearMessageQueue();
    _isProcessingQueue.value = false;
    super.onClose();
  }
}