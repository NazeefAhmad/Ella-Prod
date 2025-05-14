import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final _baseUrl = AppConstants.baseUrl.trim();

  static const String _profileDataCacheKey = 'profile_data_cache';
  static const String _profileDataCacheTimestampKey = 'profile_data_cache_timestamp';
  static const String _profilePicUrlCacheKey = 'profile_pic_url_cache';
  static const String _profilePicUrlCacheTimestampKey = 'profile_pic_url_cache_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 10); // Cache for 10 minutes

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // Helper to check cache validity
  Future<bool> _isCacheValid(String timestampKey) async {
    final prefs = await _prefs;
    final timestampString = prefs.getString(timestampKey);
    if (timestampString == null) return false;
    final timestamp = DateTime.parse(timestampString);
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  Future<void> clearProfileCache() async {
    final prefs = await _prefs;
    await prefs.remove(_profileDataCacheKey);
    await prefs.remove(_profileDataCacheTimestampKey);
    await prefs.remove(_profilePicUrlCacheKey);
    await prefs.remove(_profilePicUrlCacheTimestampKey);
    print('Profile cache cleared');
  }

  // Function to get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /profile/ - Get user profile
  Future<Map<String, dynamic>> getUserProfile({bool forceRefresh = false}) async {
    final prefs = await _prefs;
    if (!forceRefresh && await _isCacheValid(_profileDataCacheTimestampKey)) {
      final cachedDataString = prefs.getString(_profileDataCacheKey);
      if (cachedDataString != null) {
        print('Returning cached profile data');
        return json.decode(cachedDataString) as Map<String, dynamic>;
      }
    }

    print('Fetching profile data from API');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
      );

      print('Get profile response status: ${response.statusCode}');
      print('Get profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          throw 'Invalid response from server';
        }
        await prefs.setString(_profileDataCacheKey, response.body);
        await prefs.setString(_profileDataCacheTimestampKey, DateTime.now().toIso8601String());
        return data as Map<String, dynamic>;
      } else {
        throw 'Failed to get profile: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }

  // GET /profile/DP - Get profile picture URL
  Future<String?> getProfilePicture({bool forceRefresh = false}) async {
    final prefs = await _prefs;
    if (!forceRefresh && await _isCacheValid(_profilePicUrlCacheTimestampKey)) {
      final cachedUrl = prefs.getString(_profilePicUrlCacheKey);
      if (cachedUrl != null) {
        print('Returning cached profile picture URL');
        return cachedUrl;
      }
    }
    print('Fetching profile picture URL from API');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/DP'),
        headers: headers,
      );

      print('Get profile picture response status: ${response.statusCode}');
      print('Get profile picture response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['profile_picture'] as String?;
        if (imageUrl != null) {
          await prefs.setString(_profilePicUrlCacheKey, imageUrl);
          await prefs.setString(_profilePicUrlCacheTimestampKey, DateTime.now().toIso8601String());
        }
        return imageUrl;
      } else if (response.statusCode == 404) {
        await prefs.remove(_profilePicUrlCacheKey); // Ensure no stale cache if not found
        await prefs.remove(_profilePicUrlCacheTimestampKey);
        return null; // No profile picture found
      } else {
        throw 'Failed to get profile picture: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in getProfilePicture: $e');
      rethrow;
    }
  }

  // PATCH /profile/ - Update profile fields
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/profile/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update profile: ${response.statusCode}';
      }
      await clearProfileCache(); // Clear cache on successful update
    } catch (e) {
      print('Error in updateProfile: $e');
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
      await clearProfileCache(); // Clear cache
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
      await clearProfileCache(); // Clear cache
    } catch (e) {
      print('Error in updateGenderPreference: $e');
      rethrow;
    }
  }

  // PUT /profile/DP - Update profile picture
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      // Check file size (5MB limit)
      final file = File(imagePath);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) { // 5MB in bytes
        throw 'Image size must be less than 5MB';
      }

      // Check file extension
      final extension = imagePath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        throw 'Invalid image format. Please use JPG, JPEG, PNG, or GIF';
      }

      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/DP'),
        headers: headers,
        body: json.encode({
          'profile_picture': imagePath,
        }),
      );

      print('Update profile picture response status: ${response.statusCode}');
      print('Update profile picture response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to update profile picture: ${response.statusCode}';
      }
      await clearProfileCache(); // Clear cache on successful update
    } catch (e) {
      print('Error in updateProfilePicture: $e');
      rethrow;
    }
  }
} 