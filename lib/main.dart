import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core import
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import 'firebase_options.dart'; // Make sure this file is generated from Firebase setup
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'pages/Splash/splash.dart';
import 'pages/Onboarding/onboarding.dart';
import 'pages/PersonalDetail/username.dart';
import 'pages/PersonalDetail/age.dart';
//import 'package:gemini_chat_app_tutorial/pages/UserInterest/UserInterest.dart';
import 'pages/chat_screen/home_page.dart';
import 'pages/feed/feed.dart';
import 'imports.dart'; // Make sure the imports file is correct
import 'app_router.dart'; // Import app_router.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'config/language_config.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'services/connectivity_service.dart';
import 'services/version_service.dart';
import 'widgets/connectivity_wrapper.dart';
import 'widgets/update_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io' show Platform;


// Add this function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();

    // Load the environment variables from the dev.env file
    await dotenv.load(fileName: "dev.env");

    // Initialize Firebase with better error handling
    print("🔥 Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");

    // Initialize Firebase Messaging
    try {
      print("📱 Initializing Firebase Messaging...");
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission for iOS
      if (Platform.isIOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Get FCM token
      String? token = await messaging.getToken();
      print("📱 Initial FCM Token: $token");

      // Store the token in SharedPreferences
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmtoken', token);
        print("📱 Stored initial FCM token in SharedPreferences");
      }

      // Listen to token refresh
      messaging.onTokenRefresh.listen((String token) async {
        print("📱 FCM Token Refreshed: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmtoken', token);
        print("📱 Updated FCM token in SharedPreferences");
      });
      
      print("✅ Firebase Messaging initialized successfully");
    } catch (e) {
      print('❌ Firebase Messaging initialization error: $e');
    }

  } catch (e) {
    print('❌ Initialization error: $e');
    // Don't crash the app, but log the error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final languageController = Get.put(LanguageController());
    final versionService = VersionService();

    return MultiProvider(
      providers: [
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<VersionService>(
          create: (_) => versionService,
        ),
      ],
      child: GetMaterialApp(
        title: 'Ella A.I',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        translations: LanguageConfig(),
        locale: languageController.getLocale(languageController.currentLanguage.value),
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: '/',
        getPages: AppRouter.routes,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: ConnectivityWrapper(
              child: VersionCheckWrapper(
                versionService: versionService,
                child: child!,
              ),
            ),
          );
        },
        defaultTransition: Transition.noTransition,
      ),
    );
  }
}

class VersionCheckWrapper extends StatefulWidget {
  final Widget child;
  final VersionService versionService;

  const VersionCheckWrapper({
    Key? key,
    required this.child,
    required this.versionService,
  }) : super(key: key);

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final hasUpdate = await widget.versionService.checkForUpdate();
      if (hasUpdate && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(
            isForceUpdate: true,
            versionService: widget.versionService,
          ),
        );
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
