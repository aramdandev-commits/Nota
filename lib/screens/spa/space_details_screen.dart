import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/space_details_provider.dart';
import '../../controllers/spaces_provider.dart';
import '../../model/space_model.dart';
import '../../model/space_note_model.dart';
import '../../model/space_settings_model.dart';
import 'space_note_view_screen.dart';
import '../../widgets/spa/member_card.dart';
import '../../widgets/spa/space_text_field.dart';
import '../../widgets/spa/space_switch_tile.dart';
import '../../widgets/spa/space_action_button.dart';

class SpaceDetailsScreen extends StatefulWidget {
  final SpaceModel space;
  const SpaceDetailsScreen({super.key, required this.space});

  @override
  State<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SpaceDetailsProvider>();
      p.fetchNotes(widget.space.id);
      p.fetchMembers(widget.space.id);
    });
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsBottomSheet(space: widget.space),
    );
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InviteMemberSheet(),
    );
  }

  void _showCreateNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateNoteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final space = widget.space;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: cs.onSurface, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: space.iconColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(space.iconData, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(space.title,
                            style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(space.description,
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showOptionsSheet,
                    child: Icon(Icons.settings_outlined,
                        color: cs.onSurface.withValues(alpha: 0.5), size: 22),
                  ),
                ],
              ),
            ),

            // Meta row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.description_outlined,
                          color: cs.onSurface.withValues(alpha: 0.4), size: 14),
                      const SizedBox(width: 4),
                      Consumer<SpaceDetailsProvider>(
                        builder: (_, p, __) => Text('${p.notes.length} notes',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.4),
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          color: cs.onSurface.withValues(alpha: 0.4), size: 14),
                      const SizedBox(width: 4),
                      Consumer<SpaceDetailsProvider>(
                        builder: (_, p, __) => Text(
                            '${p.members.length} members',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.4),
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  _RoleBadge(role: space.role),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          space.privacy == SpacePrivacy.private
                              ? Icons.lock_outline
                              : Icons.language,
                          color: cs.onSurface.withValues(alpha: 0.4),
                          size: 14),
                      const SizedBox(width: 4),
                      Text(
                          space.privacy == SpacePrivacy.private
                              ? AppLocalizations.of(context)!.private
                              : AppLocalizations.of(context)!.public,
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.4),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Consumer<SpaceDetailsProvider>(
              builder: (ctx, provider, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TabButton(
                        label:
                            '${AppLocalizations.of(context)!.myNotes} (${provider.notes.length})',
                        icon: Icons.description_outlined,
                        isSelected: provider.activeTab == 'notes',
                        onTap: () => provider.setActiveTab('notes')),
                    const SizedBox(width: 12),
                    _TabButton(
                        label:
                            '${AppLocalizations.of(context)!.members} (${provider.members.length})',
                        icon: Icons.people_outline,
                        isSelected: provider.activeTab == 'members',
                        onTap: () => provider.setActiveTab('members')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search + action row
            Consumer<SpaceDetailsProvider>(
              builder: (ctx, provider, _) {
                final isMembersTab = provider.activeTab == 'members';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF151821)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: isDark
                                  ? null
                                  : Border.all(
                                      color:
                                          cs.onSurface.withValues(alpha: 0.1))),
                          child: TextField(
                            onChanged: isMembersTab
                                ? provider.searchMembers
                                : provider.searchNotes,
                            style: TextStyle(color: cs.onSurface, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: isMembersTab
                                  ? AppLocalizations.of(context)!.searchMembers
                                  : AppLocalizations.of(context)!.searchNotes,
                              hintStyle: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.4)),
                              prefixIcon: Icon(Icons.search,
                                  color: cs.onSurface.withValues(alpha: 0.4),
                                  size: 18),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isMembersTab
                            ? _showInviteSheet
                            : _showCreateNoteSheet,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                              color: const Color(0xFF6B58FF),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Icon(
                                  isMembersTab
                                      ? Icons.person_add_outlined
                                      : Icons.add,
                                  color: Colors.white,
                                  size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  isMembersTab
                                      ? AppLocalizations.of(context)!.invite
                                      : AppLocalizations.of(context)!.addNote,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Consumer<SpaceDetailsProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading && provider.activeTab == 'notes') {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6B58FF)));
                  }
                  if (provider.activeTab == 'members') {
                    return _MembersTab(
                        myRole: widget.space.role, provider: provider);
                  }
                  return _NotesTab(
                      provider: provider, spaceRole: widget.space.role);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notes Tab ─────────────────────────────────────────────────────────────────

