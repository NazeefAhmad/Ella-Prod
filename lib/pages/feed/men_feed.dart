import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MenFeedScreen extends StatefulWidget {
  @override
  _MenFeedScreenState createState() => _MenFeedScreenState();
}

class _MenFeedScreenState extends State<MenFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> profiles = [
    {"name": "John", "image": "assets/men/john.jpg"},
    {"name": "Michael", "image": "assets/men/michael.jpg"},
    {"name": "David", "image": "assets/men/david.jpg"},
    {"name": "Lucas", "image": "assets/men/lucas.jpg"},
    {"name": "Ethan", "image": "assets/men/ethan.jpg"},
    {"name": "James", "image": "assets/men/james.jpg"},
    {"name": "Ryan", "image": "assets/men/ryan.jpg"},
    {"name": "Chris", "image": "assets/men/chris.jpg"},
    {"name": "Alexander", "image": "assets/men/alexander.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
