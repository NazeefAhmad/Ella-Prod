import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/auth_service.dart';
import '../../widgets/loading_dialog.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  final AuthService _authService = AuthService();

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    _showLoadingDialog(context, 'Signing in with Google...');
    try {
      final user = await _authService.signInWithGoogle();
      _hideLoadingDialog(context);
      if (user != null) {
        // Check if user has a username
        final userProfile = await _authService.getUserProfile();
        if (userProfile != null && userProfile['username'] != null && userProfile['username'].toString().isNotEmpty) {
          // User has a username, navigate to feed
          Get.offAllNamed('/feed');
        } else {
          // No username, navigate to username setup
          Get.toNamed('/username');
        }
      } else {
        Get.snackbar("Error", "Google Sign-In failed. Please try again.");
      }
    } catch (e) {
      _hideLoadingDialog(context);
      Get.snackbar("Error", "Failed to sign in: $e");
    }
  }

  Future<void> _handleGuestSignIn(BuildContext context) async {
    _showLoadingDialog(context, 'Continuing as guest...');
    try {
      final success = await _authService.signInAsGuest();
      _hideLoadingDialog(context);
      if (success) {
        Get.toNamed('/username');
      } else {
        Get.snackbar('Error', 'Failed to continue as guest',
          snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      _hideLoadingDialog(context);
      Get.snackbar('Error', 'Failed to continue as guest: $e',
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen onboarding background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding/Onboarding (3).png',
              fit: BoxFit.cover,
            ),
          ),
          // Branding + Button section at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 0), // Increased from 40 to 60
          
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Added extra space before headline image
                  const SizedBox(height: 60),
                  
                  // Headline image (instead of text)
                  Image.asset(
                    'assets/images/onboarding/onboarding_text.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 25), // Increased from 55 to 75
                  
                  // Google Sign In Button
                  GestureDetector(
                    onTap: () => _handleGoogleSignIn(context),
                    child: Container(
  width: 288.17,
  height: 55.92,
  decoration: BoxDecoration(
    border: Border.all(
      color: const Color(0xFFFF204E), // FF204E at 100% opacity for the stroke
      width: 1, // Stroke width from the image
    ),
  //  color: const Color(0x1AFF204E), // FF204E at 10% opacity (1A is ~10% opacity in hex)
    borderRadius: BorderRadius.circular(18), // Border radius from the image (18)
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/icons/image 13.png',
        height: 24,
      ),
      const SizedBox(width: 8),
      const Text(
        "Sign in with Google",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),
                  ),
                  
                 // const SizedBox(height: 20), // Increased from 16 to 20
                  
                  // "or" text
                  
                  
                  const SizedBox(height: 25), // Increased from 16 to 20
                  
                  // Guest Sign In Button
                  GestureDetector(
                    onTap: () => _handleGuestSignIn(context),
                    child: Container(
                      width: double.infinity,
                    
                      decoration: BoxDecoration(
                       // color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            //color: Color(0x989898),
                              color: Color.fromRGBO(100, 100, 100, 1)
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Increased from 65 to 80
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}