// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ComprehensiveNotificationService {
//   static final ComprehensiveNotificationService _instance = ComprehensiveNotificationService._internal();
//   factory ComprehensiveNotificationService() => _instance;
//   ComprehensiveNotificationService._internal();

//   static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Permission status
//   bool _isNotificationEnabled = false;
//   bool get isNotificationEnabled => _isNotificationEnabled;

//   // Initialize the notification service
//   Future<void> initialize() async {
//     await _initializeFirebaseMessaging();
//     await _initializeLocalNotifications();
//     await _checkPermissionStatus();
//     await _setupMessageHandlers();
//   }

//   // Initialize Firebase Messaging
//   Future<void> _initializeFirebaseMessaging() async {
//     // Request permission
//     NotificationSettings settings = await firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     // Handle permission status
//     await _handlePermissionStatus(settings.authorizationStatus);

//     // Get FCM token
//     String? token = await firebaseMessaging.getToken();
//     if (token != null) {
      
//       print('FCM Token: $token');
//       await _saveFCMToken(token);
      
//     }

//     // Listen for token refresh
//     firebaseMessaging.onTokenRefresh.listen((newToken) {
//       _saveFCMToken(newToken);
//     });
//   }

//   // Initialize Local Notifications
//   Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     // Create notification channel for Android
//     await _createNotificationChannel();
//   }

//   // Create notification channel (Android)
//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   // Setup message handlers
//   Future<void> _setupMessageHandlers() async {
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         _showLocalNotification(message);
//       }
//     });

//     // Handle when app is opened from notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('App opened from notification: ${message.data}');
//       _handleNotificationTap(message.data);
//     });

//     // Handle initial message when app is launched from notification
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print('App launched from notification: ${initialMessage.data}');
//       _handleNotificationTap(initialMessage.data);
//     }
//   }

//   // Handle permission status
//   Future<void> _handlePermissionStatus(AuthorizationStatus status) async {
//     switch (status) {
//       case AuthorizationStatus.authorized:
//         _isNotificationEnabled = true;
//         print('User granted notification permission');
//         break;
//       case AuthorizationStatus.denied:
//         _isNotificationEnabled = false;
//         print('User denied notification permission');
//         break;
//       case AuthorizationStatus.notDetermined:
//         _isNotificationEnabled = false;
//         print('User has not determined notification permission');
//         break;
//       case AuthorizationStatus.provisional:
//         _isNotificationEnabled = true;
//         print('User granted provisional notification permission');
//         break;
//     }
//     await _savePermissionStatus();
//   }

//   // Check current permission status
//   Future<void> _checkPermissionStatus() async {
//     PermissionStatus status = await Permission.notification.status;
//     _isNotificationEnabled = status.isGranted;
//     await _savePermissionStatus();
//   }

//   // Request notification permission
//   Future<bool> requestPermission() async {
//     PermissionStatus status = await Permission.notification.request();
//     _isNotificationEnabled = status.isGranted;
//     await _savePermissionStatus();
//     return status.isGranted;
//   }

//   // Show local notification
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload: json.encode(message.data),
//     );
//   }

//   // Handle notification tap
//   void _onNotificationTapped(NotificationResponse response) {
//     if (response.payload != null) {
//       Map<String, dynamic> data = json.decode(response.payload!);
//       _handleNotificationTap(data);
//     }
//   }

//   // Handle notification tap (implement your navigation logic here)
//   void _handleNotificationTap(Map<String, dynamic> data) {
//     // Implement your navigation logic here
//     // For example, navigate to a specific screen based on data
//     print('Notification tapped with data: $data');
//   }

//   // Save FCM token
//   Future<void> _saveFCMToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('fcm_token', token);
//   }

//   // Save permission status
//   Future<void> _savePermissionStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('notification_enabled', _isNotificationEnabled);
//   }

//   // Load permission status
//   Future<void> loadPermissionStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _isNotificationEnabled = prefs.getBool('notification_enabled') ?? false;
//   }

//   // Get FCM token
//   Future<String?> getFCMToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('fcm_token');
//   }
// }

// // Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// } 

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hoocup/consts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

