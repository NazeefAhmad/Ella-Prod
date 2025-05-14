import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/services/token_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserActivityService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final _baseUrl = AppConstants.baseUrl.trim();
  String? _currentSessionId;

  // Function to get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generate a unique session ID
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get current session ID or generate a new one
  String getCurrentSessionId() {
    _currentSessionId ??= _generateSessionId();
    return _currentSessionId!;
  }

  // Record user activity
  Future<void> recordActivity(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final packageInfo = await PackageInfo.fromPlatform();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/account/activity'),
        headers: headers,
        body: json.encode({
          'endpoint': endpoint,
          'session_id': getCurrentSessionId(),
          'device_info': {
            'platform': Platform.operatingSystem,
            'app_version': packageInfo.version,
          }
        }),
      );

      print('Record activity response status: ${response.statusCode}');
      print('Record activity response body: ${response.body}');

      if (response.statusCode != 201) {
        throw 'Failed to record activity: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in recordActivity: $e');
      // Don't rethrow the error to prevent disrupting the user experience
    }
  }

  // Get user activity status
  Future<Map<String, dynamic>> getActivityStatus({String? userId, int? inactiveDays}) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId;
      if (inactiveDays != null) queryParams['inactive_days'] = inactiveDays.toString();
      
      final uri = Uri.parse('$_baseUrl/account/activity').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: headers,
      );

      print('Get activity status response status: ${response.statusCode}');
      print('Get activity status response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          throw 'Invalid response from server';
        }
        return data;
      } else if (response.statusCode == 403) {
        throw 'You do not have permission to view this user\'s activity';
      } else if (response.statusCode == 404) {
        throw 'User not found';
      } else {
        throw 'Failed to get activity status: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in getActivityStatus: $e');
      rethrow;
    }
  }
} 