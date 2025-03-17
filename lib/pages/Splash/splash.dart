// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
// import 'package:device_info_plus/device_info_plus.dart';  // Import the package

// class SplashPage extends StatefulWidget {
//   const SplashPage({Key? key}) : super(key: key);

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   String deviceId = '';

//   @override
//   void initState() {
//     super.initState();
//     _getDeviceId();
//     // Navigate to OnboardingPage after a delay
//     Future.delayed(const Duration(seconds: 3), () {
//       Get.offNamed('/onboarding');
//     });
//   }

//   // Function to get the device ID
//   Future<void> _getDeviceId() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     String id = '';
    
//     // Check for the platform and get device ID accordingly
//     if (Theme.of(context).platform == TargetPlatform.iOS) {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       id = iosInfo.identifierForVendor ?? 'Unknown Device ID';  // iOS specific device ID
//     } else if (Theme.of(context).platform == TargetPlatform.android) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       id = androidInfo.fingerprint ?? 'Unknown Device ID';  // Android specific device ID
//     }

//     setState(() {
//       deviceId = id;
//     });

//     print("Device ID: $deviceId");  // Print the device ID to console for debugging purposes
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,  // Change the background color if needed
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.account_circle,  // Placeholder for logo or app icon
//               size: 100,
//               color: Colors.white,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Ella.AI',
//               style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Connecting you to AI',
//               style: TextStyle(fontSize: 20, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             const CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Device ID: $deviceId',  // Displaying the device ID on the splash page
//               style: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:device_info_plus/device_info_plus.dart';  // Import the package

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String deviceId = 'Fetching...';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getDeviceId();  // Get device ID when the dependencies change (after context is available)
    // Navigate to OnboardingPage after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/onboarding');
    });
  }

  // Function to get the device ID
  Future<void> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String id = '';
    
      // Check platform and get device ID accordingly
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? 'Unknown Device ID';  // iOS specific device ID
      } else if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.fingerprint ?? 'Unknown Device ID';  // Android specific device ID
      }

      setState(() {
        deviceId = id;
      });

      print("Device ID: $deviceId");  // Log the device ID for debugging
    } catch (e) {
      print("Error fetching device ID: $e");
      setState(() {
        deviceId = 'Failed to get device ID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,  // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,  // Placeholder for logo or app icon
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ella.AI',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connecting you to AI',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            if (deviceId != 'Fetching...') 
              Text(
                'Device ID: $deviceId',  // Display device ID on splash page (optional for debugging)
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
