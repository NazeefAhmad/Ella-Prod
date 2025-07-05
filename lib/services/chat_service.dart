// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:hoocup/consts.dart';
// import '../models/chat_models.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:get/get.dart';
// import 'package:hoocup/services/token_storage_service.dart';



// class ChatService {

// Future<void> fetchAndPrintFirebaseUidAndUserId() async {
//   print('\n=== Fetch Firebase UID and User ID ===');
//   try {
//     final token = await TokenStorageService().getAccessToken();
//     if (token == null) {
//       print('No access token found. User may not be logged in.');
//       return;
//     }
//     final url = Uri.parse('$baseUrl/api/v1/firebase-uid');
//     print('ChatService: Fetching from: $url');

//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//     print('ChatService: Request Headers: $headers');
//     final response = await http.get(url, headers: headers);

//     print('ChatService: Response Status: ${response.statusCode}');
//     print('ChatService: Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final firebaseUid = data['firebase_uid'] as String? ?? '';
//       final userId = data['user_id'] as String? ?? '';

//       print('ChatService: ✅ Firebase UID: $firebaseUid');
//       print('ChatService: ✅ User ID: $userId');
//     } else {
//       print('ChatService: ❌ Failed to fetch Firebase UID and User ID. Status: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('ChatService: ❌ Error fetching Firebase UID and User ID: $e');
//   }
// }



//   // For physical Android device, use your computer's IP address
//   final String baseUrl;
//   final String userId;
//   final String userName;

//   ChatService({
//     required this.baseUrl,
//     required this.userId,
//     required this.userName,
//   });

//   // Check API health
//   Future<bool> checkHealth() async {
//     print('\n=== API Health Check ===');
//     print('ChatService: Checking API health at $baseUrl/health');
//     print('ChatService: Platform: ${Platform.operatingSystem}');
    
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/health'))
//           .timeout(const Duration(seconds: 5));
      
//       print('ChatService: Health check response - Status: ${response.statusCode}, Body: ${response.body}');
      
//       if (response.statusCode == 200) {
//          await fetchAndPrintFirebaseUidAndUserId();
//         print('ChatService: API is healthy and responding');
//         return true;
//       } else {
//         print('ChatService: API returned unexpected status code: ${response.statusCode}');
//         return false;
//       }
//     } on SocketException catch (e) {
//       print('\n=== Connection Error ===');
//       print('ChatService: Cannot connect to server at $baseUrl');
//       print('ChatService: Error details: $e');
//       print('\nTroubleshooting steps:');
//       print('1. Ensure FastAPI server is running (uvicorn main:app --reload)');
//       print('2. Check if server is running on port 8000');
//       print('3. Verify your computer\'s IP address is correct');
//       print('   - On Mac/Linux: Run "ifconfig" in terminal');
//       print('   - On Windows: Run "ipconfig" in command prompt');
  
//       print('4. Make sure your Android device is on the same WiFi network as your computer');
//       print('5. Check if your computer\'s firewall is blocking the connection');
//       print('========================\n');
//       return false;
//     } on TimeoutException catch (e) {
//       print('\n=== Timeout Error ===');
//       print('ChatService: Server connection timed out after 5 seconds');
//       print('ChatService: Error details: $e');
//       print('ChatService: Please check if the server is running and accessible');
//       print('========================\n');
//       return false;
//     } catch (e) {
//       print('\n=== Unexpected Error ===');
//       print('ChatService: Health check error: $e');
//       print('========================\n');
//       return false;
//     }
//   }
  
  

