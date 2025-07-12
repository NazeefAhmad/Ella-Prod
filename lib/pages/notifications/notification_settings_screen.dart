import 'package:flutter/material.dart';
import '../../widgets/back_button.dart';
import '../../services/comprehensive_notification_service.dart';
import '../../services/permission_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  final ComprehensiveNotificationService _notificationService = ComprehensiveNotificationService();
  final PermissionManager _permissionManager = PermissionManager();
  
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationStatus();
    }
  }

  Future<void> _loadNotificationStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _notificationService.loadPermissionStatus();
      bool isGranted = await _permissionManager.isNotificationPermissionGranted();
      
      setState(() {
        _notificationsEnabled = isGranted;
        _isLoading = false;
      });
      
      print('Notification permission status: $isGranted');
    } catch (e) {
      print('Error loading notification status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
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
      // User wants to disable notifications - open settings
      await _permissionManager.openNotificationSettings();
    }

    // Reload status after a delay to allow user to change settings
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadNotificationStatus();
    });
  }

  // Add method to refresh permission status
  Future<void> _refreshPermissionStatus() async {
    try {
      await _loadNotificationStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_notificationsEnabled ? 'Notifications are enabled' : 'Notifications are disabled'),
          backgroundColor: _notificationsEnabled ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error refreshing permission status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const CustomBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshPermissionStatus,
            tooltip: 'Refresh permission status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 32, 78, 1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            size: 48,
                            color: const Color.fromRGBO(255, 32, 78, 1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Stay Updated',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _notificationsEnabled
                              ? 'Your notifications are turned on! You will receive updates about new matches, messages, and exciting features in real-time.'
                              : 'Please allow notifications to get updates in real-time about new matches, messages, and exciting features.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        if (!_notificationsEnabled) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'How to enable notifications:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '1. Go to Settings > Apps > Hoocup\n'
                                  '2. Tap on "Notifications"\n'
                                  '3. Enable "Allow notifications"\n'
                                  '4. Return here and tap the refresh button',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toggle section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: _notificationsEnabled 
                                  ? const Color.fromRGBO(255, 32, 78, 1)
                                  : Colors.grey[400],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Push Notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                              activeColor: const Color.fromRGBO(255, 32, 78, 1),
                              activeTrackColor: const Color.fromRGBO(255, 32, 78, 0.3),
                              inactiveThumbColor: Colors.grey[400],
                              inactiveTrackColor: Colors.grey[200],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _notificationsEnabled
                              ? 'You\'ll receive notifications for:'
                              : 'Enable notifications to receive updates for:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNotificationItem(
                          icon: Icons.favorite,
                          title: 'New Matches',
                          description: 'When someone likes your profile',
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'Messages',
                          description: 'New messages from your matches',
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationItem(
                          icon: Icons.update,
                          title: 'App Updates',
                          description: 'New features and improvements',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can change notification settings anytime in your device settings.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _notificationsEnabled 
                ? const Color.fromRGBO(255, 32, 78, 1).withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: _notificationsEnabled 
                ? const Color.fromRGBO(255, 32, 78, 1)
                : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _notificationsEnabled 
                      ? Colors.black87
                      : Colors.grey[600],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 