import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/auth_service.dart';
import 'package:hoocup/consts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    String fcmToken = '';
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
        }
      }

      // Fetch FCM token
      try {
        print("📱 Starting FCM token fetch...");
        
        // Get the FCM token directly since Firebase is already initialized
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
        print("📱 Raw FCM Token received: $fcmToken");
        
        // Store FCM token
        if (fcmToken.isNotEmpty) {
          await prefs.setString(AppConstants.fcmtoken, fcmToken);
          // Verify the token was stored correctly
          String? storedToken = prefs.getString(AppConstants.fcmtoken);
          print("📱 Stored FCM token in SharedPreferences: $storedToken");
          print("📱 Verification - Retrieved token matches: ${storedToken == fcmToken}");
        } else {
          print("📱 Warning: Empty FCM token received");
        }

        // Set up token refresh listener
        FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
          print("📱 FCM Token Refreshed in Splash: $token");
          prefs.setString(AppConstants.fcmtoken, token);
        });
        
      } catch (e) {
        print("📱 Error getting FCM token: $e");
        print("📱 Error stack trace: ${StackTrace.current}");
      }

      // Set the device info in AppConstants
      AppConstants.deviceId = fetchedDeviceId;
      AppConstants.deviceFingerprint = fetchedDeviceFingerprint;
      
      print("📱 Final device info set in AppConstants:");
      print("Device ID: ${AppConstants.deviceId}");
      print("Device Fingerprint: ${AppConstants.deviceFingerprint}");
      print("FCM Token: $fcmToken");

    } catch (e) {
      print("📱 Error in _fetchAndSetDeviceInfo: $e");
    }
  }

  Future<void> _initAppAndNavigate() async {
    await _fetchAndSetDeviceInfo(); // Fetch device info first

    // Load user ID and username from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    AppConstants.userId = prefs.getString('user_id') ?? '';
    AppConstants.userName = prefs.getString('username') ?? '';
    print("Loaded from SharedPreferences - User ID: ${AppConstants.userId}, Username: ${AppConstants.userName}");

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
  backgroundColor: Color(0x00f1f1f1), // FF for alpha, 123456 for hex color

      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/splash/Splash.png', // Your original image
                 
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
