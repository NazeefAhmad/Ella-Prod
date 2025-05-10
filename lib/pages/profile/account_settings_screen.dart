import 'package:flutter/material.dart';
import '../login/login.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  Widget _buildOptionItem(BuildContext context, String title, {Color? textColor}) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        if (title == 'Log Out') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        } else if (title == 'Deactivate Account') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Deactivate Account'),
              content: const Text(
                'We\'re sorry to see you go! Your account will be temporarily deactivated. '
                'You can reactivate it anytime within 30 days by simply logging back in. '
                'After 30 days, your data will be permanently deleted from our servers. '
                'Are you sure you want to proceed?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement deactivate account logic
                    Navigator.pop(context);
                  },
                  child: const Text('Deactivate', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          );
        } else if (title == 'Delete Account') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Account'),
              content: const Text(
                'We\'re sad to see you leave! This action will permanently delete your account '
                'and all associated data. Your data will be completely removed from our servers '
                'within 30 days. This action cannot be undone. '
                'Are you absolutely sure you want to delete your account?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement delete account logic
                    Navigator.pop(context);
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(
              context,
              'Log Out',
              textColor: Colors.red,
            ),
            const Divider(height: 1),
            _buildOptionItem(
              context,
              'Deactivate Account',
              textColor: Colors.black,
            ),
            const Divider(height: 1),
            _buildOptionItem(
              context,
              'Delete Account',
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
} 