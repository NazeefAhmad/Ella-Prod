import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double size;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Image.asset(
          'assets/icons/back_icon.png',
          width: 24,
          height: 24,
        ),
        onPressed: onPressed ?? () => Get.back(),
      ),
    );
  }
} 