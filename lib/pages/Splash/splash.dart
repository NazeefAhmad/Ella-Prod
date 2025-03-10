// lib/pages/Splash/splash.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomePage after delay
    Future.delayed(const Duration(seconds: 1), () {
      Get.offNamed('/onboarding');
    }
    
    );

    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Your splash screen content - logo, app name, etc.
            Text(
              'Ella.AI',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
             Text(
              'Splash Screen ',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}