// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:gemini_chat_app_tutorial/services/auth_service.dart';
// import 'package:gemini_chat_app_tutorial/services/api_service.dart';  // Adjust the path as needed



// class LoginPage extends StatelessWidget {
//    LoginPage({Key? key}) : super(key: key);

//   final AuthService _authService = AuthService();  // Instantiate AuthService


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Sign up with Google button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 60),
//                   backgroundColor: Colors.blue, // Google sign-in button color
//                 ),
//                 onPressed: () async {
//                   // Call signInWithGoogle() from AuthService
//                   User? user = await _authService.signInWithGoogle();
//                   if (user != null) {
//                     // Navigate to the Username page
//                     Get.toNamed('/username');
//                   } else {
//                     // Show error message if sign-in fails
//                     Get.snackbar("Error", "Google Sign-In failed. Please try again.");
//                   }
//                 },
//                 child: const Text(
//                   'Sign Up with Google',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//               const SizedBox(height: 20),
          
            
//             ElevatedButton(
//   style: ElevatedButton.styleFrom(
//     minimumSize: const Size(double.infinity, 60),
//     backgroundColor: Colors.grey, // Guest button color
//   ),
//  // In the ElevatedButton onPressed handler, modify it to:
// onPressed: () async {
//   final apiService = ApiService();

//   try {
//     // Add await here to ensure the API call completes
//     await apiService.continueAsGuest();
    
//     // Only navigate after successful API call
//     Get.toNamed('/username');
//   } catch (e) {
//     print('Error: $e');
//     // Add user feedback
//     Get.snackbar('Error', 'Failed to continue as guest: $e',
//       snackPosition: SnackPosition.BOTTOM);
//   }
// },
//   child: const Text(
//     'Continue as Guest',
//     style: TextStyle(fontSize: 18),
//   ),
// ),


//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth * 0.8; // Making the pink area square-ish
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
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
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Hey There, Hotshot!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to next screen or perform skip action
                        Get.toNamed('/username');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
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
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade800,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "E",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // "Sign in with Google" button - using your existing functionality
                GestureDetector(
                  onTap: () async {
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
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
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
                const Center(
                  child: Text(
                    "or",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // "Continue as Guest" button - using your existing functionality
                GestureDetector(
                  onTap: () async {
                    final apiService = ApiService();

                    try {
                      // Add await here to ensure the API call completes
                      await apiService.continueAsGuest();
                      
                      // Only navigate after successful API call
                      Get.toNamed('/username');
                    } catch (e) {
                      print('Error: $e');
                      // Add user feedback
                      Get.snackbar('Error', 'Failed to continue as guest: $e',
                        snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
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