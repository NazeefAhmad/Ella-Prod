import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';

class ChatService {
  // For physical Android device, use your computer's IP address
  final String baseUrl = 'http://192.168.1.57:8000'; // TODO: Replace with your computer's IP

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
      print('   - Look for your local IP (usually starts with 192.168.x.x)');
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
  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String message,
  }) async {
    print('\n=== Chat Request ===');
    print('ChatService: Sending message to $baseUrl/chat');
    print('ChatService: Request Details:');
    print('- User ID: $userId');
    print('- Message: $message');
    print('- Timestamp: ${DateTime.now()}');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'user_id': userId,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 10));

      print('\n=== Server Response ===');
      print('ChatService: Response Status: ${response.statusCode}');
      print('ChatService: Response Headers: ${response.headers}');
      print('ChatService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        print('\n=== Parsed Response ===');
        print('ChatService: Parsed Response: $decodedResponse');
        print('ChatService: Bot Message: ${decodedResponse['response']}');
        print('========================\n');
        return decodedResponse;
      } else {
        print('\n=== Error Response ===');
        print('ChatService: API error - Status: ${response.statusCode}');
        print('ChatService: Error Body: ${response.body}');
        print('========================\n');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
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
} 