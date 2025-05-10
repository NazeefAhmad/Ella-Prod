import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/home_page.dart';
import 'package:gemini_chat_app_tutorial/pages/settings.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetailsPage.dart';
import 'package:gemini_chat_app_tutorial/pages/Onboarding/onboarding.dart';
import 'package:gemini_chat_app_tutorial/pages/login/login.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/username.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';
import 'package:gemini_chat_app_tutorial/pages/feed/feed.dart';
import 'package:gemini_chat_app_tutorial/pages/Splash/splash.dart';
import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';
import 'pages/messages/messages_screen.dart';
import 'pages/profile/profile_screen.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(name: '/userInterest', page: () => UserInterestPage()),
    GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/settings', page: () => SettingsPage()),
    GetPage(name: '/onboarding', page: () => OnboardingPage()),
    GetPage(name: '/username', page: () => const UsernamePage()),
    GetPage(name: '/age', page: () => AgePage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/feed', page: () => FeedScreen()),
    GetPage(name: '/messages', page: () => const MessagesScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/', page: () => const SplashPage()),
  ];
}
