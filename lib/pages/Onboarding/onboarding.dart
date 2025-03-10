// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
// import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
// import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';


// class OnboardingPage extends StatefulWidget {
//   const OnboardingPage({Key? key}) : super(key: key);

//   @override
//   State<OnboardingPage> createState() => _OnboardingPageState();
// }

// class _OnboardingPageState extends State<OnboardingPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to HomePage after delay (3 seconds)
//     Future.delayed(const Duration(seconds: 100), () {
//       Get.offNamed('/login');  // Replace with your desired page (e.g. '/home')
//     });
//   }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Center(
//       child: Image.asset(
//         'assets/images/onbordings.png',
//         width: MediaQuery.of(context).size.width * 1, // Makes it responsive
//         fit: BoxFit.contain, // Adjusts for different screen sizes
//       ),
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to next page after delay
    Future.delayed(const Duration(seconds: 1000), () {
      Get.offNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // color: Color(E40F5D), // Light pink background
          color: Color.fromRGBO(239, 203, 215, 1), // Light pink background using RGBO
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: size.height * 0.05,
              right: size.width * 0.05,
              child: _buildCircle(size.width * 0.2, Colors.white.withOpacity(0.5)),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: size.width * 0.1,
              child: _buildCircle(size.width * 0.25, Colors.white.withOpacity(0.7)),
            ),
            Positioned(
              top: size.height * 0.7,
              right: size.width * 0.15,
              child: _buildCircle(size.width * 0.1, Color(0xFFFFADD4).withOpacity(0.6)),
            ),
            Positioned(
              bottom: size.height * 0.3,
              left: size.width * 0.5,
              child: _buildCircle(size.width * 0.15, Color(0xFFFFADD4).withOpacity(0.4)),
            ),
            
            // Hearts
            // Positioned(
            //   top: size.height * 0.1,
            //   right: size.width * 0.2,
            //   child: _buildHeart(size.width * 0.08, Color(0xFFFFADD4).withOpacity(0.7)),
            // ),
            Positioned(
  top: size.height * 0.3,
  right: size.width * 0.2,
  child: Image.asset(
    'assets/images/hearts/heart.png', // Make sure to use the correct path to your image
    width: size.width * 0.08,
    height: size.width * 0.08,
    fit: BoxFit.cover, // This ensures the image is scaled properly
  ),
),

Positioned(///to be done later///to be done later
  top: size.height * 0.3,
  right: size.width * 0.6,
  child: Image.asset(
    'assets/images/hearts/hearts.png', // Make sure to use the correct path to your image
    width: size.width * 0.08,
    height: size.width * 0.08,
    fit: BoxFit.cover, // This ensures the image is scaled properly
  ),
),
Positioned(//to be done later
  top: size.height * 0.68,
  right: size.width * 0.1,
  child: Image.asset(
    'assets/images/hearts/heart1.png', // Make sure to use the correct path to your image
    width: size.width * 0.08,
    height: size.width * 0.08,
    fit: BoxFit.fill, // This ensures the image is scaled properly
  ),
),
Positioned(//heart 2
  top: size.height * 0.78,
  right: size.width * 0.18,
  child: Image.asset(
    'assets/images/hearts/heart2.png', // done
    width: size.width * 0.1,
    height: size.width * 0.13,
    fit: BoxFit.fill, 
  ),
),

Positioned( //heart 3
  top: size.height * 0.75,
  right: size.width * .9,
  child: Image.asset(
    'assets/images/hearts/heart3.png', //done
    width: size.width * 0.1,
    height: size.width * 0.14,
    fit: BoxFit.fill, 
  ),
),

Positioned(//heart 4
  top: size.height * 0.91,
  right: size.width * 0.45,
  child: Image.asset(
    'assets/images/hearts/heart4.png', //done
    width: size.width * .15,
    height: size.width * .15,
    fit: BoxFit.fill,
  ),
),
Positioned( //heart 5
  top: size.height * 0.15,
  right: size.width * 0.45,
  child: Image.asset(
    'assets/images/hearts/heart5.png', // To be done later
    width: size.width * 0.15,
    height: size.width * 0.15,
    fit: BoxFit.fill, 
  ),
),
Positioned( //heart 6
  top: size.height * 0.05,
  right: size.width * 0,
  child: Image.asset(
    'assets/images/hearts/heart6.png', // Done
    width: size.width * 0.1,
    height: size.width * 0.2,
    fit: BoxFit.fill, 
  ),
),
            Positioned(
              bottom: size.height * 0.15,
              right: size.width * 0.1,
              child: _buildHeart(size.width * 0.1, Color(0xFFFFADD4).withOpacity(0.7)),
            ),
            Positioned(
              left: size.width * 0.05,
              top: size.height * 0.6,
              child: _buildHeart(size.width * 0.12, Color(0xFFFFADD4).withOpacity(0.7)),
            ),
            
            // Photo circles
            Positioned(
              top: size.height * 0.08,
              left: size.width * 0.15,
              child: _buildProfileCircle('assets/girls/Emma.jpg', size.width * 0.3),
            ),
            Positioned(
              top: size.height * 0.15,
              right: size.width * 0.1,
              child: _buildProfileCircle('assets/girls/airhostess.jpg', size.width * 0.28),
            ),
            Positioned(
              top: size.height * 0.35,
              left: size.width * 0.15,
              child: _buildProfileCircle('assets/girls/shweta.jpg', size.width * 0.28),
            ),
            Positioned(
              top: size.height * 0.45,
              right: size.width * 0.25,
              child: _buildProfileCircle('assets/girls/Emma.jpg', size.width * 0.25),
            ),
            
            // App name and tagline
            Positioned(
              bottom: size.height * 0.15,
              left: size.width * 0.1,
              child: Container(
                width: size.width * 0.6,
                height: size.height * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(size.width * 0.3),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ella AI',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                    Text(
                      'Your Dating Partner',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 20,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Let's go button
            Positioned(
              bottom: size.height * 0.06,
              right: size.width * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      "Let's go!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildHeart(double size, Color color) {
    return Icon(
      Icons.favorite,
      size: size,
      color: color,
    );
  }

  Widget _buildProfileCircle(String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}