class _NotesTab extends StatelessWidget {
  final SpaceDetailsProvider provider;
  final SpaceRole spaceRole;
  const _NotesTab({required this.provider, required this.spaceRole});

  @override
  Widget build(BuildContext context) {
    final notes = provider.filteredNotes;
    if (notes.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noNotesFound,
              style: TextStyle(color: Color(0xFF6B7280))));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _NoteCard(note: notes[i], spaceRole: spaceRole),
    );
  }
}

// ── Members Tab ───────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final SpaceRole myRole;
  final SpaceDetailsProvider provider;
  const _MembersTab({required this.myRole, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isMembersLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B58FF)));
    }
    final members = provider.filteredMembers;
    if (members.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noMembersFound,
              style: TextStyle(color: Color(0xFF6B7280))));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: members.length,
      itemBuilder: (ctx, i) => MemberCard(member: members[i], myRole: myRole),
    );
  }
}

// ── Note Card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final SpaceNoteModel note;
  final SpaceRole spaceRole;
  const _NoteCard({required this.note, required this.spaceRole});

  String _timeLabel(DateTime dt, {bool isEdited = false}) {
    final diff = DateTime.now().difference(dt);
    String timeStr = '';
    if (diff.inDays == 0) {
      timeStr = 'Today';
    } else if (diff.inDays == 1)
      timeStr = 'Yesterday';
    else {
      const m = [
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
      timeStr = '${m[dt.month - 1]} ${dt.day}';
    }
    return isEdited ? 'Edited $timeStr' : timeStr;
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteOptionsSheet(note: note, spaceRole: spaceRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => SpaceNoteViewScreen(note: note))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF151821)
                  : Theme.of(context).cardColor,
              border: isDark
                  ? null
                  : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(children: [
                      Flexible(
                          child: Text(note.title,
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (note.isFavorite) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star,
                            color: Color(0xFFFBBF24), size: 14)
                      ],
                    ]),
                  ),
                  GestureDetector(
                      onTap: () => _showOptions(context),
                      child: Icon(Icons.more_vert,
                          color: cs.onSurface.withValues(alpha: 0.4),
                          size: 20)),
                ],
              ),
              const SizedBox(height: 6),
              Text(note.content,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.access_time,
                    color: cs.onSurface.withValues(alpha: 0.4), size: 12),
                const SizedBox(width: 4),
                Text(
                    _timeLabel(note.updatedAt ?? note.createdAt,
                        isEdited: note.updatedAt != null),
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        fontSize: 11)),
                const SizedBox(width: 10),
                Expanded(
                    child: Wrap(
                        spacing: 6,
                        children:
                            note.tags.map((t) => _TagChip(tag: t)).toList())),
              ]),
            ],
          ),
        ));
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202430) : Theme.of(context).cardColor,
          border: isDark
              ? null
              : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(6)),
      child: Text(tag,
          style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10)),
    );
  }
}

// ── Create Note Sheet ─────────────────────────────────────────────────────────

