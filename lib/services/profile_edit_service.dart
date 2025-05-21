import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/services/token_storage_service.dart';

class ProfileEditService {
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

  // PUT /profile/username - Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
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

  // PUT /profile/bio - Update bio
  Future<void> updateBio(String bio) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
        body: json.encode({
          'bio': bio,
        }),
      );

      print('Update bio response status: ${response.statusCode}');
      print('Update bio response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update bio: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateBio: $e');
      rethrow;
    }
  }

  // PUT /profile/email - Update email
  Future<void> updateEmail(String email) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
        body: json.encode({
          'email': email,
        }),
      );

      print('Update email response status: ${response.statusCode}');
      print('Update email response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update email: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateEmail: $e');
      rethrow;
    }
  }

  // PUT /profile/gender - Update gender
  Future<void> updateGender(String gender) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
        body: json.encode({
          'gender': gender,
        }),
      );

      print('Update gender response status: ${response.statusCode}');
      print('Update gender response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update gender: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateGender: $e');
      rethrow;
    }
  }

  // PUT /profile/date-of-birth - Update date of birth
  Future<void> updateDateOfBirth(DateTime dateOfBirth) async {
    try {
      final headers = await _getAuthHeaders();
      // Format date as YYYY-MM-DD
      final formattedDate = '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
        body: json.encode({
          'date_of_birth': formattedDate,
        }),
      );

      print('Update date of birth response status: ${response.statusCode}');
      print('Update date of birth response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update date of birth: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateDateOfBirth: $e');
      rethrow;
    }
  }

  // PUT /profile/avatar - Update profile picture
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      final headers = await _getAuthHeaders();
      // Remove Content-Type header as it will be set automatically for multipart request
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/profile/profile'),
      );

      // Add authorization header
      if (headers['Authorization'] != null) {
        request.headers['Authorization'] = headers['Authorization']!;
      }

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imagePath,
        ),
      );

      // Add the token to the request headers
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update profile picture response status: ${response.statusCode}');
      print('Update profile picture response body: ${response.body}');

      if (response.statusCode == 401) {
        throw 'Authentication failed. Please sign in again.';
      } else if (response.statusCode != 200) {
        throw 'Failed to update profile picture: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateProfilePicture: $e');
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