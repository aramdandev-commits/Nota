import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/note_provider.dart';
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

  BottomNavigationBarItem _buildItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    Color? activeBg,
    Color? iconColor,
  }) {
    final bool isSelected = index == selectedIndex;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected && activeBg != null ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? (iconColor ?? const Color(0xFF3377FF))
              : const Color(0xFF8E9099),
        ),
      ),
      label: label,
    );
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
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: Color(0xFF8E9099),
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
              const Text(
                'FAVORITES',
                style: TextStyle(
                  color: Color(0xFF8E9099),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    FavoriteCard(
                      date: 'Nov 19',
                      title: 'Project Ideas 💡',
                      subtitle: 'Collection of innovative project',
                      icon: Icons.star,
                    ),
                    SizedBox(width: 16),
                    FavoriteCard(
                      date: 'Nov 17',
                      title: 'Reading Notes - AI Research',
                      subtitle: 'Key insights from recent AI papers: large',
                      icon: Icons.star,
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT NOTES',
                    style: TextStyle(
                      color: Color(0xFF8E9099),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/notes');
                    },
                    child: Row(
                      children: const [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF3377FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: Color(0xFF3377FF), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<NoteProvider>(
                builder: (context, noteProvider, child) {
                  final recentNotes = noteProvider.notes.take(5).toList();

                  if (recentNotes.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No recent notes yet.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = recentNotes[index];

                      String previewText = "No content";
                      try {
                        if (note.content.isNotEmpty) {
                          final List<dynamic> ops = jsonDecode(note.content);
                          previewText = ops
                              .map((op) => op['insert']?.toString() ?? '')
                              .join('')
                              .replaceAll('\n', ' ')
                              .trim();
                          if (previewText.length > 50) {
                            previewText = '${previewText.substring(0, 50)}...';
                          }
                        }
                      } catch (e) {
                        previewText = note.content;
                        if (previewText.length > 50) {
                          previewText = '${previewText.substring(0, 50)}...';
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          context.push('/new-note', extra: note.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title.isNotEmpty ? note.title : 'Untitled Note',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                previewText.isNotEmpty ? previewText : 'Empty Note',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Updated: ${note.updatedAt.toString().substring(0, 16)}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 80),
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
                color: const Color(0xFFE520A4).withValues(alpha: 0.3),
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
            color: const Color(0xFF0F111A).withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
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
              _buildItem(
                icon: Icons.home_filled,
                label: 'Home',
                index: 0,
                selectedIndex: _selectedIndex,
              ),
              _buildItem(
                icon: Icons.description_outlined,
                label: 'Notes',
                index: 1,
                selectedIndex: _selectedIndex,
              ),
              _buildItem(
                icon: Icons.auto_awesome,
                label: '',
                index: 2,
                selectedIndex: _selectedIndex,
                activeBg: const Color(0xFF2C134A),
                iconColor: const Color(0xFFC084FC),
              ),
              _buildItem(
                icon: Icons.folder_outlined,
                label: 'Spaces',
                index: 3,
                selectedIndex: _selectedIndex,
              ),
              _buildItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                index: 4,
                selectedIndex: _selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}