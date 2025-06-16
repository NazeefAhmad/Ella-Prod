import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateTo(String routeName, {dynamic arguments}) {
    Get.toNamed(
      routeName,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static void navigateAndReplace(String routeName, {dynamic arguments}) {
    Get.offNamed(
      routeName,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static void navigateAndClearStack(String routeName, {dynamic arguments}) {
    Get.offAllNamed(
      routeName,
      arguments: arguments,
      predicate: (_) => false,
    );
  }

  static void navigateToPage(Widget page) {
    Get.to(
      () => page,
      preventDuplicates: false,
    );
  }
} 