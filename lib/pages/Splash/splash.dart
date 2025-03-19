import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:device_info_plus/device_info_plus.dart';  // For device info
import 'package:gemini_chat_app_tutorial/consts.dart';  // Your constants file
import 'package:android_id/android_id.dart';  // For Android ID

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String deviceId = 'Fetching...';
  String deviceFingerprint = 'Fetching...';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getDeviceInfo(); // Fetch device info when dependencies change
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/onboarding');
    });
  }

  // Function to get the device ID and fingerprint
  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    const androidIdPlugin = AndroidId();

    String id = 'Unknown';
    String fingerprint = 'Unknown';

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? 'Unknown Device ID';  // iOS-specific device ID
      } else if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = await androidIdPlugin.getId() ?? 'Unknown Device ID';  // Android ID as device ID
        fingerprint = androidInfo.fingerprint ?? 'Unknown Fingerprint';  // Android fingerprint
      }
    } catch (e) {
      print("Error fetching device info: $e");
    }

    // Save the device ID and fingerprint in your constants
    AppConstants.deviceId = id;
    AppConstants.deviceFingerprint = fingerprint;

    setState(() {
      deviceId = id;
      deviceFingerprint = fingerprint;
    });

    print("📱 Device ID: $deviceId");
    print("🔍 Device Fingerprint: $deviceFingerprint");
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
                'Device ID: $deviceId',  // Display device ID
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            if (deviceFingerprint != 'Fetching...')
              Text(
                'Fingerprint: $deviceFingerprint',  // Display device fingerprint
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
