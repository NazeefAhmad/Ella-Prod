import 'package:flutter/material.dart';
import 'dart:io' show Platform, File;
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../bottomNavigation/bottom_navigation.dart';
import 'account_settings_screen.dart';
import 'additional_resources_screen.dart';
import '../User_Interest/UserInterest.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';
import '../../widgets/back_button.dart';

// Shimmer Placeholder Widget
class ProfileShimmerPlaceholder extends StatelessWidget {
  const ProfileShimmerPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for placeholder
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50), // Profile picture placeholder
            const SizedBox(height: 16),
            Container(width: 150, height: 24, color: Colors.white), // Username placeholder
            const SizedBox(height: 8),
            Container(width: 200, height: 16, color: Colors.white), // Bio placeholder
            const SizedBox(height: 30),
            Container( 
              width: double.infinity, 
              height: 50, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              )
            ), 
            
                 SizedBox(height: 20,),
                      Divider(height: 1,),
            const SizedBox(height: 20),
            _buildShimmerListItem(),
            _buildShimmerListItem(),
            _buildShimmerListItem(),
            _buildShimmerListItem(),
            _buildShimmerListItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerListItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          Container(width: 24, height: 24, color: Colors.grey[300]), // Icon placeholder
          const SizedBox(width: 16),
          Expanded(child: Container(height: 16, color: Colors.grey[300])), // Text placeholder
          const SizedBox(width: 16),
          Container(width: 16, height: 16, color: Colors.grey[300]), // Chevron placeholder
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _defaultNetworkImage;
  String? _profileImagePath;
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile({bool forceRefresh = false}) async {
    try {
      setState(() => _isLoading = true);
      
      final results = await Future.wait([
        _profileService.getUserProfile(forceRefresh: forceRefresh),
        _profileService.getProfilePicture(forceRefresh: forceRefresh),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final profilePicture = results[1] as String?;
      
      print('Fetched profile data: $profile');
      print('Fetched profile picture: $profilePicture');
      
      if (!mounted) return;
      
      final isGuest = profile['is_guest'] ?? false;
      
      setState(() {
        _isGuestUser = isGuest;
        _guestUsername = profile['username'] ?? '';
        _userBio = profile['bio'] ?? '';
        _userEmail = profile['email'] ?? '';
        _userGender = profile['gender'] ?? '';
        _userDob = profile['date_of_birth'] != null 
            ? DateTime.parse(profile['date_of_birth']).toString().split(' ')[0] 
            : '';
        
        if (_profileImagePath == null) {
          _defaultNetworkImage = profilePicture;
        }
        
        print('Profile data after setState:');
        print('Username: $_guestUsername');
        print('Bio: $_userBio');
        print('Email: $_userEmail');
        print('Gender: $_userGender');
        print('DOB: $_userDob');
        print('Profile Picture: $_defaultNetworkImage');
        
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

  String _getRandomDefaultImage() {
    final random = Random();
    return _defaultImages[random.nextInt(_defaultImages.length)];
  }

  bool _isHttpUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  ImageProvider? _getImageProvider(String? localPath, String? networkUrl) {
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (networkUrl != null && networkUrl.isNotEmpty) {
      if (_isHttpUrl(networkUrl)) {
        return NetworkImage(networkUrl);
      } else {
        final file = File(networkUrl);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }
    }
    return null;
  }

  Future<void> _pickAndUpdateImage() async {
    if (_isGuestUser) {
      _showSignInDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });

        try {
          await _profileService.updateProfilePicture(image.path);
          await _loadUserProfile(forceRefresh: true);
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _profileImagePath = null;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    await _loadUserProfile(forceRefresh: true);
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
    ImageProvider? currentImageProvider = _getImageProvider(_profileImagePath, _defaultNetworkImage);

    return Scaffold(
      extendBody: true, // allows bottom nav to float over body
      backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 101,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isLoading
                ? const ProfileShimmerPlaceholder(key: ValueKey('shimmer'))
                : SafeArea(
                    key: const ValueKey('profile'),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: _pickAndUpdateImage,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 72,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: currentImageProvider,
                                    child: currentImageProvider == null
                                        ? const Text(
                                            'AB',
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                    onBackgroundImageError: currentImageProvider != null
                                        ? (_, __) {
                                            if (mounted) {
                                              setState(() {
                                                _defaultNetworkImage = null;
                                                _profileImagePath = null;
                                              });
                                            }
                                          }
                                        : null,
                                  ),
                                  if (!_isGuestUser)
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromRGBO(255, 32, 78, 1),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _guestUsername ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _isGuestUser ? 'Guest Account' : (_userBio?.isNotEmpty == true ? _userBio! : 'No bio yet'),
                            style: const TextStyle(color: Colors.grey, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      _isGuestUser ? Icons.login : Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    label: Text(_isGuestUser ? 'Sign in to edit profile' : 'Edit Profile'),
                                    onPressed: _isGuestUser
                                        ? _showSignInDialog
                                        : () async {
                                            await Get.toNamed('/editProfile');
                                            _loadUserProfile(forceRefresh: true);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isGuestUser
                                          ? const Color.fromRGBO(255, 32, 78, 1)
                                          : Colors.grey[200],
                                      foregroundColor: _isGuestUser ? Colors.white : Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Divider(),
                                const SizedBox(height: 30),
                                _buildSettingsItem('Account Settings',
                                  icon: Icons.person_outline,
                                  onTap: _isGuestUser ? _showSignInDialog : () {
                                    Get.toNamed('/accountSettings');
                                  },
                                ),
                                _buildSettingsItem('Change Preference',
                                  iconPath: 'assets/icons/gender_pref.png',
                                  onTap: _isGuestUser ? _showSignInDialog : () {
                                    Get.toNamed('/changePref');
                                  },
                                ),
                                _buildSettingsItem('Notifications',
                                  icon: Icons.notifications_none,
                                  onTap: _isGuestUser ? _showSignInDialog : () {
                                    Get.toNamed('/notifications');
                                  },
                                ),
                                _buildSettingsItem('Rate our App',
                                  icon: Icons.star_border,
                                  onTap: _launchStore,
                                ),
                                _buildSettingsItem('Additional Resources',
                                  icon: Icons.info_outline,
                                  onTap: () {
                                    Get.toNamed('/additionalResources');
                                  },
                                ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Bottom navigation overlay
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: BottomNavigation(selectedIndex: 2),
            ),
          ),
        ],
      ),
    );
  }
}