//   // Send chat message
//   Future<ChatResponse> sendMessage(String message) async {
//     print('\n=== Chat Request ===');
//     print('ChatService: Sending message to $baseUrl/chat/');
//     print('ChatService: Request Details:');
//     print('- User ID: $userId');
//     print('- Username: $userName');
//     print('- Message: $message');
//     print('- Timestamp: ${DateTime.now()}');
    
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(ChatRequest(
//           userId: userId,
//           userName: userName,
//           message: message,
//         ).toJson()),
//       );

//       print('\n=== Server Response ===');
//       print('ChatService: Response Status: ${response.statusCode}');
//       print('ChatService: Response Headers: ${response.headers}');
//       print('ChatService: Response Body: ${response.body}');

//       if (response.statusCode != 200) {
//         print('\n=== Error Response ===');
//         print('ChatService: API error - Status: ${response.statusCode}');
//         print('ChatService: Error Body: ${response.body}');
//         print('========================\n');
//         throw Exception('Failed to send message: ${response.statusCode}');
//       }

//       return ChatResponse.fromJson(jsonDecode(response.body));
//     } on SocketException catch (e) {
//       print('\n=== Connection Error ===');
//       print('ChatService: Cannot connect to server at $baseUrl');
//       print('ChatService: Error details: $e');
//       print('ChatService: Please ensure server is running and accessible');
//       print('========================\n');
//       rethrow;
//     } on TimeoutException catch (e) {
//       print('\n=== Timeout Error ===');
//       print('ChatService: Server connection timed out');
//       print('ChatService: Error details: $e');
//       print('========================\n');
//       rethrow;
//     } catch (e) {
//       print('\n=== Error ===');
//       print('ChatService: Error sending message: $e');
//       print('========================\n');
//       rethrow;
//     }
//   }

//   Future<ChatResponse> sendMediaMessage(String message, String mediaPath, String mediaType) async {
//     print('\n=== Media Chat Request ===');
//     print('ChatService: Sending media message to $baseUrl/chat/media');
//     print('ChatService: Request Details:');
//     print('- User ID: $userId');
//     print('- Username: $userName');
//     print('- Message: $message');
//     print('- Media Type: $mediaType');
//     print('- Timestamp: ${DateTime.now()}');
    
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/chat/media'));
      
//       // Add text fields
//       request.fields['user_id'] = userId;
//       request.fields['username'] = userName;
//       request.fields['message'] = message;
//       request.fields['media_type'] = mediaType;
      
//       // Add media file
//       request.files.add(await http.MultipartFile.fromPath('media', mediaPath));
      
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       print('\n=== Server Response ===');
//       print('ChatService: Response Status: ${response.statusCode}');
//       print('ChatService: Response Headers: ${response.headers}');
//       print('ChatService: Response Body: ${response.body}');

//       if (response.statusCode != 200) {
//         print('\n=== Error Response ===');
//         print('ChatService: API error - Status: ${response.statusCode}');
//         print('ChatService: Error Body: ${response.body}');
//         print('========================\n');
//         throw Exception('Failed to send media message: ${response.statusCode}');
//       }

//       return ChatResponse.fromJson(jsonDecode(response.body));
//     } on SocketException catch (e) {
//       print('\n=== Connection Error ===');
//       print('ChatService: Cannot connect to server at $baseUrl');
//       print('ChatService: Error details: $e');
//       print('ChatService: Please ensure server is running and accessible');
//       print('========================\n');
//       rethrow;
//     } on TimeoutException catch (e) {
//       print('\n=== Timeout Error ===');
//       print('ChatService: Server connection timed out');
//       print('ChatService: Error details: $e');
//       print('========================\n');
//       rethrow;
//     } catch (e) {
//       print('\n=== Error ===');
//       print('ChatService: Error sending media message: $e');
//       print('========================\n');
//       rethrow;
//     }
//   }

//   Future<ChatHistoryResponse> getChatHistory(String chatId, {int limit = 50, int offset = 0}) async {
//     // Use a default chat ID if empty
//     final effectiveChatId = chatId.isNotEmpty ? chatId : 'guest_${DateTime.now().millisecondsSinceEpoch}';
    
//     print('\n=== Chat History Request ===');
//     print('ChatService: Getting chat history from $baseUrl/chat/$effectiveChatId/history');
//     print('ChatService: Request Details:');
//     print('- Chat ID: $effectiveChatId');
//     print('- Username: $userName');
//     print('- Limit: $limit');
//     print('- Offset: $offset');
//     print('- Timestamp: ${DateTime.now()}');
    
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/$effectiveChatId/history?limit=$limit&offset=$offset&username=$userName'),
//       );

//       print('\n=== Server Response ===');
//       print('ChatService: Response Status: ${response.statusCode}');
//       print('ChatService: Response Headers: ${response.headers}');
//       print('ChatService: Response Body: ${response.body}');

//       if (response.statusCode != 200) {
//         print('\n=== Error Response ===');
//         print('ChatService: API error - Status: ${response.statusCode}');
//         print('ChatService: Error Body: ${response.body}');
//         print('========================\n');
//         throw Exception('Failed to get chat history: ${response.statusCode}');
//       }

//       return ChatHistoryResponse.fromJson(jsonDecode(response.body));
//     } on SocketException catch (e) {
//       print('\n=== Connection Error ===');
//       print('ChatService: Cannot connect to server at $baseUrl');
//       print('ChatService: Error details: $e');
//       print('ChatService: Please ensure server is running and accessible');
//       print('========================\n');
//       rethrow;
//     } on TimeoutException catch (e) {
//       print('\n=== Timeout Error ===');
//       print('ChatService: Server connection timed out');
//       print('ChatService: Error details: $e');
//       print('========================\n');
//       rethrow;
//     } catch (e) {
//       print('\n=== Error ===');
//       print('ChatService: Error getting chat history: $e');
//       print('========================\n');
//       rethrow;
//     }
//   }
  
// } 

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
    final effectiveChatId = chatId.isNotEmpty
        ? chatId
        : 'guest_${DateTime.now().millisecondsSinceEpoch}';

    print('\n=== Chat History Request ===');
    print('Chat ID: $effectiveChatId');

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/chat/$effectiveChatId/history?limit=$limit&offset=$offset&username=$userName'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch history');
      }

      return ChatHistoryResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('❌ ChatService: Error getting history: $e');
      rethrow;
    }
  }
}
