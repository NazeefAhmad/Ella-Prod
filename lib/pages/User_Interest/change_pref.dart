import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoocup/services/profile_service.dart';
import 'package:hoocup/widgets/loading_dialog.dart';
import '../../widgets/back_button.dart';

class ChangePref extends StatefulWidget {
  const ChangePref({super.key});

  @override
  State<ChangePref> createState() => _ChangePrefPageState();
}

class _ChangePrefPageState extends State<ChangePref> {
  String? selectedPreference;
  final ProfileService _profileService = ProfileService();
  final bool _isLoading = false;
  bool _isConfirmed = false;

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
      backgroundColor: Color.fromRGBO(248, 248, 248, 1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
       flexibleSpace: Padding(
  padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Centered Title
      const Align(
        alignment: Alignment.center,
        child: Text(
          'Change Preferences',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      // Left Back Icon
      Align(
        alignment: Alignment.centerLeft,
        child: const CustomBackButton(),
      ),
    ],
  ),
),

        ),
      ),
      body: Padding(
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

            // Place the confirmation checkbox here
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _isConfirmed,
                  activeColor: activeColor,
                  onChanged: (bool? value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'I confirm to change my preferences',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8E9A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              onPressed: (_isLoading || selectedPreference == null || !_isConfirmed) ? null : _handlePreferenceSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: (selectedPreference != null && _isConfirmed) ? activeColor : inactiveColor,
                foregroundColor: (selectedPreference != null && _isConfirmed) ? activeTextColor : inactiveTextColor,
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
                      'Change your Preference',
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
