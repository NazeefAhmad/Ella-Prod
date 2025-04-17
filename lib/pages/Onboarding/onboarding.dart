import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  final List<String> profileImages = const [
    'assets/girls/sofiya.jpg',
    'assets/girls/shweta.jpg',
    'assets/girls/isma.jpg',
    'assets/girls/beach_girl.jpg',
    'assets/girls/airhostess.jpg',
    'assets/girls/Emma.jpg',
    'assets/girls/Emma.jpg',
    'assets/girls/beach_girl.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Profile grid covering the entire screen
              _buildProfileGrid(constraints),
              
              // App branding and button section positioned above the 4th row
              _buildAppBranding(constraints),
            ],
          );
        }
      ),
    );
  }

  Widget _buildAppBranding(BoxConstraints constraints) {
    // Position the branding content between the 3rd and 4th rows
    return Positioned(
      left: 0,
      right: 0,
      // Position it at about 65% of the screen height (between rows 3 and 4)
      top: constraints.maxHeight * 0.62,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HOOCUP',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF2E53),
                letterSpacing: 1.5,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Swipe Less, Talk More.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            _buildGetStartedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileGrid(BoxConstraints screenConstraints) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define center area that's 55% of the width
        final centerAreaWidth = constraints.maxWidth * 0.68;
        final leftEdge = (constraints.maxWidth - centerAreaWidth) / 2;
        final rightEdge = leftEdge + centerAreaWidth;
        
        // Standard tile size
        final tileSize = constraints.maxWidth * 0.3;
        final tileSpacing = constraints.maxWidth * 0.03;
        
        // Consistent small tilt angle
        const tileDegree = 0.05;
        
        return Container(
          color: Colors.white,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          // Use ClipRect to ensure cropping happens at screen edges
          child: ClipRect(
            child: Stack(
              children: [
                // ROW 1
                // Left image (partially visible)
                _buildProfileTile(
                  0, 
                  size: tileSize,
                  left: leftEdge - tileSize * 1.1, 
                  top: 40, 
                  angle: 0.2,
                  isFocused: true,
                  isPartial: true,
                ),
                
                // Middle-left image (focused)
                _buildProfileTile(
                  1, 
                  size: tileSize,
                  left: leftEdge + tileSpacing, 
                  top: 15, 
                  angle: 0.15,
                  isFocused: false,
                ),
                
                // Middle-right image (focused)
                _buildProfileTile(
                  2, 
                  size: tileSize,
                  left: rightEdge - tileSize - tileSpacing, 
                  top: 45, 
                  angle: 0.14,
                  isFocused: false,
                ),
                //row 2
                // Right image (partially visible)
                _buildProfileTile(
                  3, 
                  size: tileSize,
                  left: rightEdge + tileSpacing * 2.9, 
                  top: 70, 
                  angle: tileDegree,
                  isFocused: true,
                  isPartial: true,
                ),
                
                // ROW 2
                // Left image (partially visible)
                _buildProfileTile(
                  4, 
                  size: tileSize,
                  left: leftEdge - tileSize * 1.3, 
                  top: constraints.maxHeight * 0.25, 
                  angle: 0.3,
                  isFocused: true,
                  isPartial: true,
                ),
                
                // Middle-left image (focused)
                _buildProfileTile(
                  5, 
                  size: tileSize,
                  left: leftEdge + tileSpacing* 0.35, 
                  //  left: leftEdge + tileSpacing, 
                  top: constraints.maxHeight * 0.22, 
                  angle: 0.16,
                  isFocused: false,
                ),
                
                // Middle-right image (focused)
                _buildProfileTile(
                  6, 
                  size: tileSize,
                  left: rightEdge - tileSize - tileSpacing, 
                  top: constraints.maxHeight * 0.26, 
                  angle: 0.17,
                  isFocused: false,
                ),
                
                // Right image (partially visible)
                _buildProfileTile(
                  7, 
                  size: tileSize,
                  left: rightEdge + tileSpacing * 2, 
                  top: constraints.maxHeight * 0.23, 
                  angle: tileDegree,
                  isFocused: false,
                  isPartial: true,
                ),
                
                // ROW 3
                // Left image (partially visible)
                // _buildProfileTile(
                //   0, 
                //   size: tileSize,
                //   left: leftEdge - tileSize * 0.7, 
                //   top: constraints.maxHeight * 0.45, 
                //   angle: tileDegree,
                //   isFocused: false,
                //   isPartial: true,
                // ),
                
                // Middle-left image (focused)
                _buildProfileTile(
                  1, 
                  size: tileSize,
                  left: leftEdge + tileSpacing * 0.05, 
                  top: constraints.maxHeight * 0.44, 
                  angle: 0.2,
                  isFocused: false,
                ),
                
                // Middle-right image (focused)
                _buildProfileTile(
                  2, 
                  size: tileSize,
                  left: rightEdge - tileSize - tileSpacing *0.46, 
                  top: constraints.maxHeight * 0.485, 
                  angle: 0.2,
                  isFocused: false,
                ),
                
                // Right image (partially visible)
                _buildProfileTile(
                  3, 
                  size: tileSize,
                  left: rightEdge + tileSpacing * 2, 
                  top: constraints.maxHeight * 0.45, 
                  angle: tileDegree,
                  isFocused: false,
                  isPartial: true,
                ),
                
                // ROW 4 (Below branding section at bottom of screen)
                // Left image (partially visible)
                _buildProfileTile(
                  4, 
                  size: tileSize,
                  left: leftEdge - tileSize * 0.6, 
                  top: constraints.maxHeight * 0.78, 
                  angle: tileDegree,
                  isFocused: false,
                  isPartial: true,
                ),
                
                // Middle-left image (focused)
                _buildProfileTile(
                  5, 
                  size: tileSize,
                  left: leftEdge + tileSpacing, 
                  top: constraints.maxHeight * 0.77, 
                  angle: tileDegree,
                  isFocused: true,
                ),
                
                // Middle-right image (focused)
                _buildProfileTile(
                  6, 
                  size: tileSize,
                  left: rightEdge - tileSize - tileSpacing, 
                  top: constraints.maxHeight * 0.77, 
                  angle: tileDegree,
                  isFocused: true,
                ),
                
                // Right image (partially visible)
                _buildProfileTile(
                  7, 
                  size: tileSize,
                  left: rightEdge + tileSpacing * 2, 
                  top: constraints.maxHeight * 0.78, 
                  angle: tileDegree,
                  isFocused: false,
                  isPartial: true,
                ),
                
                // Extra white overlay at screen edges to enhance cropping effect
                Positioned(
                  left: 0,
                  top: 0,
                  width: leftEdge * 0.8,
                  height: constraints.maxHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Right edge fade
                Positioned(
                  right: 0,
                  top: 0,
                  width: leftEdge * 0.8,
                  height: constraints.maxHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTile(
    int index, {
    required double size,
    required double left, 
    required double top, 
    required double angle,
    required bool isFocused,
    bool isPartial = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isFocused ? 0.1 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Image
                Positioned.fill(
                  child: Image.asset(
                    profileImages[index % profileImages.length],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                
                // White overlay for non-focused images
                if (!isFocused)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isPartial ? 0.8 : 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF2E53).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF2E53),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}