import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:get/get.dart'; // Import Get for GetMaterialApp
import 'package:gemini_chat_app_tutorial/imports.dart';
export 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';
import 'package:gemini_chat_app_tutorial/pages/User Interest/UserInterest.dart';  // Import UserInterestPage
import 'pages/home_page.dart';
// import 'feed_screen.dart';  
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';

import 'package:gemini_chat_app_tutorial/pages/login/login.dart'; // Import LoginPage



void main() async {
  // Ensure widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables from the dev.env file
  await dotenv.load(fileName: "dev.env");

  // Get the API key from the environment variables
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'default_api_key'; // Add a default or handle missing key

  // Initialize Gemini with the API key
  Gemini.init(apiKey: apiKey);
  
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
       home: SplashPage(), // Set SplashPage as the home screen
      //initialRoute: '/personal_details', // Initial route for app start
      getPages: [
         GetPage(name: '/login', page: () => LoginPage()), // Add route for LoginPage
        GetPage(name: '/onboarding', page: () => OnboardingPage()),
        GetPage(name: '/personal_details', page: () => PersonalDetailsPage()), // Route for PersonalDetailsPage
        GetPage(name: '/home', page: () => HomePage()), // Route for HomePage
         GetPage(name: '/username', page: () => UsernamePage()),
        GetPage(name: '/age', page: () => AgePage()), // Define AgePage here
        GetPage(name: '/feed', page: () => FeedScreen()),  // Feed screen route
                GetPage(name: '/user_interest', page: () => UserInterestPage()), // Add route for UserInterestPage

      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
