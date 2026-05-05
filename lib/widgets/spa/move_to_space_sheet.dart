import 'package:flutter/material.dart';

class SpaceModel {
  final String id;
  final String name;
  final int notesCount;
  final int membersCount;
  final IconData icon;
  final Color color;
  final bool isCurrent;

  SpaceModel({
    required this.id,
    required this.name,
    required this.notesCount,
    required this.membersCount,
    required this.icon,
    required this.color,
    this.isCurrent = false,
  });
}

class MoveToSpaceSheet extends StatefulWidget {
  const MoveToSpaceSheet({super.key});

  @override
  State<MoveToSpaceSheet> createState() => _MoveToSpaceSheetState();
}

class _MoveToSpaceSheetState extends State<MoveToSpaceSheet> {
  bool _showSuccess = false;

  final List<SpaceModel> _dummySpaces = [
    SpaceModel(
      id: '1',
      name: 'Personal Space',
      notesCount: 7,
      membersCount: 1,
      icon: Icons.folder_outlined,
      color: const Color(0xFFE91E63),
    ),
    SpaceModel(
      id: '2',
      name: 'Team Space',
      notesCount: 8,
      membersCount: 3,
      icon: Icons.people_outline,
      color: const Color(0xFF2196F3),
    ),
    SpaceModel(
      id: '3',
      name: 'Project Space',
      notesCount: 12,
      membersCount: 2,
      icon: Icons.folder_outlined,
      color: const Color(0xFF4CAF50),
    ),
    SpaceModel(
      id: '4',
      name: 'Research Space',
      notesCount: 5,
      membersCount: 4,
      icon: Icons.insert_drive_file_outlined,
      color: const Color(0xFFFF9800),
      isCurrent: true,
    ),
    SpaceModel(
      id: '5',
      name: 'Archive',
      notesCount: 15,
      membersCount: 1,
      icon: Icons.folder_outlined,
      color: const Color(0xFF9E9E9E),
    ),
  ];

  void _moveToSpace(String spaceId) async {
    setState(() {
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color inputColor = Color(0xFF2A2A38);
    const Color textColor = Colors.white;
    const Color subtitleColor = Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
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
                  decoration: const BoxDecoration(
                    color: inputColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: subtitleColor, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Move to Space',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select a space for this note',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: inputColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: subtitleColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _dummySpaces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final space = _dummySpaces[index];
                return _buildSpaceItem(space);
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
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

  Widget _buildSpaceItem(SpaceModel space) {
    return InkWell(
      onTap: space.isCurrent ? null : () => _moveToSpace(space.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A38),
          borderRadius: BorderRadius.circular(12),
          border: space.isCurrent
              ? Border.all(color: const Color(0xFF3D7AF9).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: space.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(space.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${space.notesCount} notes · ${space.membersCount} member${space.membersCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (space.isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D7AF9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    color: Color(0xFF3D7AF9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}