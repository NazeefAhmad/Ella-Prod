import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignInDialog extends StatelessWidget {
  final AuthService authService;
  final VoidCallback onSignInSuccess;

  const SignInDialog({
    Key? key,
    required this.authService,
    required this.onSignInSuccess,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required AuthService authService,
    required VoidCallback onSignInSuccess,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SignInDialog(
        authService: authService,
        onSignInSuccess: onSignInSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign in Required'),
      content: const Text('Please sign in to edit your profile.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await authService.signInWithGoogle();
              onSignInSuccess();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign in failed: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Sign in with Google'),
        ),
      ],
    );
  }
} 