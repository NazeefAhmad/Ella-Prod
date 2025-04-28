import 'package:flutter/material.dart';
import '../bottomNavigation/bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C23),
      body: const Center(
        child: Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
} 