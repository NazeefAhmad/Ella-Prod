import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core import
import 'firebase_options.dart'; // Make sure this file is generated from Firebase setup
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';
//import 'package:gemini_chat_app_tutorial/pages/UserInterest/UserInterest.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';
import 'package:gemini_chat_app_tutorial/pages/login/login.dart';
import 'imports.dart'; // Make sure the imports file is correct
import 'package:gemini_chat_app_tutorial/app_router.dart'; // Import app_router.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'config/language_config.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';

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
    );
  }
}
