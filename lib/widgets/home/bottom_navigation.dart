import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.push('/notes');
        break;
      case 2:
        context.go('/ai-analyze');
        break;
      case 3:
        context.go('/spaces');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    BottomNavigationBarItem buildItem({
      required IconData icon,
      required String label,
      required int index,
      Color? activeBg,
      Color? iconColor,
    }) {
      final isSelected = selectedIndex == index;
      final activeIconColor = iconColor ?? const Color(0xFF3377FF);
      final activeBackground = activeBg ??
          (isDark ? const Color(0xFF162544) : const Color(0xFFE8EEFF));

      return BottomNavigationBarItem(
        label: label,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? activeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? activeIconColor
                : cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: cs.onSurface.withValues(alpha: 0.08),
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
          unselectedItemColor: cs.onSurface.withValues(alpha: 0.4),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            buildItem(
                icon: Icons.home,
                label: AppLocalizations.of(context)!.home,
                index: 0),
            buildItem(
                icon: Icons.description,
                label: AppLocalizations.of(context)!.myNotes,
                index: 1),
            buildItem(
              icon: Icons.auto_awesome,
              label: '',
              index: 2,
              activeBg:
                  isDark ? const Color(0xFF2C134A) : const Color(0xFFF3EAFF),
              iconColor: const Color(0xFFC084FC),
            ),
            buildItem(
                icon: Icons.folder,
                label: AppLocalizations.of(context)!.spaces,
                index: 3),
            buildItem(
                icon: Icons.settings,
                label: AppLocalizations.of(context)!.settings,
                index: 4),
          ],
        ),
      ),
    );
  }
}
