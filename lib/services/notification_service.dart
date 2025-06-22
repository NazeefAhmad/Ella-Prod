import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../consts.dart';

class NotificationService {
  final String _baseUrl = '${AppConstants.baseUrl}/notifications';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Register FCM token
  Future<bool> registerFCMToken() async {
    try {
      final token = await getFCMToken();
      if (token == null) return false;

      final deviceInfo = await _deviceInfo.deviceInfo;
      final deviceId = deviceInfo.data['id']?.toString() ?? '';
      final deviceType = deviceInfo.data['platform']?.toString().toLowerCase() ?? '';

      final response = await http.post(
        Uri.parse('$_baseUrl/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _auth.currentUser?.getIdToken()}',
        },
        body: jsonEncode({
          'token': token,
          'device_id': deviceId,
          'device_type': deviceType,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error registering FCM token: $e');
      return false;
    }
  }

  // Send notification to current user
  Future<bool> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _auth.currentUser?.getIdToken()}',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': data,
          'image': image,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Subscribe to topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      final token = await getFCMToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/subscribe-topic'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _auth.currentUser?.getIdToken()}',
        },
        body: jsonEncode({
          'tokens': [token],
          'topic': topic,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error subscribing to topic: $e');
      return false;
    }
  }

  // Unsubscribe from topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      final token = await getFCMToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/unsubscribe-topic'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _auth.currentUser?.getIdToken()}',
        },
        body: jsonEncode({
          'tokens': [token],
          'topic': topic,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      return false;
    }
  }

  // Initialize notification settings
  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register FCM token
    await registerFCMToken();

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) async {
      await registerFCMToken();
    });
  }
} 