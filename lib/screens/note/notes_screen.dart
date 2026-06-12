import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';
import '../../controllers/space_details_provider.dart';
import '../../model/note_model.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/note/delete_note_sheet.dart';
import 'trash_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Text(
                AppLocalizations.of(context)!.myNotes,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2D) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: const Color(0xFF3377FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.all,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border, size: 16),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.favorites,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.trash,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2D) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(color: cs.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchNotes,
                          hintStyle: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5),
                              fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotesList(context, filter: 'all'),
                  _buildNotesList(context, filter: 'favorites'),
                  const TrashScreen(),
                ],
              ),
            ),
          ],
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
      bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
    );
  }



  Widget _buildNotesList(BuildContext context, {required String filter}) {
    return Consumer2<NoteProvider, SpaceDetailsProvider>(
      builder: (context, noteProvider, spaceDetailsProvider, child) {
        final allNotes = [
          ...noteProvider.notes,
          ...spaceDetailsProvider.notes.map((sn) => NoteModel(
                id: sn.id,
                spaceId: 'unknown',
                title: sn.title,
                content: sn.content,
                preview: sn.preview,
                createdAt: sn.createdAt,
                updatedAt: sn.updatedAt ?? sn.createdAt,
                isFavorite:
                    false, // Space notes might not support favorites yet
              ))
        ];

        allNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        List<NoteModel> filteredNotes = allNotes;
        if (filter == 'favorites') {
          filteredNotes = filteredNotes.where((n) => n.isFavorite).toList();
        }

        if (_searchQuery.isNotEmpty) {
          filteredNotes = filteredNotes.where((n) {
            return n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (n.preview ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (filteredNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noNotesFoundYet,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.54),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          itemCount: filteredNotes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return NoteCard(
              note: filteredNotes[index],
            );
          },
        );
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  Color _getAvatarColor(String letter) {
    final colors = [
      const Color(0xFF3377FF),
      const Color(0xFFE520A4),
      const Color(0xFF00C48C),
      const Color(0xFFFF8A00),
      const Color(0xFF7A36DC),
    ];
    int index =
        letter.codeUnits.isNotEmpty ? letter.codeUnits[0] % colors.length : 0;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title = note.title.isNotEmpty
        ? note.title
        : AppLocalizations.of(context)!.untitledNote;
    String firstLetter =
        title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?';
    String previewText = note.preview ?? '';
    if (previewText.isEmpty) {
      previewText = AppLocalizations.of(context)!.emptyNote;
    }

    return GestureDetector(
      onTap: () => context.push('/new-note', extra: note),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DeleteNoteSheet(
            noteId: note.id,
            isTrash: note.isDeleted,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161622) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  _getAvatarColor(firstLetter).withValues(alpha: 0.2),
              radius: 20,
              child: Text(
                firstLetter,
                style: TextStyle(
                  color: _getAvatarColor(firstLetter),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                        GestureDetector(
                          onTap: () {
                            context
                                .read<NoteProvider>()
                                .toggleFavorite(note.id);
                          },
                          child: Icon(
                            note.isFavorite ? Icons.star : Icons.star_border,
                            color: note.isFavorite
                                ? const Color(0xFFFFD700)
                                : cs.onSurface.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(note.updatedAt),
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    previewText,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3377FF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
