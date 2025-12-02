import 'package:flutter/material.dart';

class JumpingArrowIndicator extends StatefulWidget {
  const JumpingArrowIndicator({super.key});

  @override
  State<JumpingArrowIndicator> createState() => _JumpingArrowIndicatorState();
}

// Use TickerProviderStateMixin to handle the AnimationController
class _JumpingArrowIndicatorState extends State<JumpingArrowIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Time for one full jump cycle
    )..repeat(reverse: true); // Start the animation and repeat back and forth

    // Animate the vertical position (offset) of the arrow
    // We want the arrow to move up by 10 pixels from its original position (0.0).
    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      // Use an elastic curve to give it a bouncy, jump-like feel
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, 
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Important: Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Use Transform.translate to move the icon vertically based on the animation value
        return Transform.translate(
          offset: Offset(0, _animation.value), // X-offset is 0, Y-offset is animated
          child: const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.white70,
            size: 40,
          ),
        );
      },
    );
  }
}