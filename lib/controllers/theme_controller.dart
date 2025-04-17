import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme_config.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _prefs.setBool('isDarkMode', isDarkMode.value);
  }

  ThemeData get currentTheme => isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
} 