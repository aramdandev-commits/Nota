import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/space_member_model.dart';
import '../../model/space_model.dart';
import '../../controllers/space_details_provider.dart';

class MemberCard extends StatelessWidget {
  final SpaceMemberModel member;
  final SpaceRole myRole;

  const MemberCard({Key? key, required this.member, required this.myRole})
      : super(key: key);

  void _showMemberOptions(BuildContext context) {
    if (myRole != SpaceRole.admin) return;
    if (member.isCurrentUser) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberOptionsSheet(member: member),
    );
  }

  String _joinedLabel(DateTime dt) {
    final months = [
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
    return 'Joined ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151821) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: member.avatarColor,
                child: Text(member.initials,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              if (member.isCurrentUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07C168),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: isDark ? const Color(0xFF151821) : Theme.of(context).cardColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Name + email + joined
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.name,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (member.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202430),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('You',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.email,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                const SizedBox(height: 2),
                Text(_joinedLabel(member.joinedAt),
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
              ],
            ),
          ),
          // Role badge
          _RoleBadge(role: member.role),
          // Options button (admin only, not for self)
          if (myRole == SpaceRole.admin && !member.isCurrentUser) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showMemberOptions(context),
              child: Icon(Icons.more_vert,
                  color: cs.onSurface.withValues(alpha: 0.4), size: 20),
            ),
          ],
        ],
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
        label = 'Admin';
        icon = Icons.star_border;
        break;
      case SpaceRole.contributor:
        text = const Color(0xFF60A5FA);
        bg = const Color(0xFF14243B);
        label = 'Contributor';
        icon = Icons.edit_outlined;
        break;
      case SpaceRole.viewer:
        text = const Color(0xFF9CA3AF);
        bg = const Color(0xFF202430);
        label = 'Viewer';
        icon = Icons.visibility_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Member Options Sheet ──────────────────────────────────────────────────────

class _MemberOptionsSheet extends StatelessWidget {
  final SpaceMemberModel member;
  const _MemberOptionsSheet({required this.member});

  void _showChangeRole(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangeRoleSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2030) : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          _SheetTile(
            icon: Icons.edit_outlined,
            iconColor: const Color(0xFF6B58FF),
            label: 'Change Role',
            onTap: () => _showChangeRole(context),
          ),
          Divider(color: cs.onSurface.withValues(alpha: 0.1), height: 8),
          _SheetTile(
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFEF4444),
            label: 'Remove',
            labelColor: const Color(0xFFEF4444),
            onTap: () {
              final nav = Navigator.of(context);
              final provider = context.read<SpaceDetailsProvider>();
              provider.removeMember(member.id);
              nav.pop();
            },
          ),
        ],
      ),
    );
  }
}

// ── Change Role Sheet ─────────────────────────────────────────────────────────

class _ChangeRoleSheet extends StatelessWidget {
  final SpaceMemberModel member;
  const _ChangeRoleSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2030) : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Change Role',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          for (final role in [
            SpaceRole.contributor,
            SpaceRole.viewer,
          ])
            _RoleOption(
              role: role,
              isSelected: member.role == role,
              onTap: () {
                final nav = Navigator.of(context);
                context
                    .read<SpaceDetailsProvider>()
                    .changeMemberRole(member.id, role);
                nav.pop();
              },
            ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final SpaceRole role;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleOption(
      {required this.role, required this.isSelected, required this.onTap});

  String get _label =>
      role.toString().split('.').last[0].toUpperCase() +
      role.toString().split('.').last.substring(1);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF1A1F36) : cs.primary.withValues(alpha: 0.1)) 
              : (isDark ? const Color(0xFF202430) : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: cs.primary)
              : (isDark ? null : Border.all(color: cs.onSurface.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_label,
                  style: TextStyle(
                    color: isSelected ? cs.primary : cs.onSurface, 
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: cs.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: labelColor ?? cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
