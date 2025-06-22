import 'package:hoocup/pages/User_Interest/change_pref.dart';
import 'package:hoocup/pages/chat_screen/home_page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart' show Curves;
// import 'package:hoocup/pages/settings.dart';
import 'package:hoocup/pages/Onboarding/onboarding.dart';
import 'package:hoocup/pages/PersonalDetail/username.dart';
import 'package:hoocup/pages/PersonalDetail/age.dart';
import 'package:hoocup/pages/feed/feed.dart';
import 'package:hoocup/pages/Splash/splash.dart';
import 'package:hoocup/pages/User_Interest/UserInterest.dart';
import 'pages/messages/messages_screen.dart';
import 'pages/profile/profile_screen.dart';
import 'pages/profile/edit_profile_screen.dart';
import 'pages/profile/account_settings_screen.dart';
import 'pages/profile/additional_resources_screen.dart';
import 'pages/notifications/notification.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(
      name: '/userInterest',
      page: () => UserInterestPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    // GetPage(name: '/settings', page: () => SettingsPage()),
    GetPage(
      name: '/onboarding',
      page: () => OnboardingPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/username',
      page: () => const UsernamePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/age',
      page: () => AgePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/feed',
      page: () => FeedScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/messages',
      page: () => const MessagesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/editProfile',
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/accountSettings',
      page: () => const AccountSettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/additionalResources',
      page: () => const AdditionalResourcesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
     GetPage(
      name: '/changePref',
      page: () => const ChangePref(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: '/',
      page: () => const SplashPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ),
  ];
}
