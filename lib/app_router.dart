
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
// import 'package:gemini_chat_app_tutorial/pages/settings.dart';
// import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
// import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
// // import 'pages/user_interest.dart';  // Import UserInterestPage
// import 'package:gemini_chat_app_tutorial/pages/login/login.dart'; // Import LoginPage

// import 'pages/home_page.dart'; 

// // Define your app routes
// final List<GetPage> appRoutes = [
//   GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
//   GetPage(name: '/home', page: () => HomePage()),
//   GetPage(name: '/settings', page: () => SettingsPage()),
//   GetPage(name: '/onboarding', page: () => OnboardingPage()),
//    GetPage(name: '/username', page: () => UsernamePage()),
//         GetPage(name: '/age', page: () => AgePage()), // Define AgePage here
//                 // GetPage(name: '/user_interest', page: () => UserInterestPage()), // Add route for UserInterestPage
//                  GetPage(name: '/login', page: () => LoginPage()), // Add route for LoginPage
//                  GetPage(name: '/', page: () => FeedScreen()),  // Feed screen route
//                    GetPage(name: '/', page: () => SplashPage()),
//     GetPage(name: '/login', page: () => LoginPage()),
//     GetPage(name: '/onboarding', page: () => OnboardingPage()),
//     GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
//     GetPage(name: '/home', page: () => HomePage()),
//     GetPage(name: '/username', page: () => UsernamePage()),
//     GetPage(name: '/age', page: () => AgePage()),
//     GetPage(name: '/feed', page: () => FeedScreen()),



//   // Add more routes as needed
// ];

import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/login/login.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart'; // UsernamePage
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart'; // AgePage
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart'; // FeedScreen
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart'; // SplashPage

// Define your app routes
class AppRouter {
  static final List<GetPage> routes = [
    GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/settings', page: () => SettingsPage()),
    GetPage(name: '/onboarding', page: () => OnboardingPage()),
    GetPage(name: '/username', page: () => UsernamePage()),
    GetPage(name: '/age', page: () => AgePage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/feed', page: () => FeedScreen()),
    GetPage(name: '/', page: () => SplashPage()), // SplashPage is the initial page
  ];
}
