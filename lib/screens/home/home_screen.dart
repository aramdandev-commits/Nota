import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/widgets/home/bottom_navigation.dart';
import 'package:nota/widgets/pdf/import_pdf.dart';
import 'package:provider/provider.dart';
import '../../controllers/note_provider.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/search_bar.dart';
import '../../widgets/home/ai_card.dart';
import '../../widgets/home/quick_action_button.dart';
import '../../widgets/home/favorite_card.dart';
import '../../widgets/pdf/nota_modal_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showImportPdfSheet(BuildContext context) {
    NotaModalSheet.show(
      context: context,
      icon: Icons.picture_as_pdf_rounded,
      title: 'Import PDF',
      subtitle: 'Upload a PDF file to convert into a note',
      body: const ImportPdfBody(),
      cancelLabel: 'Cancel',
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Inter',
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
                      onTap: () => _showImportPdfSheet(context),
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
                      onTap: () => context.push('/spaces'),
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
                  Text(
                    'RECENT NOTES',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No recent notes yet.',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                              fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentNotes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = recentNotes[index];

                      String previewText = getPreviewText(note.content);
                      return GestureDetector(
                        onTap: () {
                          context.push('/new-note', extra: note.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title.isNotEmpty
                                    ? note.title
                                    : 'Untitled Note',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                previewText.isNotEmpty
                                    ? previewText
                                    : 'Empty Note',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.54),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Updated: ${note.updatedAt.toString().substring(0, 16)}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.38),
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
      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
}

String getPreviewText(String content) {
  if (content.isEmpty) return "No content";
  try {
    final List<dynamic> ops = jsonDecode(content);
    String text = ops.map((op) => op['insert']?.toString() ?? '').join('').replaceAll('\n', ' ').trim();
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  } catch (e) {
    return "Rich text note (Open to view)";
  }
}
