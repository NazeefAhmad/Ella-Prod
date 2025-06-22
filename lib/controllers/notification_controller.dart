import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _setupNotificationHandlers();
  }

  Future<void> _initializeNotifications() async {
    try {
      isLoading.value = true;
      await _notificationService.initialize();
      // TODO: Fetch notifications from your backend
      isLoading.value = false;
    } catch (e) {
      print('Error initializing notifications: $e');
      isLoading.value = false;
    }
  }

  void _setupNotificationHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  void _handleNotification(RemoteMessage message) {
    final notification = NotificationModel(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      data: message.data,
      image: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      timestamp: DateTime.now(),
    );

    notifications.insert(0, notification);
    _showLocalNotification(notification);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap based on the data
    if (message.data['type'] == 'chat_message') {
      // Navigate to chat screen
      // Get.to(() => ChatScreen(chatId: message.data['chat_id']));
    } else if (message.data['type'] == 'system_update') {
      // Handle system update
      // Get.to(() => SystemUpdateScreen());
    } else if (message.data['type'] == 'relationship_update') {
      // Handle relationship update
      // Get.to(() => RelationshipUpdateScreen());
    }
  }

  void _showLocalNotification(NotificationModel notification) {
    Get.snackbar(
      notification.title,
      notification.body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: notification.image != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(notification.image!),
              radius: 20,
            )
          : const Icon(Icons.notifications, color: Colors.red),
    );
  }

  Future<void> toggleNotifications(bool value) async {
    try {
      if (value) {
        await _notificationService.subscribeToTopic('default');
      } else {
        await _notificationService.unsubscribeFromTopic('default');
      }
      isNotificationsEnabled.value = value;
    } catch (e) {
      print('Error toggling notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshNotifications() async {
    await _initializeNotifications();
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling a background message: ${message.messageId}');
} 