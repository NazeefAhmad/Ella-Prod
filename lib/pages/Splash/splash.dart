import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/services/auth_service.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'dart:io' show Platform;

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
    String fetchedDeviceId = 'Unknown';
    String fetchedDeviceFingerprint = 'Unknown';

    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        fetchedDeviceId = iosInfo.identifierForVendor ?? 'Unknown-iOS-ID';
        fetchedDeviceFingerprint = 'iOS-Fingerprint-NotAvailable'; 
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        fetchedDeviceId = await androidIdPlugin.getId() ?? 'Unknown-Android-ID';
        fetchedDeviceFingerprint = androidInfo.fingerprint ?? 'Unknown-Android-Fingerprint';
      }
    } catch (e) {
      print("Error fetching device info: $e");
      fetchedDeviceId = 'ErrorFetchingID';
      fetchedDeviceFingerprint = 'ErrorFetchingFingerprint';
    }

    AppConstants.deviceId = fetchedDeviceId;
    AppConstants.deviceFingerprint = fetchedDeviceFingerprint;
    print("📱 Device ID: ${AppConstants.deviceId}");
    print("🔍 Device Fingerprint: ${AppConstants.deviceFingerprint}");
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
