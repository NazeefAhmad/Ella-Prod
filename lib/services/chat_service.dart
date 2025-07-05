
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:hoocup/consts.dart';
import '../models/chat_models.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/token_storage_service.dart';

class ChatService {
  final String baseUrl;
  String userId; // ✅ Now mutable
  final String userName;

  ChatService({
    required this.baseUrl,
    this.userId = '', // ✅ Allow initialization without knowing it
    required this.userName,
  });
Future<bool> checkHealth() async {
  print('\n=== API Health Check ===');
  print('ChatService: Checking API health at $baseUrl/health');
  print('ChatService: Platform: ${Platform.operatingSystem}');
  
  try {
    final response = await http.get(Uri.parse('$baseUrl/health'))
        .timeout(const Duration(seconds: 5));
    
    print('ChatService: Health check response - Status: ${response.statusCode}, Body: ${response.body}');
    
    if (response.statusCode == 200) {
      await fetchAndSetFirebaseUidAndUserId(); // ✅ Ensures userId is fetched
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
    return false;
  } on TimeoutException catch (e) {
    print('\n=== Timeout Error ===');
    print('ChatService: Server connection timed out after 5 seconds');
    print('ChatService: Error details: $e');
    return false;
  } catch (e) {
    print('\n=== Unexpected Error ===');
    print('ChatService: Health check error: $e');
    return false;
  }
}

  // ✅ Fetch and store firebase_uid + user_id from backend
  Future<void> fetchAndSetFirebaseUidAndUserId() async {
    print('\n=== Fetch Firebase UID and User ID ===');
    try {
      final token = await TokenStorageService().getAccessToken();
      if (token == null) {
        print('No access token found. User may not be logged in.');
        return;
      }

      final url = Uri.parse('$baseUrl/api/v1/firebase-uid');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      print('ChatService: Response Status: ${response.statusCode}');
      print('ChatService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedUserId = data['user_id'] ?? '';
        final firebaseUid = data['firebase_uid'] ?? '';

        userId = fetchedUserId; // ✅ Store userId for reuse
        print('ChatService: ✅ User ID set: $userId');
        print('ChatService: ✅ Firebase UID: $firebaseUid');
      } else {
        print('ChatService: ❌ Failed to fetch IDs. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatService: ❌ Error fetching UID and User ID: $e');
    }
  }

  // ✅ Send a normal chat message with user_id + timestamp
  Future<ChatResponse> sendMessage(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    print('\n=== Chat Request ===');
    print('ChatService: Sending message to $baseUrl/chat/');
    print('- User ID: $userId');
    print('- Username: $userName');
    print('- Message: $message');
    print('- Timestamp: $timestamp');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'username': userName,
          'message': message,
          'timestamp': timestamp,
        }),
      );

      print('\n=== Server Response ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }

      return ChatResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('❌ ChatService: Error sending message: $e');
      rethrow;
    }
  }

  // ✅ Send media message with user_id
  Future<ChatResponse> sendMediaMessage(
      String message, String mediaPath, String mediaType) async {
    final timestamp = DateTime.now().toIso8601String();
    print('\n=== Media Chat Request ===');
    print('- User ID: $userId');
    print('- Username: $userName');
    print('- Media Type: $mediaType');
    print('- Timestamp: $timestamp');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/media'),
      );

      request.fields['user_id'] = userId;
      request.fields['username'] = userName;
      request.fields['message'] = message;
      request.fields['media_type'] = mediaType;
      request.fields['timestamp'] = timestamp;

      request.files.add(await http.MultipartFile.fromPath('media', mediaPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to send media message');
      }

      return ChatResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('❌ ChatService: Error sending media: $e');
      rethrow;
    }
  }

  // ✅ Fetch chat history
  Future<ChatHistoryResponse> getChatHistory(String chatId,
    {int limit = 50, int offset = 0}) async {
  if (chatId.isEmpty) {
    throw Exception('Chat ID must be provided for history fetching');
  }

  print('\n=== Chat History Request ===');
  print('Chat ID: $chatId');

  try {
    final uri = Uri.parse(
        '$baseUrl/chat/$chatId/history?limit=$limit&offset=$offset');

    final response = await http.get(uri);

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 404) {
      throw Exception('Chat not found');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to fetch history');
    }

    return ChatHistoryResponse.fromJson(jsonDecode(response.body));
  } catch (e) {
    print('❌ ChatService: Error getting history: $e');
    rethrow;
  }
}
}