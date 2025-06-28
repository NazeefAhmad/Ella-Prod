import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/profile_service.dart';
import '../../widgets/back_button.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({Key? key}) : super(key: key);

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  String? _currentUsername;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      
      setState(() {
        _currentUsername = profile['username'];
        _usernameController.text = _currentUsername ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading username: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load username';
        });
      }
    }
  }

  bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    final isValid = regex.hasMatch(username);
    print('Username validation: "$username" -> $isValid');
    return isValid;
  }

void showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.black, fontSize: 14),
    ),
    backgroundColor: Colors.white, // White background
    behavior: SnackBarBehavior.floating,
    elevation: 20,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.withOpacity(0.25)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    duration: const Duration(seconds: 3),
  );

  // Remove existing snackbars and show the new one
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}



  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    print('Attempting to update username to: "$newUsername"');
    
    if (newUsername.isEmpty) {
      setState(() => _errorMessage = 'Username cannot be empty');
      return;
    }

    if (!isValidUsername(newUsername)) {
      print('Username validation failed, showing snackbar');
      showSnackbar(
        context,
        '⚠️ Whoops! Usernames can only have letters, numbers, and underscores. No spaces or funky stuff!',
      );
      return;
    }

    print('Username validation passed, proceeding with API call');
    if (newUsername == _currentUsername) {
      Navigator.pop(context);
      return;
    }

    try {
      setState(() => _isLoading = true);
      await _profileService.updateUsername(newUsername);
      if (!mounted) return;
      
      Navigator.pop(context, newUsername);
    } catch (e) {
      print('Error updating username: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Username',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a username',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
} 