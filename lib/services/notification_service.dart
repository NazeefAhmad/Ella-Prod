import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../consts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String _baseUrl = '${AppConstants.baseUrl}/notifications';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Permission status
  bool _isNotificationEnabled = false;
  bool get isNotificationEnabled => _isNotificationEnabled;

  // Initialize the notification service
  Future<void> initialize() async {
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
    await _checkPermissionStatus();
    await _setupMessageHandlers();
  }

  // Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle permission status
    await _handlePermissionStatus(settings.authorizationStatus);

    // Get FCM token
    String? token = await firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveFCMToken(newToken);
    });
  }

  // Initialize Local Notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel (Android)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Setup message handlers
  Future<void> _setupMessageHandlers() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.data}');
      _handleNotificationTap(message.data);
    });

    // Handle initial message when app is launched from notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data);
    }
  }

  // Handle permission status
  Future<void> _handlePermissionStatus(AuthorizationStatus status) async {
    switch (status) {
      case AuthorizationStatus.authorized:
        _isNotificationEnabled = true;
        print('User granted notification permission');
        break;
      case AuthorizationStatus.denied:
        _isNotificationEnabled = false;
        print('User denied notification permission');
        break;
      case AuthorizationStatus.notDetermined:
        _isNotificationEnabled = false;
        print('User has not determined notification permission');
        break;
      case AuthorizationStatus.provisional:
        _isNotificationEnabled = true;
        print('User granted provisional notification permission');
        break;
    }
    await _savePermissionStatus();
  }

  // Check current permission status
  Future<void> _checkPermissionStatus() async {
    PermissionStatus status = await Permission.notification.status;
    _isNotificationEnabled = status.isGranted;
    await _savePermissionStatus();
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    _isNotificationEnabled = status.isGranted;
    await _savePermissionStatus();
    return status.isGranted;
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      Map<String, dynamic> data = json.decode(response.payload!);
      _handleNotificationTap(data);
    }
  }

  // Handle notification tap (implement your navigation logic here)
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Implement your navigation logic here
    // For example, navigate to a specific screen based on data
    print('Notification tapped with data: $data');
  }

  // Save FCM token
  Future<void> _saveFCMToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  // Save permission status
  Future<void> _savePermissionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _isNotificationEnabled);
  }

  // Load permission status
  Future<void> loadPermissionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled = prefs.getBool('notification_enabled') ?? false;
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
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
          'token': AppConstants.fcmtoken,
          'device_id': AppConstants.deviceId,
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
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
} 