class ComprehensiveNotificationService {
  static final ComprehensiveNotificationService _instance = ComprehensiveNotificationService._internal();
  factory ComprehensiveNotificationService() => _instance;
  ComprehensiveNotificationService._internal();

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      
      // Register with backend after getting token
      await registerTokenWithBackend();
    }

    // Listen for token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _saveFCMToken(newToken);
      await registerTokenWithBackend(); // Re-register with backend
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
    print('Notification tapped with data: $data');
    
    // Navigate based on notification type
    if (data['type'] == 'chat') {
      Get.toNamed('/chat', arguments: data);
    } else if (data['type'] == 'feed') {
      Get.toNamed('/feed');
    } else if (data['type'] == 'profile') {
      Get.toNamed('/profile');
    } else if (data['type'] == 'activity') {
      Get.toNamed('/activity');
    }
    // Add more navigation logic as needed
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

  // Register FCM token with backend
  Future<void> registerTokenWithBackend() async {
    try {
      String? fcmToken = await getFCMToken();
      if (fcmToken == null) {
        print('❌ No FCM token available for backend registration');
        return;
      }

      // Use AppConstants.accessToken instead of SharedPreferences
      String? authToken = AppConstants.accessToken;
      
      if (authToken == null || authToken.isEmpty) {
        print('⚠️ No auth token available, skipping backend registration');
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
          'device_id': await _getDeviceId(),
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token registered with backend successfully');
      } else {
        print('❌ Failed to register token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error registering token with backend: $e');
    }
  }

  // Get device ID
  Future<String> _getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  // Test notification from backend
  Future<void> testNotification() async {
    try {
      // Use AppConstants.accessToken instead of SharedPreferences
      String? authToken = AppConstants.accessToken;
      
      if (authToken == null || authToken.isEmpty) {
        print('❌ No auth token available for testing');
        return;
      }

      final response = await http.post(
    Uri.parse('${AppConstants.baseUrl}/notifications/test'),
     headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Test notification sent successfully');
      } else {
        print('❌ Failed to send test notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error testing notification: $e');
    }
  }

  // Send custom notification
  Future<void> sendCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? image,
  }) async {
    try {
      // Use AppConstants.accessToken instead of SharedPreferences
      String? authToken = AppConstants.accessToken;
      
      if (authToken == null || authToken.isEmpty) {
        print('❌ No auth token available');
        return;
      }

      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': data,
          'image': image,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Custom notification sent successfully');
      } else {
        print('❌ Failed to send custom notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending custom notification: $e');
    }
  }

  // Send multicast notification
  Future<void> sendMulticastNotification({
    required String title,
    required String body,
    required List<String> tokens,
    Map<String, dynamic>? data,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/send-multicast'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': data,
          'image': image,
        }),
      );

      // Send tokens separately
      final tokensResponse = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/send-multicast'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tokens),
      );

      if (response.statusCode == 200) {
        print('✅ Multicast notification sent successfully');
      } else {
        print('❌ Failed to send multicast notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending multicast notification: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic({
    required List<String> tokens,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/subscribe-topic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tokens': tokens,
          'topic': topic,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Subscribed to topic: $topic');
      } else {
        print('❌ Failed to subscribe to topic: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic({
    required List<String> tokens,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/unsubscribe-topic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tokens': tokens,
          'topic': topic,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Unsubscribed from topic: $topic');
      } else {
        print('❌ Failed to unsubscribe from topic: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  // Send topic notification
  Future<void> sendTopicNotification({
    required String title,
    required String body,
    required String topic,
    Map<String, dynamic>? data,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/send-topic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': data,
          'image': image,
        }),
      );

      // Send topic separately
      final topicResponse = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/notifications/send-topic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(topic),
      );

      if (response.statusCode == 200) {
        print('✅ Topic notification sent successfully');
      } else {
        print('❌ Failed to send topic notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending topic notification: $e');
    }
  }

  // Debug method to check token status
  Future<void> debugTokenStatus() async {
    String? fcmToken = await getFCMToken();
    String? authToken = AppConstants.accessToken;
    
    print('�� Debug Token Status:');
    print('FCM Token: ${fcmToken?.substring(0, 20)}...');
    print('Auth Token: ${authToken?.substring(0, 20)}...');
    print('Auth Token Length: ${authToken?.length}');
    print('API URL: ${dotenv.env['API_BASE_URL']}');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}