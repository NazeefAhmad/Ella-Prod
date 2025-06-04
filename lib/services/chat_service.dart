import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';
import '../models/chat_models.dart';

class ChatService {
  // For physical Android device, use your computer's IP address
  final String baseUrl;
  final String userId;
  final String userName;

  ChatService({
    required this.baseUrl,
    required this.userId,
    required this.userName,
  });

  // Check API health
  Future<bool> checkHealth() async {
    print('\n=== API Health Check ===');
    print('ChatService: Checking API health at $baseUrl/health');
    print('ChatService: Platform: ${Platform.operatingSystem}');
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      
      print('ChatService: Health check response - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('ChatService: API is healthy and responding');
        return true;
      } else {
        print('ChatService: API returned unexpected status code: ${response.statusCode}');
        return false;
      }
    } on SocketException catch (e) {
      print('\n=== Connection Error ===');
      print('ChatService: Cannot connect to server at $baseUrl');
      print('ChatService: Error details: $e');
      print('\nTroubleshooting steps:');
      print('1. Ensure FastAPI server is running (uvicorn main:app --reload)');
      print('2. Check if server is running on port 8000');
      print('3. Verify your computer\'s IP address is correct');
      print('   - On Mac/Linux: Run "ifconfig" in terminal');
      print('   - On Windows: Run "ipconfig" in command prompt');
  
      print('4. Make sure your Android device is on the same WiFi network as your computer');
      print('5. Check if your computer\'s firewall is blocking the connection');
      print('========================\n');
      return false;
    } on TimeoutException catch (e) {
      print('\n=== Timeout Error ===');
      print('ChatService: Server connection timed out after 5 seconds');
      print('ChatService: Error details: $e');
      print('ChatService: Please check if the server is running and accessible');
      print('========================\n');
      return false;
    } catch (e) {
      print('\n=== Unexpected Error ===');
      print('ChatService: Health check error: $e');
      print('========================\n');
      return false;
    }
  }

  // Send chat message
  Future<ChatResponse> sendMessage(String message) async {
    print('\n=== Chat Request ===');
    print('ChatService: Sending message to $baseUrl/chat');
    print('ChatService: Request Details:');
    print('- User ID: $userId');
    print('- Username: $userName');
    print('- Message: $message');
    print('- Timestamp: ${DateTime.now()}');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ChatRequest(
          userId: userId,
          userName: userName,
          message: message,
        ).toJson()),
      );

      print('\n=== Server Response ===');
      print('ChatService: Response Status: ${response.statusCode}');
      print('ChatService: Response Headers: ${response.headers}');
      print('ChatService: Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('\n=== Error Response ===');
        print('ChatService: API error - Status: ${response.statusCode}');
        print('ChatService: Error Body: ${response.body}');
        print('========================\n');
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      return ChatResponse.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print('\n=== Connection Error ===');
      print('ChatService: Cannot connect to server at $baseUrl');
      print('ChatService: Error details: $e');
      print('ChatService: Please ensure server is running and accessible');
      print('========================\n');
      rethrow;
    } on TimeoutException catch (e) {
      print('\n=== Timeout Error ===');
      print('ChatService: Server connection timed out');
      print('ChatService: Error details: $e');
      print('========================\n');
      rethrow;
    } catch (e) {
      print('\n=== Error ===');
      print('ChatService: Error sending message: $e');
      print('========================\n');
      rethrow;
    }
  }

  Future<ChatHistoryResponse> getChatHistory(String chatId, {int limit = 50, int offset = 0}) async {
    // Use a default chat ID if empty
    final effectiveChatId = chatId.isNotEmpty ? chatId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
    
    print('\n=== Chat History Request ===');
    print('ChatService: Getting chat history from $baseUrl/chat/$effectiveChatId/history');
    print('ChatService: Request Details:');
    print('- Chat ID: $effectiveChatId');
    print('- Username: $userName');
    print('- Limit: $limit');
    print('- Offset: $offset');
    print('- Timestamp: ${DateTime.now()}');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$effectiveChatId/history?limit=$limit&offset=$offset&username=$userName'),
      );

      print('\n=== Server Response ===');
      print('ChatService: Response Status: ${response.statusCode}');
      print('ChatService: Response Headers: ${response.headers}');
      print('ChatService: Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('\n=== Error Response ===');
        print('ChatService: API error - Status: ${response.statusCode}');
        print('ChatService: Error Body: ${response.body}');
        print('========================\n');
        throw Exception('Failed to get chat history: ${response.statusCode}');
      }

      return ChatHistoryResponse.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print('\n=== Connection Error ===');
      print('ChatService: Cannot connect to server at $baseUrl');
      print('ChatService: Error details: $e');
      print('ChatService: Please ensure server is running and accessible');
      print('========================\n');
      rethrow;
    } on TimeoutException catch (e) {
      print('\n=== Timeout Error ===');
      print('ChatService: Server connection timed out');
      print('ChatService: Error details: $e');
      print('========================\n');
      rethrow;
    } catch (e) {
      print('\n=== Error ===');
      print('ChatService: Error getting chat history: $e');
      print('========================\n');
      rethrow;
    }
  }
} 
