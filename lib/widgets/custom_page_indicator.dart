import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomPageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final double dotHeight;
  final double dotWidth;
  final Color dotColor;
  final Color activeDotColor;

  const CustomPageIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
    this.dotHeight = 8,
    this.dotWidth = 8,
    this.dotColor = Colors.grey,
    this.activeDotColor = const Color(0xFFAD46FF),
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: itemCount,
      effect: WormEffect(
        dotHeight: dotHeight,
        dotWidth: dotWidth,
        dotColor: dotColor,
        activeDotColor: activeDotColor,
      ),
    );
  }
}