class _CreateNoteSheet extends StatefulWidget {
  final SpaceNoteModel? note;
  const _CreateNoteSheet({this.note});
  @override
  State<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<_CreateNoteSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.note?.title ?? '');
    _tagsCtrl = TextEditingController(text: widget.note?.tags.join(', ') ?? '');
    _descCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) =>
      raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151821)
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Handle(),
          const SizedBox(height: 20),
          Text(
              widget.note == null
                  ? AppLocalizations.of(context)!.createNote
                  : AppLocalizations.of(context)!.editNote,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              widget.note == null
                  ? AppLocalizations.of(context)!.createNoteDescription
                  : AppLocalizations.of(context)!.updateYourDetail,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.noteName,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SpaceTextField(
              controller: _nameCtrl,
              hintText: AppLocalizations.of(context)!.enterNoteName),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.description,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SpaceTextField(
            controller: _descCtrl,
            hintText: AppLocalizations.of(context)!.enterDescription,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.tag,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SpaceTextField(
              controller: _tagsCtrl,
              hintText: AppLocalizations.of(context)!.tagDescription),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: SpaceActionButton(
                    label: AppLocalizations.of(context)!.cancel,
                    variant: SpaceButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(
              child: SpaceActionButton(
                label: widget.note == null
                    ? AppLocalizations.of(context)!.createNoteSpaces
                    : AppLocalizations.of(context)!.updateNote,
                onPressed: () {
                  final nav = Navigator.of(context);
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) return;

                  if (widget.note != null) {
                    context.read<SpaceDetailsProvider>().editNote(
                        widget.note!.id,
                        name,
                        _descCtrl.text.trim(),
                        _parseTags(_tagsCtrl.text));
                  } else {
                    final note = SpaceNoteModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: name,
                      content: _descCtrl.text.trim(),
                      authorName: 'You',
                      createdAt: DateTime.now(),
                      tags: _parseTags(_tagsCtrl.text),
                    );
                    context.read<SpaceDetailsProvider>().addNote(note);
                  }
                  nav.pop();
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Note Options Sheet ────────────────────────────────────────────────────────

class _NoteOptionsSheet extends StatelessWidget {
  final SpaceNoteModel note;
  final SpaceRole spaceRole;
  const _NoteOptionsSheet({required this.note, required this.spaceRole});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canDelete =
        spaceRole == SpaceRole.admin || spaceRole == SpaceRole.contributor;
    return Container(
      decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF151821)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          const SizedBox(height: 20),
          _OptionTile(
            icon: note.isFavorite ? Icons.star : Icons.star_border,
            iconColor: const Color(0xFFFBBF24),
            label: note.isFavorite
                ? AppLocalizations.of(context)!.removeFavorite
                : AppLocalizations.of(context)!.toggleFavorite,
            onTap: () {
              final nav = Navigator.of(context);
              context.read<SpaceDetailsProvider>().toggleFavorite(note.id);
              nav.pop();
            },
          ),
          if (canDelete) ...[
            Divider(color: cs.onSurface.withValues(alpha: 0.1)),
            _OptionTile(
              icon: Icons.edit_outlined,
              iconColor: const Color(0xFF60A5FA),
              label: AppLocalizations.of(context)!.editNote,
              onTap: () {
                final nav = Navigator.of(context);
                nav.pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _CreateNoteSheet(note: note),
                );
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFEF4444),
              label: AppLocalizations.of(context)!.deleteNote,
              labelColor: const Color(0xFFEF4444),
              onTap: () {
                final nav = Navigator.of(context);
                context.read<SpaceDetailsProvider>().deleteNote(note.id);
                nav.pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ── Space Options Sheet ───────────────────────────────────────────────────────

class _OptionsBottomSheet extends StatelessWidget {
  final SpaceModel space;
  const _OptionsBottomSheet({required this.space});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = space.role == SpaceRole.admin;
    return Container(
      decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF151821)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          const SizedBox(height: 20),
          if (isAdmin) ...[
            _OptionTile(
              icon: Icons.edit_outlined,
              iconColor: const Color(0xFF6B58FF),
              label: AppLocalizations.of(context)!.editSpace,
              onTap: () {
                final nav = Navigator.of(context);
                nav.pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _EditSpaceSheet(space: space),
                );
              },
            ),
            Divider(color: cs.onSurface.withValues(alpha: 0.1)),
            _OptionTile(
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFEF4444),
              label: AppLocalizations.of(context)!.deleteSpace,
              labelColor: const Color(0xFFEF4444),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: isDark
                        ? const Color(0xFF151821)
                        : Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(AppLocalizations.of(context)!.deleteSpace,
                        style: TextStyle(color: cs.onSurface)),
                    content: Text(
                        '${AppLocalizations.of(context)!.delete}" ${space.title} "${AppLocalizations.of(context)!.thisCannotBe}',
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5))),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5)))),
                      TextButton(
                        onPressed: () {
                          final provider = dialogCtx.read<SpacesProvider>();
                          Navigator.pop(dialogCtx); // pop dialog
                          Navigator.pop(context); // pop bottom sheet
                          Navigator.pop(context); // pop details screen
                          provider.deleteSpace(space.id);
                        },
                        child: Text(AppLocalizations.of(context)!.delete,
                            style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else
            _OptionTile(
              icon: Icons.logout,
              iconColor: const Color(0xFFEF4444),
              label: AppLocalizations.of(context)!.leaveSpace,
              labelColor: const Color(0xFFEF4444),
              onTap: () {
                final provider = context.read<SpacesProvider>();
                Navigator.pop(context); // pop bottom sheet
                Navigator.pop(context); // pop details screen
                provider.deleteSpace(space.id);
              },
            ),
        ],
      ),
    );
  }
}

