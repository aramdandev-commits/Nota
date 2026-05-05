import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push('/home');
        break;
      case 1:
        context.push('/notes');
        break;
      case 2:
        context.push('/ai-analyze');
        break;
      case 3:
        context.push('/spaces');
        break;
      case 4:
        context.push('/settings');
        break;
    }
  }

  BottomNavigationBarItem buildItem({
    required IconData icon,
    required String label,
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
        child: Icon(
          icon,
          color: isSelected
              ? (iconColor ?? const Color(0xFF3377FF))
              : const Color(0xFF8E9099),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F111A).withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: const Color(0xFF3377FF),
          unselectedItemColor: const Color(0xFF8E9099),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            buildItem(icon: Icons.home, label: 'Home', index: 0),
            buildItem(icon: Icons.description, label: 'Notes', index: 1),
            buildItem(
              icon: Icons.auto_awesome,
              label: '',
              index: 2,
              activeBg: const Color(0xFF2C134A),
              iconColor: const Color(0xFFC084FC),
            ),
            buildItem(icon: Icons.folder, label: 'Spaces', index: 3),
            buildItem(icon: Icons.settings, label: 'Settings', index: 4),
          ],
        ),
      ),
    );
  }
}
