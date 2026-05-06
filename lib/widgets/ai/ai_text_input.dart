import 'package:flutter/material.dart';

/// Multi-line text field for pasting / typing text to analyze.
class AiTextInput extends StatelessWidget {
  final TextEditingController controller;

  const AiTextInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 7,
        minLines: 7,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        decoration: const InputDecoration(
          hintText: 'Paste or type text to analyze...',
          hintStyle: TextStyle(
            color: Color(0xFF4A4A6A),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
