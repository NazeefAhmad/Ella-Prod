import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  final RxString currentLanguage = 'en_US'.obs;
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    currentLanguage.value = _prefs.getString('language') ?? 'en_US';
    Get.updateLocale(getLocale(currentLanguage.value));
  }

  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    Get.updateLocale(getLocale(languageCode));
    _prefs.setString('language', languageCode);
  }

  Locale getLocale(String languageCode) {
    switch (languageCode) {
      case 'es_ES':
        return const Locale('es', 'ES');
      default:
        return const Locale('en', 'US');
    }
  }
} 