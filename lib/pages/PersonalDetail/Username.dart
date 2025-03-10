import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/PersonalDetail/age.dart';


class UsernamePage extends StatefulWidget {
  const UsernamePage({Key? key}) : super(key: key);

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("What's your name?"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading Text
            const Text(
              'What would you like to be called?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Text Field for Name Input
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),

            // Circular button with Continue text
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Age Page when clicked
                  if (_usernameController.text.isNotEmpty) {
                    Get.toNamed('/age'); // Replace with your next page route
                  } else {
                    // Show error if name is not entered
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter your name!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                ),
                child: const Icon(Icons.arrow_forward, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
