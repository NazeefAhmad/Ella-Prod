import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<double> _dot1Anim;
  late Animation<double> _dot2Anim;
  late Animation<double> _dot3Anim;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _dot1Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _dot2Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );
    _dot3Anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedDot(_dot1Anim),
          const SizedBox(width: 6),
          _buildAnimatedDot(_dot2Anim),
          const SizedBox(width: 6),
          _buildAnimatedDot(_dot3Anim),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
} 