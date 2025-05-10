import 'package:flutter/material.dart';

class UserInterestsScreen extends StatelessWidget {
  const UserInterestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Preference',
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
            _buildPreferenceItem(
              context,
              'I am interested in',
              'Men',
            ),
            const Divider(height: 1),
            _buildPreferenceItem(
              context,
              'Show me',
              'Everyone',
            ),
            const Divider(height: 1),
            _buildPreferenceItem(
              context,
              'Age Range',
              '18-35',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {
        // TODO: Implement preference selection
      },
    );
  }
} 