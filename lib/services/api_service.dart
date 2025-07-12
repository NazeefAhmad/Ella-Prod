import 'dart:convert';
import 'dart:io';  
import 'dart:async';  // Add this import for TimeoutException
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';  
import 'package:hoocup/consts.dart';  
import 'package:hoocup/services/token_storage_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final _baseUrl = AppConstants.baseUrl.trim(); // Trim any whitespace

  // Function to get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Function to refresh access token
  Future<void> refreshAccessToken() async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    print('Starting token refresh process...');
    while (retryCount < maxRetries) {
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        print('[DEBUG] Current refresh token before refresh: '
            + (refreshToken ?? 'null'));
        if (refreshToken == null) {
          print('No refresh token available');
          throw 'No refresh token available';
        }

        print('Attempting token refresh (attempt ${retryCount + 1}/$maxRetries)...');
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refresh_token': refreshToken}),
        ).timeout(const Duration(seconds: 10));

        print('[DEBUG] Token refresh response status: ${response.statusCode}');
        print('[DEBUG] Token refresh response body: ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data == null) {
            print('Invalid response from server - null data');
            throw 'Invalid response from server';
          }

          final accessToken = data['access_token'] as String?;
          final newRefreshToken = data['refresh_token'] as String?;
          final expiresIn = (data['expires_in'] ?? 30) * 60;

          if (accessToken == null || newRefreshToken == null) {
            print('Missing required tokens in response');
            throw 'Missing required tokens in response';
          }

          print('[DEBUG] Token refresh successful - saving new tokens');
          print('[DEBUG] New refresh token after refresh: \n' + newRefreshToken);
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: newRefreshToken,
            expiresIn: expiresIn,
          );
          print('[DEBUG] New tokens saved successfully');
          return;
        } else if (response.statusCode == 401) {
          print('[DEBUG] Refresh token is invalid or expired (401)');
          print('[DEBUG] API error: Status ${response.statusCode}, Body: ${response.body}');
          break;
        } else {
          print('[DEBUG] API error: Status ${response.statusCode}, Body: ${response.body}');
          retryCount++;
          if (retryCount < maxRetries) {
            print('Retrying in ${retryDelay.inSeconds} seconds...');
            await Future.delayed(retryDelay);
            continue;
          }
          throw 'Failed to refresh token after $maxRetries attempts';
        }
      } on TimeoutException {
        print('[DEBUG] Token refresh request timed out');
        retryCount++;
        if (retryCount < maxRetries) {
          print('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
          continue;
        }
        throw 'Token refresh timed out after $maxRetries attempts';
      } catch (e) {
        print('[DEBUG] Error refreshing token: $e');
        retryCount++;
        if (retryCount < maxRetries) {
          print('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
          continue;
        }
        print('[DEBUG] All retry attempts failed, logging out user');
        await _tokenStorage.deleteTokens();
        Get.offAllNamed('/onboarding');
        rethrow;
      }
    }

    print('[DEBUG] Token refresh failed after all attempts, logging out user');
    await _tokenStorage.deleteTokens();
    Get.offAllNamed('/onboarding');
  }

  // Function to make authenticated requests with automatic token refresh
  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn,
  ) async {
    try {
      // Check if access token is expired
      if (await _tokenStorage.isAccessTokenExpired()) {
        await refreshAccessToken();
      }

      final headers = await _getAuthHeaders();
      final response = await requestFn(headers);

      // If token is invalid or expired, try refreshing once
      if (response.statusCode == 401) {
        await refreshAccessToken();
        final newHeaders = await _getAuthHeaders();
        return await requestFn(newHeaders);
      }

      return response;
    } catch (e) {
      print('Error in authenticated request: $e');
      rethrow;
    }
  }

  // Function to get JWT token for Google authentication
  Future<Map<String, dynamic>?> getGoogleAuthToken(String idToken, String uid, String email) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/firebase');
      print('Making request to: $url');
      print('Device platform: ${Platform.operatingSystem}');
      print('Base URL being used: $_baseUrl');
      print('Request body: {"token": "${idToken.substring(0, 20)}..."}'); // Log first 20 chars of token

      // Get device fingerprint
      String deviceFingerprint = await _getDeviceFingerprint();
      String deviceId = AppConstants.deviceId;
      
      // Get FCM token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString(AppConstants.fcmtoken) ?? '';
      print("📱 API Service - Google Auth - Retrieved FCM token from SharedPreferences: $fcmToken");
      print("📱 API Service - Google Auth - FCM token length: ${fcmToken.length}");
      print("📱 API Service - Google Auth - FCM token is empty: ${fcmToken.isEmpty}");
      
      print('📱 Device Info before API call:');
      print('Device ID: $deviceId');
      print('Device Fingerprint: $deviceFingerprint');
      print('Platform: ${Platform.isIOS ? "ios" : "android"}');
      print('FCM Token: $fcmToken');

      // Test connection first
      try {
        final testResponse = await http.get(Uri.parse('$_baseUrl/health'))
            .timeout(const Duration(seconds: 5));
        print('Health check response: ${testResponse.statusCode} - ${testResponse.body}');
      } catch (e) {
        print('Health check failed: $e');
      }

      final requestBody = {
        'token': idToken,
        'uid': uid,
        'email': email,
        'device_id': deviceId,
        'fingerprint': deviceFingerprint,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'fcm_token': fcmToken
      };
      
      print('📱 Request body with device info: ${json.encode(requestBody)}');
      print('📱 Request body FCM token: ${requestBody['fcm_token']}');
      print('📱 Request body FCM token length: ${requestBody['fcm_token']?.length}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          throw 'Invalid response from server';
        }

        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        // Convert minutes to seconds for consistency
        final expiresIn = (data['expires_in'] ?? 30) * 60; // Default to 30 minutes if not provided

        if (accessToken == null || refreshToken == null) {
          throw 'Missing required tokens in response';
        }

        // Save the tokens with expiration
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
        );
        return data;
      } else {
        print('API error: Status ${response.statusCode}, Body: ${response.body}');
        throw 'Failed to authenticate with Google: ${response.statusCode}';
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      print('Troubleshooting steps:');
      print('1. Verify server is running at $_baseUrl');
      print('2. Check if device and computer are on same network');
      print('3. Try pinging the server IP from your device');
      rethrow;
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
      rethrow;
    } catch (e) {
      print('Error in getGoogleAuthToken: $e');
      rethrow;
    }
  }

  // Function to continue as guest
  Future<Map<String, dynamic>> continueAsGuest() async {
    try {
      String deviceId = AppConstants.deviceId;
      String deviceFingerprint = await _getDeviceFingerprint();
      String platform = Platform.isIOS ? 'ios' : 'android';
      
      // Get FCM token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString(AppConstants.fcmtoken) ?? '';
      print("📱 API Service - Retrieved FCM token from SharedPreferences: $fcmToken");
      print("📱 API Service - FCM token length: ${fcmToken.length}");
      print("📱 API Service - FCM token is empty: ${fcmToken.isEmpty}");

      if (deviceId.isEmpty) {
        throw 'Device ID is empty';
      }

      final url = Uri.parse('$_baseUrl/auth/guestUser');
      print('Making request to: $url'); // Debug log

      // Test connection first
      try {
        final testResponse = await http.get(Uri.parse('$_baseUrl/health'))
            .timeout(const Duration(seconds: 5));
        print('Health check response: ${testResponse.statusCode} - ${testResponse.body}');
      } catch (e) {
        print('Health check failed: $e');
        throw 'Cannot connect to server. Please check your internet connection and try again.';
      }

      final requestBody = {
        'device_id': deviceId,
        'fingerprint': deviceFingerprint,
        'platform': platform,
        'fcm_token': fcmToken
      };

      print('📱 Guest login request body: ${json.encode(requestBody)}');
      print('📱 Guest login request body FCM token: ${requestBody['fcm_token']}');
      print('📱 Guest login request body FCM token length: ${requestBody['fcm_token']?.length}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data == null) {
          throw 'Invalid response from server';
        }

        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 1800;

        if (accessToken == null || refreshToken == null) {
          throw 'Missing required tokens in response';
        }

        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
        );
        return data;
      } else {
        print('API error: Status ${response.statusCode}, Body: ${response.body}');
        throw 'Failed to continue as guest: ${response.statusCode}';
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      print('Troubleshooting steps:');
      print('1. Verify server is running at $_baseUrl');
      print('2. Check if device and computer are on same network');
      print('3. Try pinging the server IP from your device');
      throw 'Network error: Cannot connect to server. Please check your internet connection and try again.';
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
      throw 'Connection timed out. Please check your internet connection and try again.';
    } catch (e) {
      print('Error in continueAsGuest: $e');
      rethrow;
    }
  }

  // Function to submit user data (example of authenticated request)
  Future<void> submitUserData(String name) async {
    await _makeAuthenticatedRequest((headers) async {
      return await http.post(
        Uri.parse('$_baseUrl/userDetails'),
        headers: headers,
        body: json.encode({'name': name}),
      );
    });
  }

  // Function to send user interest (example of authenticated request)
  Future<void> sendInterest(String interest) async {
    await _makeAuthenticatedRequest((headers) async {
      return await http.post(
        Uri.parse('$_baseUrl/interest'),
        headers: headers,
        body: json.encode({'interest': interest}),
      );
    });
  }

  // Helper function to get device fingerprint
  Future<String> _getDeviceFingerprint() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fingerprint = '';

    try {
      print('📱 Getting device fingerprint...');
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        fingerprint = androidInfo.fingerprint ?? 'Unknown Fingerprint';
        print('📱 Android fingerprint: $fingerprint');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        fingerprint = iosInfo.identifierForVendor ?? 'Unknown Fingerprint';
        print('📱 iOS fingerprint: $fingerprint');
      }
    } catch (e) {
      print('❌ Error fetching device fingerprint: $e');
    }

    return fingerprint;
  }

  // Function to logout device
  Future<void> logout(String deviceId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: headers,
        body: json.encode({
          'device_id': deviceId,
        }),
      );

      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to logout: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in logout: $e');
      rethrow;
    }
  }

  // Function to deactivate account
  Future<void> deactivateAccount() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/deactivate'),
        headers: headers,
      );

      print('Deactivate account response status: ${response.statusCode}');
      print('Deactivate account response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to deactivate account: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in deactivateAccount: $e');
      rethrow;
    }
  }

  // Function to delete account
  Future<void> deleteAccount() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/account'),
        headers: headers,
      );

      print('Delete account response status: ${response.statusCode}');
      print('Delete account response body: ${response.body}');

      if (response.statusCode != 200) {
        throw 'Failed to delete account: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in deleteAccount: $e');
      rethrow;
    }
  }

  // Function to update username
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

      if (response.statusCode != 200) {
        throw 'Failed to update username: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in updateUsername: $e');
      rethrow;
    }
  }

  /// Fetches Firebase UID and user ID for the authenticated user and stores them in AppConstants and SharedPreferences
  // Future<Map<String, dynamic>?> fetchFirebaseUidAndUserId() async {
  //   try {
  //     final url = Uri.parse('$_baseUrl/api/v1/firebase-uid');
  //     final headers = await _getAuthHeaders();
  //     final response = await http.get(url, headers: headers);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final firebaseUid = data['firebase_uid'] as String? ?? '';
  //       final userId = data['user_id'] as String? ?? '';
  //       AppConstants.userId = userId;
  //       AppConstants.firebaseUid = firebaseUid;
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('user_id', userId);
  //       await prefs.setString('firebase_uid', firebaseUid);
  //       return data;
  //     } else {
  //       print('Failed to fetch Firebase UID: \\${response.statusCode} - \\${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching Firebase UID: \\${e.toString()}');
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>?> fetchFirebaseUidAndUserId() async {
  try {
    print('[fetchFirebaseUidAndUserId] Starting fetch...');

    final url = Uri.parse('$_baseUrl/api/v1/firebase-uid');
    print('[fetchFirebaseUidAndUserId] URL: $url');

    final headers = await _getAuthHeaders();
    print('[fetchFirebaseUidAndUserId] Headers: $headers');

    final response = await http.get(url, headers: headers);
    print('[fetchFirebaseUidAndUserId] Response Status: ${response.statusCode}');
    print('[fetchFirebaseUidAndUserId] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('[fetchFirebaseUidAndUserId] Decoded Data: $data');

      final firebaseUid = data['firebase_uid'] as String? ?? '';
      final userId = data['user_id'] as String? ?? '';
      print('[fetchFirebaseUidAndUserId] Firebase UID: $firebaseUid');
      print('[fetchFirebaseUidAndUserId] User ID: $userId');

      AppConstants.userId = userId;
      AppConstants.firebaseUid = firebaseUid;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('firebase_uid', firebaseUid);
      print('[fetchFirebaseUidAndUserId] Stored in SharedPreferences');

      return data;
    } else {
      print('[fetchFirebaseUidAndUserId] Failed to fetch Firebase UID: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('[fetchFirebaseUidAndUserId] Error fetching Firebase UID: ${e.toString()}');
    return null;
  }
}

}

