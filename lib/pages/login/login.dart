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
                        // Container(
                        //   padding: const EdgeInsets.all(4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.orange,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                        // ),
Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
   // color: Colors.orange,
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
                // Container(
                //   width: double.infinity,
                //   height: imageHeight,
                //   decoration: BoxDecoration(
                //     color: Color.fromRGBO(255, 219, 227, 1),
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   // child: Center(
                //   //   child: Container(
                //   //     width: 40,
                //   //     height: 40,
                //   //     decoration: BoxDecoration(
                //   //       color: Colors.purple.shade800,
                //   //       shape: BoxShape.circle,
                //   //       boxShadow: [
                //   //         BoxShadow(
                //   //           color: Colors.black.withOpacity(0.3),
                //   //           spreadRadius: 1,
                //   //           blurRadius: 2,
                //   //           offset: const Offset(0, 1),
                //   //         ),
                //   //       ],
                //   //     ),
                //   //     child: const Center(
                //   //       child: Text(
                //   //         "E",
                //   //         style: TextStyle(
                //   //           color: Colors.white,
                //   //           fontWeight: FontWeight.bold,
                //   //           fontSize: 20,
                //   //         ),
                //   //       ),
                //   //     ),
                //   //   ),
                //   // ),
                // ),
                
                 const SizedBox(height: 4),

Container(
  width: double.infinity,
  height: imageHeight,
  decoration: BoxDecoration(
    color: Color.fromRGBO(255, 219, 227, 1),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: SingleChildScrollView( // So chat can scroll
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message 1 (Emma starting flirty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/girls/Emma.jpg'),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Lying in bed... wearing almost nothing 👀",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message 2 (you reply teasing)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Damn... now how do you expect me to concentrate? 🔥",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text('E', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message 3 (Emma goes naughtier)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/girls/Emma.jpg'),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Imagine my hands missing your touch... and my lips craving yours 😈",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message 4 (you reply hotter)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "If I was there... trust me baby, you'd forget what breathing feels like 👅💦",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text('E', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message 5 (Emma teasing harder)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/girls/Emma.jpg'),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Mmm I dare you to pin me down and make me yours tonight 💋😈",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message 6 (you ending with heat)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Baby, once I have you... there will be no escape tonight 💕🔥",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text('E', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          // Message 7 (Emma teasing playfully)
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage('assets/girls/Emma.jpg'),
    ),
    SizedBox(width: 8),
    Flexible(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Text(
          "Can't stop thinking about your smile... and what else you could be hiding 😏",
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  ],
),
SizedBox(height: 16),

// Message 8 (You replying with charm)
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Flexible(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.greenAccent.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Text(
          "Hmm, just imagining what else you're hiding... 😘",
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
    SizedBox(width: 8),
    CircleAvatar(
      backgroundColor: Colors.purple,
      child: Text('E', style: TextStyle(color: Colors.white)),
    ),
  ],
),
SizedBox(height: 16),

// Message 9 (Emma playing coy)
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     CircleAvatar(
//       radius: 20,
//       backgroundImage: AssetImage('assets/girls/Emma.jpg'),
//     ),
//     SizedBox(width: 8),
//     Flexible(
//       child: Container(
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           "What if I told you I was thinking about you... in ways I probably shouldn't be 😏",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     ),
//   ],
// ),
// SizedBox(height: 16),

// // Message 10 (You responding with flirt)
// Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Flexible(
//       child: Container(
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.greenAccent.shade100,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//             bottomLeft: Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           "I’m guessing those thoughts are making you smile, aren’t they? 😏💖",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     ),
//     SizedBox(width: 8),
//     CircleAvatar(
//       backgroundColor: Colors.purple,
//       child: Text('E', style: TextStyle(color: Colors.white)),
//     ),
//   ],
// ),
// SizedBox(height: 16),

// // Message 11 (Emma gets bolder)
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     CircleAvatar(
//       radius: 20,
//       backgroundImage: AssetImage('assets/girls/Emma.jpg'),
//     ),
//     SizedBox(width: 8),
//     Flexible(
//       child: Container(
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           "I’d love to see that smirk of yours in person... Maybe soon? 😉💋",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     ),
//   ],
// ),
SizedBox(height: 16),

        ],
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