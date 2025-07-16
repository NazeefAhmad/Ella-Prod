import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'imports.dart';
import 'app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'config/language_config.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'services/connectivity_service.dart';
import 'services/version_service.dart';
import 'services/comprehensive_notification_service.dart';
import 'widgets/connectivity_wrapper.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'consts.dart';
import 'services/chat_service.dart';

/// Background message handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔄 Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: "dev.env");

    // Initialize Firebase
    print("🔥 Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");

    // Initialize SharedPreferences
    await SharedPreferences.getInstance();

    // Initialize comprehensive notification service
    try {
      print("\ud83d\udcf1 Initializing Comprehensive Notification Service...");
      await ComprehensiveNotificationService().initialize();
      print("\u2705 Comprehensive Notification Service initialized successfully");
    } catch (e) {
      print('\u274c Comprehensive Notification Service initialization error: $e');
    }

    // Register ChatService with GetX for dependency injection
    Get.put(ChatService(
      baseUrl: AppConstants.baseUrl,
      userName: AppConstants.userName,
      userId: AppConstants.userId,
    ));

    // Initialize Clarity and Run App
    final config = ClarityConfig(
      projectId: "s564z36nwm",
      logLevel: LogLevel.None,
    );

    runApp(ClarityWidget(
      app: const MyApp(),
      clarityConfig: config,
    ));

  } catch (e) {
    print('❌ Global initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final languageController = Get.put(LanguageController());
    final versionService = VersionService();

    return MultiProvider(
      providers: [
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<VersionService>(
          create: (_) => versionService,
        ),
      ],
      child: GetMaterialApp(
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
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: ConnectivityWrapper(
              child: child!,
            ),
          );
        },
        defaultTransition: Transition.noTransition,
      ),
    );
  }
}
//check