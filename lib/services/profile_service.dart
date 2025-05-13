import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/services/token_storage_service.dart';

class ProfileService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final _baseUrl = AppConstants.baseUrl.trim();

  // Function to get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /profile/ - Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: headers,
      );

      print('Get profile response status: ${response.statusCode}');
      print('Get profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          throw 'Invalid response from server';
        }
        return data;
      } else {
        throw 'Failed to get profile: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }

  // GET /profile/username - Get username (read-only for guest users)
  Future<String> getUsername() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/username'),
        headers: headers,
      );

      print('Get username response status: ${response.statusCode}');
      print('Get username response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['username'] == null) {
          throw 'Invalid response from server';
        }
        return data['username'] as String;
      } else {
        throw 'Failed to get username: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in getUsername: $e');
      rethrow;
    }
  }

  // PUT /profile/username - Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/username'),
        headers: headers,
        body: json.encode({
          'username': newUsername,
        }),
      );

      print('Update username response status: ${response.statusCode}');
      print('Update username response body: ${response.body}');

      if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        if (responseBody['message']?.toString().toLowerCase().contains('already taken') ?? false) {
          throw 'Username already taken. Please choose a different username.';
        }
        throw 'Invalid username: ${responseBody['message'] ?? 'Please try again'}';
      } else if (response.statusCode != 200) {
        throw 'Failed to update username: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateUsername: $e');
      rethrow;
    }
  }

  // PUT /profile/gender-preference - Update gender preference
  Future<void> updateGenderPreference(String genderPreference) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/gender-preference'),
        headers: headers,
        body: json.encode({
          'gender_preference': genderPreference,
        }),
      );

      print('Update gender preference response status: ${response.statusCode}');
      print('Update gender preference response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update gender preference: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateGenderPreference: $e');
      rethrow;
    }
  }
} 