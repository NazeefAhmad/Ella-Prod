import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                // On selecting Male, navigate to HomePage
                Get.toNamed('/feed');
              },
              label: const Text("Male"),
              icon: const Icon(Icons.male),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 30),
            // Female button (Floating Action Button)
            FloatingActionButton.extended(
              onPressed: () {
                // On selecting Female, navigate to HomePage
                Get.toNamed('/feed');
              },
              label: const Text("Female"),
              icon: const Icon(Icons.female),
              backgroundColor: Colors.pink,
            ),
            const SizedBox(height: 30),
            // Everyone button (Floating Action Button)
            FloatingActionButton.extended(
              onPressed: () {
                // On selecting Everyone, navigate to HomePage
                Get.toNamed('/feed');
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
