
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/services/api_service.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';

class UserInterestPage extends StatefulWidget {
  const UserInterestPage({Key? key}) : super(key: key);

  @override
  State<UserInterestPage> createState() => _UserInterestPageState();
}

class _UserInterestPageState extends State<UserInterestPage> {
  String? selectedPreference;

  // Preference types
  static const String MEN = 'Male';
  static const String WOMEN = 'Female';
  static const String ALL = 'Everyone';

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFFF3B5C);
    final Color inactiveColor = const Color(0xFFE0E0E0);
    final Color activeTextColor = Colors.white;
    final Color inactiveTextColor = const Color(0xFF8E8E9A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Back Button and Progress Indicators (Updated for third screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3855),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3855),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3855),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Rest of the content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Who are you interested in?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tell us who you\'d like to match with!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E8E9A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Preference buttons
                    _buildPreferenceButton(
                      text: 'I want to See men',
                      emoji: '👨',
                      preference: MEN,
                      isActive: selectedPreference == MEN,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      activeTextColor: activeTextColor,
                      inactiveTextColor: inactiveTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildPreferenceButton(
                      text: 'I want to See Women',
                      emoji: '👩',
                      preference: WOMEN,
                      isActive: selectedPreference == WOMEN,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      activeTextColor: activeTextColor,
                      inactiveTextColor: inactiveTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildPreferenceButton(
                      text: 'I am open to all',
                      emoji: '🌈',
                      preference: ALL,
                      isActive: selectedPreference == ALL,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      activeTextColor: activeTextColor,
                      inactiveTextColor: inactiveTextColor,
                    ),
                    
                    const Spacer(),
                    
                    // Bottom "Select your Preference" button
                    ElevatedButton(
                      onPressed: selectedPreference != null ? () {
                        // Save interest and make the API call
                        AppConstants.interest = selectedPreference!;
                        ApiService().sendInterest(AppConstants.interest); // Send to backend
                        Get.toNamed('/feed'); // Navigate to Feed page
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPreference != null ? activeColor : inactiveColor,
                        foregroundColor: selectedPreference != null ? activeTextColor : inactiveTextColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: inactiveColor,
                        disabledForegroundColor: inactiveTextColor,
                      ),
                      child: const Text(
                        'Select your Preference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceButton({
    required String text,
    required String emoji,
    required String preference,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Color activeTextColor,
    required Color inactiveTextColor,
  }) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedPreference = preference;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : inactiveColor,
        foregroundColor: isActive ? activeTextColor : inactiveTextColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isActive ? activeTextColor : inactiveTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}