import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/comprehensive_notification_service.dart';
import '../services/permission_manager.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget>
    with WidgetsBindingObserver {
  final ComprehensiveNotificationService _notificationService = ComprehensiveNotificationService();
  final PermissionManager _permissionManager = PermissionManager();
  
  bool _isNotificationEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatus();
    }
  }

  Future<void> _loadPermissionStatus() async {
    setState(() {
      _isLoading = true;
    });

    await _notificationService.loadPermissionStatus();
    bool isGranted = await _permissionManager.isNotificationPermissionGranted();

    setState(() {
      _isNotificationEnabled = isGranted;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    if (value) {
      // User wants to enable notifications
      bool granted = await _permissionManager.requestNotificationPermission();
      
      if (!granted) {
        // Permission denied, show settings dialog
        bool shouldOpenSettings = await _permissionManager.showPermissionDialog(context);
        
        if (shouldOpenSettings) {
          await _permissionManager.openNotificationSettings();
        }
      }
    } else {
      // User wants to disable notifications
      await _permissionManager.openNotificationSettings();
    }

    // Reload status after a delay to allow user to change settings
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadPermissionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Enable push notifications to stay updated with important information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: _isNotificationEnabled,
                    onChanged: _toggleNotification,
                    activeColor: Theme.of(context).primaryColor,
                  ),
              ],
            ),
            if (!_isNotificationEnabled && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notifications are disabled. Tap the switch to enable them.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 