import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/services/profile_service.dart';
import 'package:gemini_chat_app_tutorial/widgets/loading_dialog.dart';
import '../../widgets/back_button.dart';

class UserInterestPage extends StatefulWidget {
  const UserInterestPage({Key? key}) : super(key: key);

  @override
  State<UserInterestPage> createState() => _UserInterestPageState();
}

class _UserInterestPageState extends State<UserInterestPage> {
  String? selectedPreference;
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  // Preference types
  static const String MEN = 'male';
  static const String WOMEN = 'female';
  static const String ALL = 'both';

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  Future<void> _handlePreferenceSelection() async {
    if (selectedPreference == null) {
      Get.snackbar(
        'Error',
        'Please select a preference',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _showLoadingDialog('Updating preference...');
    try {
      await _profileService.updateGenderPreference(selectedPreference!);
      _hideLoadingDialog();
      Get.toNamed('/feed');
    } catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        'Error',
        'Failed to update preference: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
            // App Bar with Back Button and Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3855),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3855),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
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
                      'Who are you \n interested in?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tell us who you\'d like to \n match with!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8E8E9A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Preference buttons
                    _buildPreferenceButton(
                      text: 'I want to See Men',
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
                      text: 'I am open to Everyone',
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
                      onPressed: _isLoading ? null : _handlePreferenceSelection,
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
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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