import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
// import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/login/login.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';
import 'pages/messages/messages_screen.dart';
import 'pages/profile/profile_screen.dart';
import 'pages/notifications/notification.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(name: '/userInterest', page: () => UserInterestPage()),
    GetPage(name: '/home', page: () => const HomePage()),
    // GetPage(name: '/settings', page: () => SettingsPage()),
    GetPage(name: '/onboarding', page: () => OnboardingPage()),
    GetPage(name: '/username', page: () => const UsernamePage()),
    GetPage(name: '/age', page: () => AgePage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/feed', page: () => FeedScreen()),
    GetPage(name: '/messages', page: () => const MessagesScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/notifications', page: () => const NotificationScreen()),
    GetPage(name: '/', page: () => const SplashPage()),
  ];
}
