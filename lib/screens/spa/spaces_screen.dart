import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/spaces_provider.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/spa/space_card.dart';
import '../../widgets/spa/create_space_bottom_sheet.dart';

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpacesProvider>().fetchSpaces();
    });
  }

  void _showCreateSpaceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSpaceBottomSheet(),
    );
  }

  void _onItemTapped() {}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      children: [
                        Text(
                          AppLocalizations.of(context)!.spaces,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.spacesDescription,
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
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
                    label: Text(
                      AppLocalizations.of(context)!.createSpace,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9810FA),
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
                  color: isDark
                      ? const Color(0xFF151821)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? null
                      : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  onChanged: (value) =>
                      Provider.of<SpacesProvider>(context, listen: false)
                          .searchSpaces(value),
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchSpaces,
                    hintStyle:
                        TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.search,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                        Text(
                          AppLocalizations.of(context)!.mySpaces,
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (spaces.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                AppLocalizations.of(context)!.noSpacesFound,
                                style: TextStyle(color: cs.onSurface),
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
                              Text(
                                AppLocalizations.of(context)!.recentActivity,
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context)!.viewAll,
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
                              color: isDark
                                  ? const Color(0xFF151821)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isDark
                                  ? null
                                  : Border.all(
                                      color:
                                          cs.onSurface.withValues(alpha: 0.1)),
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
                                      style: TextStyle(
                                        color:
                                            cs.onSurface.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${spaceWithActivity.lastEditedBy} ',
                                          style: TextStyle(
                                            color: cs.onSurface,
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
                                            style: TextStyle(
                                              color: cs.onSurface
                                                  .withValues(alpha: 0.5),
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
      bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
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
