import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/services/auth_service.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  Future<void> _fetchAndSetDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    const androidIdPlugin = AndroidId();
    String fetchedDeviceId = '';
    String fetchedDeviceFingerprint = '';
    final prefs = await SharedPreferences.getInstance();

    try {
      print("📱 Starting device info fetch...");
      
      // Try to get stored values first
      fetchedDeviceId = prefs.getString('device_id') ?? '';
      fetchedDeviceFingerprint = prefs.getString('device_fingerprint') ?? '';
      
      print("📱 Initial stored values - Device ID: $fetchedDeviceId, Fingerprint: $fetchedDeviceFingerprint");

      // If we don't have stored values, fetch them
      if (fetchedDeviceId.isEmpty || fetchedDeviceFingerprint.isEmpty) {
        print("📱 No stored values found, fetching new device info...");
        if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          fetchedDeviceId = iosInfo.identifierForVendor ?? '';
          fetchedDeviceFingerprint = iosInfo.identifierForVendor ?? ''; // Use identifierForVendor for both on iOS
          print("📱 iOS Device Info - ID: $fetchedDeviceId, Fingerprint: $fetchedDeviceFingerprint");
        } else if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          fetchedDeviceId = await androidIdPlugin.getId() ?? '';
          fetchedDeviceFingerprint = androidInfo.fingerprint ?? '';
          print("📱 Android Device Info - ID: $fetchedDeviceId, Fingerprint: $fetchedDeviceFingerprint");
        }

        // Only store if we got valid values
        if (fetchedDeviceId.isNotEmpty && fetchedDeviceFingerprint.isNotEmpty) {
          await prefs.setString('device_id', fetchedDeviceId);
          await prefs.setString('device_fingerprint', fetchedDeviceFingerprint);
          print("📱 Stored new values in SharedPreferences");
        } else {
          print("❌ Failed to get valid device info");
        }
      }
    } catch (e) {
      print("❌ Error fetching device info: $e");
      fetchedDeviceId = '';
      fetchedDeviceFingerprint = '';
    }

    // Set the values in AppConstants
    AppConstants.deviceId = fetchedDeviceId;
    AppConstants.deviceFingerprint = fetchedDeviceFingerprint;
    print("📱 Final values set in AppConstants - Device ID: ${AppConstants.deviceId}");
    print("🔍 Final values set in AppConstants - Device Fingerprint: ${AppConstants.deviceFingerprint}");
  }

  Future<void> _initAppAndNavigate() async {
    await _fetchAndSetDeviceInfo(); // Fetch device info first

    bool isAuthenticated = false;
    try {
      isAuthenticated = await _authService.isAuthenticated();
    } catch (e) {
      print("Error checking authentication: $e");
      // Assume not authenticated if error occurs
    }

    // This ensures navigation happens after the 3-second splash duration
    if (isAuthenticated) {
      Get.offAllNamed('/feed');
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Your animation duration
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

    // Original 3-second delay before navigating
    Future.delayed(const Duration(seconds: 3), () {
      _initAppAndNavigate(); // Call our new method here
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Your original background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/splash/hoocup_splash.png', // Your original image
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