// ── Edit Space Sheet ──────────────────────────────────────────────────────────

class _EditSpaceSheet extends StatefulWidget {
  final SpaceModel space;
  const _EditSpaceSheet({required this.space});
  @override
  State<_EditSpaceSheet> createState() => _EditSpaceSheetState();
}

class _EditSpaceSheetState extends State<_EditSpaceSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.space.title);
    _descCtrl = TextEditingController(text: widget.space.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<SpaceDetailsProvider>(
      builder: (ctx, provider, _) => Container(
        decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF151821)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Handle(),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.editSpace,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.spaceName,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SpaceTextField(
                  controller: _nameCtrl,
                  hintText: AppLocalizations.of(context)!.enterSpaceName),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.description,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SpaceTextField(
                  controller: _descCtrl,
                  hintText: AppLocalizations.of(context)!.enterDescription,
                  maxLines: 3),
              const SizedBox(height: 16),
              SpaceSwitchTile(
                title: AppLocalizations.of(context)!.allowMembersToEdit,
                subtitle:
                    AppLocalizations.of(context)!.allowMembersToEditDescription,
                value: provider.allowMembersToEdit,
                onChanged: provider.setAllowMembersToEdit,
              ),
              const SizedBox(height: 10),
              SpaceSwitchTile(
                title: AppLocalizations.of(context)!.makeSpacePublic,
                subtitle: AppLocalizations.of(context)!.anyoneWithLink,
                value: provider.isPublic,
                onChanged: provider.setIsPublic,
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: SpaceActionButton(
                        label: AppLocalizations.of(context)!.cancel,
                        variant: SpaceButtonVariant.secondary,
                        onPressed: () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(
                  child: SpaceActionButton(
                    label: AppLocalizations.of(context)!.save,
                    isLoading: provider.isSaving,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final settings = SpaceSettingsModel(
                        name: _nameCtrl.text.trim(),
                        description: _descCtrl.text.trim(),
                        isPublic: provider.isPublic,
                        allowMembersToEdit: provider.allowMembersToEdit,
                        invitedEmails: [],
                      );
                      await provider.updateSpaceSettings(settings);
                      context
                          .read<SpacesProvider>()
                          .renameSpace(widget.space.id, settings.name);
                      nav.pop();
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Invite Member Sheet ───────────────────────────────────────────────────────

class _InviteMemberSheet extends StatefulWidget {
  const _InviteMemberSheet();
  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF151821)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Handle(),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.inviteMembers,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.inviteMembersDescription,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5), fontSize: 14)),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.emailAddress,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SpaceTextField(
              controller: _emailCtrl,
              hintText: AppLocalizations.of(context)!.enterEmail,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: SpaceActionButton(
                    label: AppLocalizations.of(context)!.cancel,
                    variant: SpaceButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(
              child: SpaceActionButton(
                label: AppLocalizations.of(context)!.sendInvite,
                onPressed: () {
                  final nav = Navigator.of(context);
                  final email = _emailCtrl.text.trim();
                  if (email.isNotEmpty) {
                    context.read<SpaceDetailsProvider>().inviteMember(email);
                  }
                  nav.pop();
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(2)),
        ),
      );
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon,
      required this.iconColor,
      required this.label,
      this.labelColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  color: labelColor ?? cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? const Color(0xFF1A1F36) : const Color(0xFF151821))
              : (isSelected
                  ? cs.primary.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: cs.primary)
              : (isDark
                  ? null
                  : Border.all(color: cs.onSurface.withValues(alpha: 0.1))),
        ),
        child: Row(children: [
          Icon(icon,
              color:
                  isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
              size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final SpaceRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color text;
    Color bg;
    String label;
    IconData icon;
    switch (role) {
      case SpaceRole.admin:
        text = const Color(0xFFFBBF24);
        bg = const Color(0xFF332B13);
        label = AppLocalizations.of(context)!.admin;
        icon = Icons.star_border;
        break;
      case SpaceRole.contributor:
        text = const Color(0xFF60A5FA);
        bg = const Color(0xFF14243B);
        label = AppLocalizations.of(context)!.contributor;
        icon = Icons.edit_outlined;
        break;
      case SpaceRole.viewer:
        text = const Color(0xFF9CA3AF);
        bg = const Color(0xFF202430);
        label = AppLocalizations.of(context)!.viewer;
        icon = Icons.visibility_outlined;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: text, size: 11),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: text, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
