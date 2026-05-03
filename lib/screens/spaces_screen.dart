import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/spaces_provider.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/space_card.dart';
import '../widgets/create_space_bottom_sheet.dart';

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({Key? key}) : super(key: key);

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  int _selectedIndex = 3;

  void _showCreateSpaceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSpaceBottomSheet(),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.push('/home');
        break;
      case 1:
        context.push('/notes');
        break;
      case 2:
        context.push('/ai');
        break;
      case 3:
        // Already on Spaces
        break;
      case 4:
        context.push('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14), // Main dark background
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Spaces',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Organize & collaborate\nwith workspaces',
                          style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateSpaceBottomSheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Create Space',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B58FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // Pill shape
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151821),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (value) =>
                      Provider.of<SpacesProvider>(context, listen: false)
                          .searchSpaces(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search spaces...',
                    hintStyle: TextStyle(color: Color(0xFF6B7280)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content Section
            Expanded(
              child: Consumer<SpacesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B58FF),
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Error: ${provider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final spaces = provider.filteredSpaces;

                  // Find a space with recent activity (null-safe)
                  final spaceWithActivity = spaces.isNotEmpty
                      ? spaces.firstWhere(
                          (s) => s.lastEditedBy != null,
                          orElse: () => spaces.first,
                        )
                      : null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MY SPACES Title
                        const Text(
                          'MY SPACES',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (spaces.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No spaces found.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: spaces
                                .map((space) => SpaceCard(space: space))
                                .toList(),
                          ),

                        const SizedBox(height: 16),

                        // RECENT ACTIVITY
                        if (spaceWithActivity != null &&
                            spaceWithActivity.lastEditedBy != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'RECENT ACTIVITY',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'View all',
                                  style: TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151821),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF238EFA),
                                  child: Text(
                                    _getInitials(
                                        spaceWithActivity.lastEditedBy ?? 'U'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Color(0xFF8B949E),
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${spaceWithActivity.lastEditedBy} ',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                            text:
                                                '${spaceWithActivity.lastEditedAction ?? "made changes"} '),
                                        if (spaceWithActivity.lastEditedAt !=
                                            null)
                                          TextSpan(
                                            text:
                                                '· ${_timeAgo(spaceWithActivity.lastEditedAt!)}',
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
              buildItem(
                icon: Icons.home_filled,
                label: 'Home',
                index: 0,
                selectedIndex: _selectedIndex,
              ),
              buildItem(
                icon: Icons.description_outlined,
                label: 'Notes',
                index: 1,
                selectedIndex: _selectedIndex,
              ),
              buildItem(
                icon: Icons.auto_awesome,
                label: '',
                index: 2,
                selectedIndex: _selectedIndex,
                activeBg: const Color(0xFF2C134A),
                iconColor: const Color(0xFFC084FC),
              ),
              buildItem(
                icon: Icons.folder_outlined,
                label: 'Spaces',
                index: 3,
                selectedIndex: _selectedIndex,
              ),
              buildItem(
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

  String _getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = 2;
    if (names.length < 2) numWords = names.length;
    for (var i = 0; i < numWords; i++) {
      initials += names[i][0];
    }
    return initials.toUpperCase();
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
