import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/space_model.dart';
import '../../controllers/space_details_provider.dart';
import '../../screens/spa/space_details_screen.dart';

class SpaceCard extends StatelessWidget {
  final SpaceModel space;

  const SpaceCard({Key? key, required this.space}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Reset and load notes for the tapped space
        context.read<SpaceDetailsProvider>().fetchNotes(space.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpaceDetailsScreen(space: space),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151821) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: space.iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                space.iconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          space.title,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        space.privacy == SpacePrivacy.private
                            ? Icons.lock_outline
                            : Icons.language,
                        color: const Color(0xFF6B7280),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    space.description,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildRoleBadge(space.role),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${space.memberCount} members  ·  ${space.noteCount} notes',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(SpaceRole role) {
    Color textColor;
    Color bgColor;
    String text;
    IconData? icon;

    switch (role) {
      case SpaceRole.admin:
        textColor = const Color(0xFFFBBF24); // Yellow
        bgColor = const Color(0xFF332B13);
        text = 'Admin';
        icon = Icons.star_border;
        break;
      case SpaceRole.contributor:
        textColor = const Color(0xFF60A5FA); // Blue
        bgColor = const Color(0xFF14243B);
        text = 'Contributor';
        icon = Icons.edit_outlined;
        break;
      case SpaceRole.viewer:
        textColor = const Color(0xFF9CA3AF); // Grey
        bgColor = const Color(0xFF202430);
        text = 'Viewer';
        icon = Icons.visibility_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
