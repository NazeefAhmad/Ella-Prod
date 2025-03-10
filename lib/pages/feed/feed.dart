import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> profiles = [
    {"name": "Emma", "image": "assets/girls/Emma.jpg"},
    {"name": "Sofiya", "image": "assets/girls/sofiya.jpg"},
    {"name": "Shweta", "image": "assets/girls/shweta.jpg"},
    {"name": "Isma", "image": "assets/girls/isma.jpg"},
    {"name": "Beach Girl", "image": "assets/girls/beach_girl.jpg"},
    {"name": "Airhostess", "image": "assets/girls/airhostess.jpg"},
    {"name": "Karisma", "image": "assets/girls/isma.jpg"},
    {"name": "Preeti", "image": "assets/girls/beach_girl.jpg"},
    {"name": "Pilot", "image": "assets/girls/airhostess.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("AI Persona Feed"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
          ),
          itemCount: 1000, // Simulate infinite scroll
          itemBuilder: (context, index) {
            final item = profiles[index % profiles.length]; // Repeat images
            return Padding(
              padding: EdgeInsets.only(
                top: (index % 2 == 1 && index % profiles.length == 1) ? 25 : 0,
              ),
              child: PersonaCard(
                name: item["name"]!,
                imagePath: item["image"]!,
              ),
            );
          },
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
      ),
    );
  }
}

class PersonaCard extends StatelessWidget {
  final String name;
  final String imagePath;

  PersonaCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/home'); // Navigate to home on tap
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 200, // Fixed height for uniformity
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
