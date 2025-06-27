import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'pages/Splash/splash.dart';
import 'pages/Onboarding/onboarding.dart';
import 'pages/PersonalDetail/username.dart';
import 'pages/PersonalDetail/age.dart';
import 'pages/chat_screen/home_page.dart';
import 'pages/feed/feed.dart';
import 'imports.dart';
import 'app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'config/language_config.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'services/connectivity_service.dart';
import 'services/version_service.dart';
import 'widgets/connectivity_wrapper.dart';
import 'widgets/update_dialog.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io' show Platform;

/// Background message handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔄 Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = ClarityConfig(
    projectId: "s564z36nwm",
    logLevel: LogLevel.None // Note: Use "LogLevel.Verbose" value while testing to debug initialization issues.
  );

  runApp(ClarityWidget(
    app: MyApp(),
    clarityConfig: config,
  ));

  try {
    // Load environment variables
    await dotenv.load(fileName: "dev.env");

    // Initialize Firebase
    print("🔥 Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");

    // Initialize SharedPreferences (optional here, but included for completeness)
    await SharedPreferences.getInstance();

    // Firebase Messaging Setup
    try {
      print("📱 Initializing Firebase Messaging...");
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // iOS permission request
      if (Platform.isIOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Get initial token
      String? token = await messaging.getToken();
      print("📱 Initial FCM Token: $token");

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmtoken', token);
        print("📱 Stored initial FCM token in SharedPreferences");
      }

      // Handle token refresh
      messaging.onTokenRefresh.listen((String token) async {
        print("📱 FCM Token Refreshed: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmtoken', token);
      });

      print("✅ Firebase Messaging initialized successfully");
    } catch (e) {
      print('❌ Firebase Messaging initialization error: $e');
    }

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
  const MyApp({Key? key}) : super(key: key);

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
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: ConnectivityWrapper(
              child: VersionCheckWrapper(
                versionService: versionService,
                child: child!,
              ),
            ),
          );
        },
        defaultTransition: Transition.noTransition,
      ),
    );
  }
}

class VersionCheckWrapper extends StatefulWidget {
  final Widget child;
  final VersionService versionService;

  const VersionCheckWrapper({
    Key? key,
    required this.child,
    required this.versionService,
  }) : super(key: key);

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final hasUpdate = await widget.versionService.checkForUpdate();
      if (hasUpdate && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(
            isForceUpdate: true,
            versionService: widget.versionService,
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error checking for updates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
//check