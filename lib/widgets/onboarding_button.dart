import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final int totalPages;
  final VoidCallback? onGetStarted;

  const OnboardingButton({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.totalPages,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff7C3AED),
            Color(0xFFDB2777),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (currentIndex == totalPages - 1) {
            // Call the callback when Get Started is pressed
            if (onGetStarted != null) {
              onGetStarted!();
            }
          } else {
            controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          currentIndex == totalPages - 1 ? 'Get Started' : 'Next >',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
