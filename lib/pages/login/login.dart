import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gemini_chat_app_tutorial/services/auth_service.dart';
import 'package:gemini_chat_app_tutorial/services/api_service.dart';  // Adjust the path as needed



class LoginPage extends StatelessWidget {
   LoginPage({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();  // Instantiate AuthService


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sign up with Google button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.blue, // Google sign-in button color
                ),
                onPressed: () async {
                  // Call signInWithGoogle() from AuthService
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    // Navigate to the Username page
                    Get.toNamed('/username');
                  } else {
                    // Show error message if sign-in fails
                    Get.snackbar("Error", "Google Sign-In failed. Please try again.");
                  }
                },
                child: const Text(
                  'Sign Up with Google',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              // Continue as Guest button
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 60),
              //     backgroundColor: Colors.grey, // Guest button color
              //   ),
              //   onPressed: () {
              //     // Navigate to the Username page as a guest
              //     Get.toNamed('/username');
              //   },
              //   child: const Text(
              //     'Continue as Guest',
              //     style: TextStyle(fontSize: 18),
              //   ),
              // ),
            
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 60),
    backgroundColor: Colors.grey, // Guest button color
  ),
  onPressed: () async {
    // Create an instance of ApiService using baseUrl from AppConstants
    final apiService = ApiService();

    try {
      // Call continueAsGuest which handles the API logic
       apiService.continueAsGuest();

      // After the API call is successful, navigate to the username page
      Get.toNamed('/username');
    } catch (e) {
      // Handle any error that occurs in the API call
      print('Error: $e');
      // You can also show an error message in the UI if needed (e.g., using a SnackBar)
    }
  },
  child: const Text(
    'Continue as Guest',
    style: TextStyle(fontSize: 18),
  ),
),


            ],
          ),
        ),
      ),
    );
  }
}
