import 'package:flutter/material.dart';
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';
import 'package:gemini_chat_app_tutorial/pages/messages/messages_screen.dart';
import 'package:get/get.dart';
//import 'package:hoocup/pages/feed/feed.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 60,
                color: Color.fromRGBO(255, 32, 78, 1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to HooCup!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You\'re all set to start your journey! We\'ll notify you about new matches, messages, and exciting updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
  _buildFeatureItem(
    icon: Icons.favorite,
    title: 'New Matches',
    description: 'Get notified when someone likes your profile',
    onTap: () {

            Get.toNamed('/feed');
    },
  ),
  const SizedBox(height: 16),
  _buildFeatureItem(
    icon: Icons.chat_bubble_outline,
    title: 'Messages',
    description: 'Never miss a conversation with your matches',
    onTap: () {

   Get.toNamed('/messages');
    },
  ),
  const SizedBox(height: 16),
  _buildFeatureItem(
    icon: Icons.update,
    title: 'Updates',
    description: 'Stay informed about new features and events',
    onTap: () {
     Get.snackbar(
      'Coming Soon',
      'Stay tuned for the latest updates and features!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
      // Get.to(UpdatesScreen());
    },
  ),
],

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 32, 78, 1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromRGBO(255, 32, 78, 1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
      )
    );
  }
} 