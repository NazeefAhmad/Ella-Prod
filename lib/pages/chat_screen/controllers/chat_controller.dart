import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_cache_service.dart';
import '../../../models/chat_user.dart' as model;
import '../../../models/chat_message.dart' as model;
import '../../../models/chat_media.dart' as model;
import '../../../consts.dart';
import '../../../services/profile_service.dart';
import 'dart:async';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService(
    baseUrl: AppConstants.baseUrl,
    userId: AppConstants.userId,
    userName: AppConstants.userName,
  );
  final ChatCacheService _chatCacheService = ChatCacheService();
  final ProfileService _profileService = ProfileService();

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

      currentUser = model.ChatUser(id: AppConstants.userId, firstName: AppConstants.userName);
      botUser = model.ChatUser(
        id: "bot",
        firstName: characterName,
        profileImage: characterImage,
      );

      await _initializeChat();
    } catch (e) {
      print('Error initializing chat service: $e');
      currentUser = model.ChatUser(id: "Guest", firstName: "Guest");
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
      final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      print('📱 Loading chat history for chat ID: $chatId');

      final isRefresh = currentOffset.value == 0;

      if (isRefresh && isApiHealthy.value) {
        print('📱 Refreshing messages from server...');
        await _refreshFromServer(chatId);
        return;
      }

      print('📱 Loading from cache...');
      final cachedMessages = await _chatCacheService.getMessages(chatId);
      
      if (cachedMessages.isNotEmpty) {
        print('📱 Found ${cachedMessages.length} messages in cache');
        messages.value = cachedMessages;
        hasChatStarted.value = true;
        currentOffset.value = messages.length;
        hasMoreMessages.value = messages.length >= messagesPerPage;
        
        if (isApiHealthy.value) {
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
        if (isApiHealthy.value) {
          await _refreshFromServer(chatId);
        } else {
          hasChatStarted.value = false;
          messages.clear();
          currentOffset.value = 0;
          hasMoreMessages.value = false;
        }
      }
    } catch (e) {
      print('📱 Error loading messages: $e');
      hasChatStarted.value = false;
      messages.clear();
      currentOffset.value = 0;
      hasMoreMessages.value = false;
      Get.snackbar('Info', 'Starting a new chat.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshFromServer(String chatId) async {
    try {
      isLoading.value = true;
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

        messages.value = newMessages;
        hasChatStarted.value = messages.isNotEmpty;
        currentOffset.value = messages.length;
        hasMoreMessages.value = messages.length >= messagesPerPage;

        _chatCacheService.saveMessages(chatId, newMessages).then((_) {
          print('📱 Successfully updated cache with ${newMessages.length} messages');
        });
        print('📱 Successfully updated with ${messages.length} messages from server');
      } else {
        print('📱 No messages found from server');
        if (messages.isEmpty) {
          hasChatStarted.value = false;
          messages.clear();
          currentOffset.value = 0;
          hasMoreMessages.value = false;
        }
      }
    } catch (e) {
      print('📱 Error fetching from server: $e');
      Get.snackbar('Error', 'Failed to refresh messages.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (!isApiHealthy.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      print('📱 Loading more messages for chat ID: $chatId, offset: ${currentOffset.value}');

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

        messages.addAll(newMessages);
        currentOffset.value += newMessages.length;
        hasMoreMessages.value = newMessages.length == messagesPerPage;

        _chatCacheService.saveMessages(chatId, messages).then((_) {
          print('📱 Successfully cached ${messages.length} messages');
        });
        print('📱 Successfully loaded ${newMessages.length} more messages from server');
      } else {
        hasMoreMessages.value = false;
        print('📱 No more messages to load');
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

    final chatId = AppConstants.userId.isNotEmpty ? AppConstants.userId : 'guest_${DateTime.now().millisecondsSinceEpoch}';

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

    try {
      String responseText;
      if (chatMessage.medias != null && chatMessage.medias!.isNotEmpty) {
        final media = chatMessage.medias!.first;
        final response = await _chatService.sendMediaMessage(
          chatMessage.text,
          media.url,
          media.type.toString(),
        );
        responseText = response.response;
      } else {
        final response = await _chatService.sendMessage(chatMessage.text);
        responseText = response.response;
      }

      final sentMessage = model.ChatMessage(
        user: chatMessage.user,
        createdAt: chatMessage.createdAt,
        text: chatMessage.text,
        medias: chatMessage.medias,
        status: model.MessageStatus.sent,
        deliveredAt: DateTime.now(),
        id: messageId,
      );

      final botMessage = model.ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: responseText,
        status: model.MessageStatus.sent,
        deliveredAt: DateTime.now(),
        id: '${messageId}_bot',
      );

      if (messages.isNotEmpty && messages[0].id == messageId) {
        messages[0] = sentMessage;
        messages.insert(0, botMessage);
      }
      isBotTyping.value = false;

      _chatCacheService.saveMessages(chatId, messages).then((_) {
        print('📱 Successfully cached new messages');
      });
    } catch (e) {
      print('📱 Error sending message: $e');
      if (messages.isNotEmpty && messages[0].id == messageId) {
        final failedMessage = model.ChatMessage(
          user: chatMessage.user,
          createdAt: chatMessage.createdAt,
          text: chatMessage.text,
          medias: chatMessage.medias,
          status: model.MessageStatus.failed,
          id: messageId,
        );
        messages[0] = failedMessage;
      }
      isBotTyping.value = false;
      Get.snackbar('Error', 'Failed to send message.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
} 