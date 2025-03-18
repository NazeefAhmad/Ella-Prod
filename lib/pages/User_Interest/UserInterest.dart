
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/services/api_service.dart';  // Import your API service
import 'package:gemini_chat_app_tutorial/consts.dart';


class UserInterestPage extends StatelessWidget {
  const UserInterestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Who are you interested in seeing?"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              'Select who you are interested in seeing:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            // Male button (Floating Action Button)
            FloatingActionButton.extended(
              onPressed: () {
                // Save interest as 'Male' and make the API call
                AppConstants.interest = 'Male';
                ApiService().sendInterest(AppConstants.interest);  // Send to backend
                Get.toNamed('/feed');  // Navigate to Feed page
              },
              label: const Text("Male"),
              icon: const Icon(Icons.male),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 30),
            // Female button (Floating Action Button)
            FloatingActionButton.extended(
              onPressed: () {
                // Save interest as 'Female' and make the API call
                AppConstants.interest = 'Female';
                ApiService().sendInterest(AppConstants.interest);  // Send to backend
                Get.toNamed('/feed');  // Navigate to Feed page
              },
              label: const Text("Female"),
              icon: const Icon(Icons.female),
              backgroundColor: Colors.pink,
            ),
            const SizedBox(height: 30),
            // Everyone button (Floating Action Button)
            FloatingActionButton.extended(
              onPressed: () {
                // Save interest as 'Everyone' and make the API call
                AppConstants.interest = 'Everyone';
                ApiService().sendInterest(AppConstants.interest);  // Send to backend
                Get.toNamed('/feed');  // Navigate to Feed page
              },
              label: const Text("Everyone"),
              icon: const Icon(Icons.group),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
