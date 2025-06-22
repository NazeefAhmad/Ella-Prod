import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/pages/PersonalDetail/age.dart';
import 'package:hoocup/services/profile_service.dart';
import 'package:hoocup/services/auth_service.dart';
import '../../widgets/back_button.dart';
import '../../widgets/sign_in_dialog.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuestUser = false;
  String? _guestUsername;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _checkUserType());
    }
  }

  Future<void> _checkUserType() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      
      // Check if user is a guest by looking at firebase_uid
      final isGuest = profile['firebase_uid']?.toString().startsWith('guest_') ?? false;
      
      setState(() {
        _isGuestUser = isGuest;
        // Set username from profile if it exists
        final username = profile['username'];
        if (username != null && username.isNotEmpty) {
          _usernameController.text = username;
        } else if (isGuest) {
          _guestUsername = profile['full_name'];
          _usernameController.text = _guestUsername ?? '';
        }
      });
    } catch (e) {
      print('Error checking user type: $e');
      if (!mounted) return;
      
      Get.snackbar(
        'Error',
        'Failed to load user information. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isGuestUser) {
      // For guest users, just proceed to next screen
      Get.to(() => const AgePage());
      return;
    }

    if (_usernameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a username';
      });
      return;
    }

    _clearError();
    setState(() {
      _isLoading = true;
    });

    try {
      // Only update username if it has changed
      final currentUsername = await _profileService.getUserProfile().then((profile) => profile['username']);
      if (currentUsername != _usernameController.text) {
        await _profileService.updateUsername(_usernameController.text);
      }
      
      if (!mounted) return;
      Get.to(() => const AgePage());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignIn() {
    SignInDialog.show(
      context: context,
      authService: _authService,
      onSignInSuccess: () async {
        if (mounted) {
          Navigator.of(context).pop();
          // Reload state to reflect new user
          _isInitialized = false;
          await _checkUserType();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "What Should We Call You?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Your AI match should\nknow your name",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 32, 78, 1)),
                  ),
                )
              else ...[
                TextField(
                  controller: _usernameController,
                  onChanged: (_) => _clearError(),
                  enabled: !_isGuestUser ? true : false,
                  readOnly: _isGuestUser,
                  decoration: InputDecoration(
                    hintText: _isGuestUser ? (_guestUsername ?? 'Loading...') : "John Doe",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(color: Colors.red),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                if (_isGuestUser) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _handleSignIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sign in to set your own username',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 32, 78, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const Spacer(),
              Container(
                width: 250,
                height: 59,
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isGuestUser ? "Continue" : "Continue",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}