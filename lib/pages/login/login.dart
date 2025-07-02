import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/auth_service.dart';
// Adjust the path as needed
import '../../widgets/loading_dialog.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthService _authService = AuthService();  // Instantiate AuthService

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
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth * 0.8; // Making the pink area square-ish
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with flame icon and "Skip" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icons/fire.gif',
                            height: 33, // same size as your previous icon
                            width: 24,
                            fit: BoxFit.cover, // optional, makes it look better inside the container
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Hey There, Hotshot!",
                          style: TextStyle(
                            fontSize: 22,
                            color: Color.fromRGBO(152, 152, 152, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to next screen or perform skip action
                        Get.toNamed('/feed');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(241,241,241,1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Main text
                const Text(
                  "Flirt fearlessly and\nfeel the connection",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Pink image container with logo
                Container(
                  width: double.infinity,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 219, 227, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/login/login_girls.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: imageHeight,
                    ),
                  ),
                ),
                
                const SizedBox(height: 95),
                
                // "Sign in with Google" button - using your existing functionality
                GestureDetector(
                  onTap: () => _handleGoogleSignIn(context),
                  child: Container(
                    width: double.infinity,
                    height: 57,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade400),
                      borderRadius: BorderRadius.circular(8),
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
                
                const SizedBox(height: 16),
                
                // "or" text
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color.fromRGBO(161, 161, 161, 0.502),
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "or",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color.fromRGBO(161, 161, 161, 0.502),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // "Continue as Guest" button
                GestureDetector(
                  onTap: () => _handleGuestSignIn(context),
                  child: Container(
                    width: double.infinity,
                    height: 57,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "Continue as Guest",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}