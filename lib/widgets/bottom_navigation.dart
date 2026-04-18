import 'package:flutter/material.dart';

BottomNavigationBarItem buildItem({
  required IconData icon,
  required String label,
  required int selectedIndex,
  required int index,
  Color? activeBg,
  Color? iconColor,
}) {
  final isSelected = selectedIndex == index;

  return BottomNavigationBarItem(
    label: label,
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? (activeBg ?? const Color(0xFF162544))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor),
    ),
  );
}
