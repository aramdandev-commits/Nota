import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/ai_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/favorite_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        context.push('/notes');
        break;
      case 2:
        context.push('/ai');
        break;
      case 3:
        context.push('/spaces');
        break;
      case 4:
        context.push('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 24),
              const CustomSearchBar(),
              const SizedBox(height: 24),
              const AICard(),
              const SizedBox(height: 24),
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: const Color(0xFF8E9099),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.add,
                      iconColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE520A4),
                      title: 'New Note',
                      subtitle: 'Start writing',
                      onTap: () => context.push('/new-note'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.auto_awesome,
                      iconColor: Colors.white,
                      iconBackgroundColor: const Color(0xFF1D84FF),
                      title: 'AI Analyze',
                      subtitle: 'Summarize',
                      onTap: () => context.push('/ai-analyze'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.upload_file,
                      iconColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFF8A00),
                      title: 'Import PDF',
                      subtitle: 'PDF → Note',
                      onTap: () => context.push('/import-pdf'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.group_add,
                      iconColor: Colors.white,
                      iconBackgroundColor: const Color(0xFF00C48C),
                      title: 'Collaborate',
                      subtitle: 'Team notes',
                      onTap: () => context.push('/collaborate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'FAVORITES',
                style: TextStyle(
                  color: const Color(0xFF8E9099),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const FavoriteCard(
                      date: 'Nov 19',
                      title: 'Project Ideas 💡',
                      subtitle: 'Collection of innovative project',
                      icon: Icons.star,
                    ),
                    const SizedBox(width: 16),
                    const FavoriteCard(
                      date: 'Nov 17',
                      title: 'Reading Notes - AI Research',
                      subtitle: 'Key insights from recent AI papers: large',
                      icon: Icons.star,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT NOTES',
                    style: TextStyle(
                      color: const Color(0xFF8E9099),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: View all recent notes
                    },
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: const Color(0xFF3377FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: const Color(0xFF3377FF), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Padding for Bottom Nav and FAB
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => context.push('/new-note'),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE520A4), Color(0xFF7A36DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE520A4).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: Theme(
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
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF3377FF),
            unselectedItemColor: const Color(0xFF8E9099),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 ? const Color(0xFF162544) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_filled),
                ),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.description_outlined),
                ),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C134A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFC084FC)),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.folder_outlined),
                ),
                label: 'Spaces',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.settings_outlined),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
