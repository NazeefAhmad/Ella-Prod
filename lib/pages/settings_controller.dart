// TODO Implement this library.

import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Observable variable
  var isDarkMode = false.obs;

  // Function to toggle the theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
