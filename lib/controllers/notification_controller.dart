import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/comprehensive_notification_service.dart';
import '../services/permission_manager.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final ComprehensiveNotificationService _notificationService = ComprehensiveNotificationService();
  final PermissionManager _permissionManager = PermissionManager();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isNotificationsEnabled = false.obs;
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
      
      // Load permission status
      await _notificationService.loadPermissionStatus();
      bool isGranted = await _permissionManager.isNotificationPermissionGranted();
      isNotificationsEnabled.value = isGranted;
      
      // Note: fetchNotifications method is not available in the new service
      // You would need to implement this separately if you need to fetch from backend
      // For now, we'll just initialize the service
      
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
        // User wants to enable notifications
        bool granted = await _permissionManager.requestNotificationPermission();
        
        if (!granted) {
          // Permission denied, show settings dialog
          bool shouldOpenSettings = await _permissionManager.showPermissionDialog(Get.context!);
          
          if (shouldOpenSettings) {
            await _permissionManager.openNotificationSettings();
          }
        }
      } else {
        // User wants to disable notifications - open settings
        await _permissionManager.openNotificationSettings();
      }

      // Reload status after a delay to allow user to change settings
      Future.delayed(const Duration(milliseconds: 500), () async {
        await _notificationService.loadPermissionStatus();
        bool isGranted = await _permissionManager.isNotificationPermissionGranted();
        isNotificationsEnabled.value = isGranted;
      });
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

  // Method to check current permission status
  Future<void> checkPermissionStatus() async {
    await _notificationService.loadPermissionStatus();
    bool isGranted = await _permissionManager.isNotificationPermissionGranted();
    isNotificationsEnabled.value = isGranted;
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling a background message: ${message.messageId}');
} 
