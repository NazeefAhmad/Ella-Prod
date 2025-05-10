// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
// // import 'package:device_info_plus/device_info_plus.dart';  // For device info
// // import 'package:gemini_chat_app_tutorial/consts.dart';  // Your constants file
// // import 'package:android_id/android_id.dart';  // For Android ID

// // class SplashPage extends StatefulWidget {
// //   const SplashPage({Key? key}) : super(key: key);

// //   @override
// //   State<SplashPage> createState() => _SplashPageState();
// // }

// // class _SplashPageState extends State<SplashPage> {
// //   String deviceId = 'Fetching...';
// //   String deviceFingerprint = 'Fetching...';

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     _getDeviceInfo(); // Fetch device info when dependencies change
// //     Future.delayed(const Duration(seconds: 3), () {
// //       Get.offNamed('/onboarding');
// //     });
// //   }

// //   // Function to get the device ID and fingerprint
// //   Future<void> _getDeviceInfo() async {
// //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
// //     const androidIdPlugin = AndroidId();

// //     String id = 'Unknown';
// //     String fingerprint = 'Unknown';

// //     try {
// //       if (Theme.of(context).platform == TargetPlatform.iOS) {
// //         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
// //         id = iosInfo.identifierForVendor ?? 'Unknown Device ID';  // iOS-specific device ID
// //       } else if (Theme.of(context).platform == TargetPlatform.android) {
// //         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
// //         id = await androidIdPlugin.getId() ?? 'Unknown Device ID';  // Android ID as device ID
// //         fingerprint = androidInfo.fingerprint ?? 'Unknown Fingerprint';  // Android fingerprint
// //       }
// //     } catch (e) {
// //       print("Error fetching device info: $e");
// //     }

// //     // Save the device ID and fingerprint in your constants
// //     AppConstants.deviceId = id;
// //     AppConstants.deviceFingerprint = fingerprint;

// //     setState(() {
// //       deviceId = id;
// //       deviceFingerprint = fingerprint;
// //     });

// //     print("📱 Device ID: $deviceId");
// //     print("🔍 Device Fingerprint: $deviceFingerprint");
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.blue,  // Splash screen background color
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             const Icon(
// //               Icons.account_circle,  // Placeholder for logo or app icon
// //               size: 100,
// //               color: Colors.white,
// //             ),
// //             const SizedBox(height: 20),
// //             const Text(
// //               'Ella.AI',
// //               style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
// //             ),
// //             const SizedBox(height: 20),
// //             const Text(
// //               'Connecting you to AI',
// //               style: TextStyle(fontSize: 20, color: Colors.white),
// //             ),
// //             const SizedBox(height: 20),
// //             const CircularProgressIndicator(
// //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //             ),
// //             const SizedBox(height: 20),
// //             if (deviceId != 'Fetching...') 
// //               Text(
// //                 'Device ID: $deviceId',  // Display device ID
// //                 style: TextStyle(fontSize: 16, color: Colors.white),
// //               ),
// //             if (deviceFingerprint != 'Fetching...')
// //               Text(
// //                 'Fingerprint: $deviceFingerprint',  // Display device fingerprint
// //                 style: TextStyle(fontSize: 16, color: Colors.white),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../config/responsive_config.dart';
// import '../../config/theme_config.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({Key? key}) : super(key: key);

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();

//     // Navigate to next screen after animation
//     Future.delayed(const Duration(seconds: 3), () {
//       Get.offNamed('/onboarding');
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0C0C23),
//       body: SafeArea(
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Logo
//                       Container(
//                         width: ResponsiveConfig.isMobile(context) ? 120 : 150,
//                         height: ResponsiveConfig.isMobile(context) ? 120 : 150,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 20,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.chat_bubble_outline,
//                             size: 80,
//                             color: Color.fromRGBO(255, 32, 78, 1),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       // App Name
//                       Text(
//                         'Ella.AI',
//                         style: AppTheme.getResponsiveTextStyle(
//                           context,
//                           fontSize: ResponsiveConfig.getTitleFontSize(context) * 1.5,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Tagline
//                       Text(
//                         'Connecting you to AI',
//                         style: AppTheme.getResponsiveTextStyle(
//                           context,
//                           fontSize: ResponsiveConfig.getBodyFontSize(context),
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       // Loading Indicator
//                       const CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Color.fromRGBO(255, 32, 78, 1),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/splash/hoocup_splash.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
