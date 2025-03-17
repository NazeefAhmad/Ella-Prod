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

void main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables from the dev.env file
  await dotenv.load(fileName: "dev.env");

  // Get the API key from the environment variables
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'default_api_key'; // Add a default or handle missing key

  // Initialize Gemini with the API key
  Gemini.init(apiKey: apiKey);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp for GetX navigation
      title: 'Ella A.I',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Start from SplashPage
      getPages: AppRouter.routes, // Use AppRouter for all routes
      debugShowCheckedModeBanner: false,
    );
  }
}
