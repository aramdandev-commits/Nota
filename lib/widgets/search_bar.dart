import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search notes, tags...',
        hintStyle: const TextStyle(color: Color(0xFF8E9099), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8E9099), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E2029),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      // TODO: Implement search logic later
    );
  }
}
