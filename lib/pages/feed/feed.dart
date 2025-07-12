import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hoocup/pages/bottomNavigation/bottom_navigation.dart';
import 'dart:ui'; // For ImageFilter
import '../../utils/navigation_helper.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;

  final List<Map<String, dynamic>> profiles = [
    {"name": "Krity", "age": 21, "image": "assets/girls/Krity/krity.jpg", "bio": "Mumbai vibe ✈️ HMU! 🫶 "},
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
      extendBody: true, // allows bottom nav to float over body
      backgroundColor: Colors.white, // match your UI theme
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildProfileGrid(),
                ),
              ),
            ],
          ),
          // Bottom navigation overlay
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: BottomNavigation(selectedIndex: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => NavigationHelper.navigateTo('/profile'),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 25,
              child: Icon(Icons.person_outline, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("For You", 0),
                const SizedBox(width: 10),
                _buildTab("All", 1),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              NavigationHelper.navigateTo('/notifications');
            },
            color: Colors.black,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Add haptic feedback
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
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 2,
            width: 40,
            color: _selectedTab == index ? Colors.pink : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid() {
    // Use a unique key to force AnimatedSwitcher to rebuild the grid
    return Padding(
      key: ValueKey<int>(_selectedTab),
      padding: const EdgeInsets.all(4.0),
      child: MasonryGridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:2,
        ),
        itemCount: 18,
        itemBuilder: (context, index) {
          final profileIndex = index % profiles.length;
          final profile = profiles[profileIndex];
          final isLeftSide = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: PersonaCard(
              name: profile["name"],
              age: profile["age"],
              imagePath: profile["image"],
              bio: profile["bio"],
              isLeftSide: isLeftSide,
            ),
          );
        },
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }
}

class PersonaCard extends StatefulWidget {
  final String name;
  final int? age;
  final String imagePath;
  final String bio;
  final bool isLeftSide;

  const PersonaCard({super.key, 
    required this.name,
    required this.imagePath,
    this.age,
    required this.bio,
    required this.isLeftSide,
  });

  @override
  _PersonaCardState createState() => _PersonaCardState();
}

class _PersonaCardState extends State<PersonaCard>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isKrity = false;

  @override
  void initState() {
    super.initState();
    _isKrity = widget.name == "Krity" && widget.age == 21;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    if (!_isKrity) return;
    setState(() {
      _isLiked = !_isLiked;
    });
    _animationController.forward(from: 0.0);
  }

  void _showComingSoonDialog() {
    if (_isKrity) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.shade100,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 50,
                  color: Colors.pink,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.name}\'s profile will be available soon.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = widget.isLeftSide ? 240.0 : 200.0;

    return GestureDetector(
      onTap: _isKrity
          ? () {
              NavigationHelper.navigateTo('/home', arguments: {
                'characterName': widget.name,
                'characterImage': widget.imagePath,
                'characterBio': widget.bio,
              });
            }
          : _showComingSoonDialog,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageFiltered(
                imageFilter: _isKrity ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  height: imageHeight,
                  width: double.infinity,
                ),
              ),
            ),
            if (!_isKrity)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildProfileInfo(),
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
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(widget.imagePath),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.age != null)
                    Text(
                      " ${widget.age}",
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.bio,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: _toggleLike,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: _isLiked ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}