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
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';

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
  bool _isGuestUser = false;
  String? _guestUsername;
  String? _userBio;
  String? _userEmail;
  String? _userGender;
  String? _userDob;
  bool _isLoading = true;
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setRandomDefaultImage();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      
      final isGuest = profile['firebase_uid']?.toString().startsWith('guest_') ?? false;
      
      setState(() {
        _isGuestUser = isGuest;
        if (isGuest) {
          _guestUsername = profile['full_name'];
        } else {
          _guestUsername = profile['full_name'];
          _userBio = profile['bio'];
          _userEmail = profile['email'];
          _userGender = profile['gender'];
          _userDob = profile['date_of_birth'];
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
      }
    }
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
      url = Uri.parse('https://apps.apple.com/app/hoocup/id1234567890');
    } else {
      return;
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch store URL');
    }
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign in Required'),
          content: const Text('Please sign in to edit your profile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _authService.signInWithGoogle();
                  if (mounted) {
                    await _loadUserProfile();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign in failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign in with Google'),
            ),
          ],
        );
      },
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                      if (!_isGuestUser)
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
                Text(
                  _guestUsername ?? 'Guest User',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isGuestUser ? 'Guest Account' : (_userBio ?? 'No bio yet'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                if (!_isGuestUser) ...[
                  const SizedBox(height: 8),
                  Text(
                    _userEmail ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  if (_userGender != null || _userDob != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [
                          if (_userGender != null) _userGender,
                          if (_userDob != null) _userDob,
                        ].join(' • '),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
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
                          onPressed: _isGuestUser
                              ? _showSignInDialog
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EditProfileScreen(),
                                    ),
                                  );
                                },
                          icon: Icon(_isGuestUser ? Icons.login : Icons.edit_outlined),
                          label: Text(_isGuestUser ? 'Sign in to Edit Profile' : 'Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isGuestUser ? const Color.fromRGBO(255, 32, 78, 1) : Colors.grey[200],
                            foregroundColor: _isGuestUser ? Colors.white : Colors.black87,
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
                        onTap: _isGuestUser
                            ? _showSignInDialog
                            : () {
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
                        onTap: _isGuestUser
                            ? _showSignInDialog
                            : () {
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
                        onTap: _isGuestUser
                            ? _showSignInDialog
                            : () {
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