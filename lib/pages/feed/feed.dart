import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gemini_chat_app_tutorial/pages/bottomNavigation/bottom_navigation.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;
  
  final List<Map<String, dynamic>> profiles = [
    {"name": "Jasleen", "age": 26, "image": "assets/girls/Emma.jpg", "bio": "Loves chai and late-night convos 🌙"},
    {"name": "Sofia", "age": 22, "image": "assets/girls/sofiya.jpg", "bio": "I can't catch feelings, I create them 💫"},
    {"name": "Aisha", "age": 26, "image": "assets/girls/shweta.jpg", "bio": "Soft heart, sharp mind, endless cosmos"},
    {"name": "Jasmin", "age": 26, "image": "assets/girls/isma.jpg", "bio": "Talk sweet, but smarter"},
    {"name": "Amara", "age": 24, "image": "assets/girls/beach_girl.jpg", "bio": "That special girl you met at the party ✨"},
    {"name": "Simran", "age": 28, "image": "assets/girls/airhostess.jpg", "bio": "Sassy enough to keep you on your toes."},
    {"name": "Suhani", "age": null, "image": "assets/girls/isma.jpg", "bio": "Loves chai and late-night convos 🌙"},
    {"name": "Aanya", "age": null, "image": "assets/girls/beach_girl.jpg", "bio": "Loves chai and late-night convos 🌙"},
    {"name": "Zoya", "age": 26, "image": "assets/girls/airhostess.jpg", "bio": "Talk sweet, but smarter"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildProfileGrid(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 18,
              child: Icon(Icons.person_outline, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("For You", 0),
                SizedBox(width: 20),
                _buildTab("All", 1),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
            color: Colors.black,
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _selectedTab == index ? Colors.black : Colors.grey,
              fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: _selectedTab == index ? Colors.pink : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: MasonryGridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
        ),
        itemCount: 18, // Display doubled profiles for the infinite effect
        itemBuilder: (context, index) {
          final profileIndex = index % profiles.length;
          final profile = profiles[profileIndex];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: PersonaCard(
              name: profile["name"],
              age: profile["age"],
              imagePath: profile["image"],
              bio: profile["bio"],
            ),
          );
        },
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }
}

class PersonaCard extends StatelessWidget {
  final String name;
  final int? age;
  final String imagePath;
  final String bio;

  PersonaCard({
    required this.name, 
    required this.imagePath,
    this.age,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/home'); // Navigate to home on tap
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                _buildProfileInfo(),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildLikeButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (age != null)
                      Text(
                        " $age",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                Text(
                  bio,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.favorite_border,
          size: 18,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}