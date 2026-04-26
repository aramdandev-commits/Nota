import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteInfoSheet extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String spaceName;

  const NoteInfoSheet({
    super.key,
    this.createdAt,
    this.modifiedAt,
    this.spaceName = 'Research Space',
  });

  @override
  Widget build(BuildContext context) {
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color itemColor = Color(0xFF2A2A38);
    const Color textColor = Colors.white;
    const Color subtitleColor = Colors.grey;

    final DateTime actualCreated = createdAt ?? DateTime.now();
    final DateTime actualModified = modifiedAt ?? DateTime.now();

    final String createdDate = DateFormat.yMMMMd().format(actualCreated);
    final String createdTime = DateFormat('hh:mm a').format(actualCreated);

    final String modifiedDate = DateFormat.yMMMMd().format(actualModified);
    final String modifiedTime = DateFormat('hh:mm a').format(actualModified);

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
                color: Colors.grey.withValues(alpha: 0.4),
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
                    color: itemColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: subtitleColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Note Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: itemColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: subtitleColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            iconColor: Colors.purpleAccent,
            label: 'Created',
            value: createdDate,
            time: createdTime,
            bgColor: itemColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.access_time_rounded,
            iconColor: Colors.blueAccent,
            label: 'Last Modified',
            value: modifiedDate,
            time: modifiedTime,
            bgColor: itemColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.folder_outlined,
            iconColor: Colors.greenAccent,
            label: 'Space',
            value: spaceName,
            bgColor: itemColor,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: itemColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? time,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (time != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}