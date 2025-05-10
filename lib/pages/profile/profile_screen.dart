import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import '../bottomNavigation/bottom_navigation.dart';
import 'account_settings_screen.dart';
import 'additional_resources_screen.dart';
import '../User_Interest/UserInterest.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _defaultNetworkImage;
  final List<String> _defaultImages = [
    'https://picsum.photos/200',
    'https://picsum.photos/201',
    'https://picsum.photos/202',
    'https://picsum.photos/203',
    'https://picsum.photos/204',
  ];

  @override
  void initState() {
    super.initState();
    _setRandomDefaultImage();
  }

  void _setRandomDefaultImage() {
    final random = Random();
    _defaultNetworkImage = _defaultImages[random.nextInt(_defaultImages.length)];
  }

  Future<void> _launchStore() async {
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/apps/details?id=com.hoocup.app');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/app/hoocup/id1234567890'); // Replace with your actual App Store ID
    } else {
      return;
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch store URL');
    }
  }

  Widget _buildSettingsItem(String title, {IconData? icon, String? iconPath, required VoidCallback onTap}) {
    return ListTile(
      leading: iconPath != null
          ? Image.asset(
              iconPath,
              width: 24,
              height: 24,
            )
          : Icon(icon, color: Colors.grey[700], size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: _defaultNetworkImage != null
                        ? DecorationImage(
                            image: NetworkImage(_defaultNetworkImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _defaultNetworkImage == null
                      ? const Center(
                          child: Text(
                            'AB',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 32, 78, 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AkaBatman',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'The Dark Knight of Conversations',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                // Edit Profile Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingsItem(
                  'Account Settings',
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  'Change Preference',
                  iconPath: 'assets/icons/gender_pref.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserInterestPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  'Notifications',
                  icon: Icons.notifications_none,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  'Rate our App',
                  icon: Icons.star_border,
                  onTap: _launchStore,
                ),
                _buildSettingsItem(
                  'Additional Resources',
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdditionalResourcesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
    );
  }
} 