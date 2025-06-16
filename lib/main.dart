import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core import
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import 'firebase_options.dart'; // Make sure this file is generated from Firebase setup
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';
//import 'package:gemini_chat_app_tutorial/pages/UserInterest/UserInterest.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';
import 'imports.dart'; // Make sure the imports file is correct
import 'package:gemini_chat_app_tutorial/app_router.dart'; // Import app_router.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'config/language_config.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';

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

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Messaging
    try {
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
    } catch (e) {
      print('Firebase Messaging initialization error: $e');
    }

  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final languageController = Get.put(LanguageController());

    return GetMaterialApp(
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
          child: child!,
        );
      },
      defaultTransition: Transition.noTransition,
    );
  }
}
