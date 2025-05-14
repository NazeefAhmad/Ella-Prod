import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

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

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    
    if (newUsername.isEmpty) {
      setState(() => _errorMessage = 'Username cannot be empty');
      return;
    }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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