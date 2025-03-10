
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'pages/user_interest.dart';  // Import UserInterestPage
import 'package:gemini_chat_app_tutorial/pages/login/login.dart'; // Import LoginPage

import 'pages/home_page.dart'; 

// Define your app routes
final List<GetPage> appRoutes = [
  GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
  GetPage(name: '/home', page: () => HomePage()),
  GetPage(name: '/settings', page: () => SettingsPage()),
  GetPage(name: '/onboarding', page: () => OnboardingPage()),
   GetPage(name: '/username', page: () => UsernamePage()),
        GetPage(name: '/age', page: () => AgePage()), // Define AgePage here
                GetPage(name: '/user_interest', page: () => UserInterestPage()), // Add route for UserInterestPage
                 GetPage(name: '/login', page: () => LoginPage()), // Add route for LoginPage
                 GetPage(name: '/', page: () => FeedScreen()),  // Feed screen route



  // Add more routes as needed
];

