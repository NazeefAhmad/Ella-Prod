import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  // Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    PermissionStatus status = await Permission.notification.status;
    return status.isGranted;
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    return status.isGranted;
  }

  // Open app settings for notification permission
  Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  // Open general app settings
  Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }

  // Show permission dialog
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permission Required'),
          content: const Text(
            'This app needs notification permission to keep you updated with important information. '
            'Please enable notifications in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await openNotificationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Check and request permission with user-friendly flow
  Future<bool> checkAndRequestNotificationPermission(BuildContext context) async {
    // First check if permission is already granted
    if (await isNotificationPermissionGranted()) {
      return true;
    }

    // Request permission
    bool granted = await requestNotificationPermission();
    
    if (granted) {
      return true;
    }

    // If permission is denied, show dialog to open settings
    return await showPermissionDialog(context);
  }
} 