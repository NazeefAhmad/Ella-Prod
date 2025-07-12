import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/responsive_config.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;

  const BottomNavigation({super.key, required this.selectedIndex});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    _animationController.forward().then((_) => _animationController.reverse());

    switch (index) {
      case 0:
        Get.offAllNamed('/feed');
        break;
      case 1:
        Get.offAllNamed('/messages');
        break;
      case 2:
        Get.offAllNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveConfig.getScreenWidth(context);
    final isMobile = ResponsiveConfig.isMobile(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile ? 16.0 : 24.0,
        left: isMobile ? 65.0 : 30.0,
        right: isMobile ? 65.0 : 30.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: isMobile ? screenWidth * 0.7 : 260,
            height: isMobile ? 56.0 : 58.0,
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C23).withOpacity(0.8),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.06),
                  blurRadius: 5,
                //  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Red underline animation
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: _getAlignment(_currentIndex),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1.0,
                    child: Container(
                      width: isMobile ? 50.0 : 60.0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 32, 78, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Navigation icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.message_outlined, 1),
                    _buildNavItem(Icons.person_outline, 2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;
    return ScaleTransition(
      scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? const Color.fromRGBO(255, 32, 78, 1) : Colors.white,
          size: ResponsiveConfig.isMobile(context) ? 26.0 : 28.0,
        ),
        onPressed: () => _onItemTapped(index),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0:
        return const Alignment(-0.8, 1);
      case 1:
        return const Alignment(0.0, 1);
      case 2:
        return const Alignment(0.8, 1);
      default:
        return const Alignment(-0.8, 1);
    }
  }
}
