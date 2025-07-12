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

class _UsernamePageState extends State<UsernamePage> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuestUser = false;
  String? _guestUsername;
  bool _isInitialized = false;
  bool _showHelperText = false;

  late AnimationController _emojiController;
  late Animation<Offset> _emojiOffsetAnimation;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showHelperText = true);
    });

    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _emojiOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(CurvedAnimation(
      parent: _emojiController,
      curve: Curves.easeInOut,
    ));

    _startEmojiBounceLoop();
  }

  void _startEmojiBounceLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await _emojiController.forward();
        await _emojiController.reverse();
      }
    }
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
    setState(() => _isLoading = true);

    try {
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      final isGuest = profile['firebase_uid']?.toString().startsWith('guest_') ?? false;

      setState(() {
        _isGuestUser = isGuest;
        final username = profile['username'];
        if (username != null && username.isNotEmpty) {
          _usernameController.text = username;
        } else if (isGuest) {
          _guestUsername = profile['full_name'];
          _usernameController.text = _guestUsername ?? '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'Failed to load user information. Please try again.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(username);
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.black, fontSize: 14)),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
  }

  Future<void> _handleSubmit() async {
    if (_isGuestUser) {
      Get.to(() => const AgePage());
      return;
    }

    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      setState(() => _errorMessage = 'Please enter a username');
      return;
    }
    if (!isValidUsername(newUsername)) {
      showSnackbar(context, '⚠️ Whoops! Usernames can only have letters, numbers, and underscores.');
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    _clearError();
    setState(() => _isLoading = true);
    try {
      final currentUsername = await _profileService.getUserProfile().then((p) => p['username']);
      if (currentUsername != newUsername) {
        await _profileService.updateUsername(newUsername);
      }
      if (mounted) Get.to(() => const AgePage());
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSignIn() {
    SignInDialog.show(
      context: context,
      authService: _authService,
      onSignInSuccess: () async {
        if (mounted) {
          Navigator.of(context).pop();
          _isInitialized = false;
          await _checkUserType();
        }
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emojiController.dispose();
    super.dispose();
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
            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)))),
            const SizedBox(width: 8),
            Container(width: 80, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 8),
            Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text("What Should We Call You?", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 24),
              const Text("Your AI match should\nknow your name", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.grey)),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 32, 78, 1))))
              else ...[
                TextField(
                  controller: _usernameController,
                  onChanged: (_) => _clearError(),
                  enabled: !_isGuestUser,
                  readOnly: _isGuestUser,
                  decoration: InputDecoration(
                    hintText: _isGuestUser ? (_guestUsername ?? 'Loading...') : "John Doe",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(color: Colors.red),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSlide(
                  offset: _showHelperText ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showHelperText ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideTransition(
                          position: _emojiOffsetAnimation,
                          child: const Text('😎', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Choose your secret persona! Letters, numbers, and underscores only — no spaces or flashy symbols.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
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
                          Icon(Icons.login, color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Sign in to set your own username',
                            style: TextStyle(color: Color.fromRGBO(255, 32, 78, 1), fontSize: 16, fontWeight: FontWeight.w500),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
