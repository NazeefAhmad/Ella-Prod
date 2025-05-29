import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._chatService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add user message immediately
      _messages.add(Message(
        content: message,
        isUser: true,
      ));
      notifyListeners();

      // Send message to API
      final response = await _chatService.sendMessage(message);

      // Add bot response
      _messages.add(Message(
        content: response.response,
        isUser: false,
      ));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory(String chatId, {int limit = 50}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final history = await _chatService.getChatHistory(chatId, limit: limit);
      _messages = history.messages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 