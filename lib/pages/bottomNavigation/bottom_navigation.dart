// import 'package:flutter/material.dart';

// class BottomNavigation extends StatelessWidget {
//   final int selectedIndex;

//   const BottomNavigation({Key? key, required this.selectedIndex}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       //width: 260,

//       height: 58,
//       decoration: BoxDecoration(
//         color: const Color(0xFF0C0C23),
//         borderRadius: BorderRadius.circular(40),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black26,
//         //     blurRadius: 10,
//         //     offset: Offset(0, 4),
//         //   ),
//         // ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           IconButton(
//             icon: Icon(
//               Icons.home,
//               color: selectedIndex == 0 ? const Color.fromRGBO(255, 32, 78, 1) : Colors.white,
//               size: 30,
//             ),
//             onPressed: () {
//               // Navigate or update here
//             },
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.message_outlined,
//               color: selectedIndex == 1 ? const Color.fromRGBO(255, 32, 78, 1) : Colors.white,
//               size: 28,
//             ),
//             onPressed: () {
//               // Navigate or update here
//             },
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.person_outline,
//               color: selectedIndex == 2 ? const Color.fromRGBO(255, 32, 78, 1): Colors.white,
//               size: 30,
//             ),
//             onPressed: () {
//               // Navigate or update here
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;

  const BottomNavigation({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Get.toNamed('/feed');
        break;
      case 1:
        Get.toNamed('/messages');
        break;
      case 2:
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 120, right: 120),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C23).withOpacity(0.8),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.06),
                  blurRadius: 5,
                  spreadRadius: 5,
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
                      width: 60,
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
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color.fromRGBO(255, 32, 78, 1) : Colors.white,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
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
