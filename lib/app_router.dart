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
// import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterestPage.dart';
// import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterestPage.dart';
import 'package:gemini_chat_app_tutorial/pages/User_Interest/UserInterest.dart';


///Users/nazeef/Developer/Flutter-Projects/New Ella Chat APP/lib/pages/User Interest/UserInterest.dart


// Define your app routes
class AppRouter {
  static final List<GetPage> routes = [
    // GetPage(name: '/userInterest', page: () => const UserInterestPage()),
    GetPage(name: '/userInterest', page: () => UserInterestPage()),
    GetPage(name: '/personal_details', page: () => PersonalDetailsPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/settings', page: () => SettingsPage()),
    GetPage(name: '/onboarding', page: () => OnboardingPage()),
    GetPage(name: '/username', page: () => const UsernamePage()),
    GetPage(name: '/age', page: () => AgePage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/feed', page: () => FeedScreen()),
    
    GetPage(name: '/', page: () => SplashPage()), // SplashPage is the initial page

  ];
}
