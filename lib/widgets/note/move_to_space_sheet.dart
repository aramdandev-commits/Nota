import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/spaces_provider.dart';
import '../../controllers/note_provider.dart';
import '../../model/space_model.dart';

class MoveToSpaceSheet extends StatefulWidget {
  final String noteId;
  final String? currentSpaceId;

  const MoveToSpaceSheet({
    super.key,
    required this.noteId,
    this.currentSpaceId,
  });

  @override
  State<MoveToSpaceSheet> createState() => _MoveToSpaceSheetState();
}

class _MoveToSpaceSheetState extends State<MoveToSpaceSheet> {
  bool _showSuccess = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ensure spaces are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpacesProvider>(context, listen: false).fetchSpaces();
    });
  }

  void _moveToSpace(String? spaceId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<NoteProvider>(context, listen: false)
          .moveNoteToSpace(widget.noteId, spaceId);

      if (mounted) {
        setState(() {
          _showSuccess = true;
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to move note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E2A) : Theme.of(context).scaffoldBackgroundColor;
    final itemBg = isDark ? const Color(0xFF2A2A38) : Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: itemBg, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move to Space',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select a space for this note',
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: itemBg, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: Consumer<SpacesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.spaces.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Create a generic item for "Personal Space"
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: provider.spaces.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isCurrent = widget.currentSpaceId == null;
                      return _buildSpaceItem(
                        context: context,
                        name: 'Personal Space',
                        notesCount: 0, // Could fetch if known
                        membersCount: 1,
                        isCurrent: isCurrent,
                        itemBg: itemBg,
                        cs: cs,
                        icon: Icons.person_outline,
                        color: Colors.blueAccent,
                        onTap: () => isCurrent ? null : _moveToSpace(null),
                      );
                    }

                    final space = provider.spaces[index - 1];
                    final isCurrent = widget.currentSpaceId == space.id;
                    return _buildSpaceItem(
                      context: context,
                      name: space.title,
                      notesCount: space.noteCount,
                      membersCount: space.memberCount,
                      isCurrent: isCurrent,
                      itemBg: itemBg,
                      cs: cs,
                      icon: Icons.folder_outlined,
                      color: Colors.teal,
                      onTap: () => isCurrent ? null : _moveToSpace(space.id),
                    );
                  },
                );
              },
            ),
          ),
          if (_showSuccess) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B332B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Moved successfully',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSpaceItem({
    required BuildContext context,
    required String name,
    required int notesCount,
    required int membersCount,
    required bool isCurrent,
    required Color itemBg,
    required ColorScheme cs,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent
              ? Border.all(color: const Color(0xFF3D7AF9).withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$notesCount notes · $membersCount member${membersCount > 1 ? 's' : ''}',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D7AF9).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(color: Color(0xFF3D7AF9), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}