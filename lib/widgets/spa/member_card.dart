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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151821),
        borderRadius: BorderRadius.circular(16),
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
                    style: const TextStyle(
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
                          Border.all(color: const Color(0xFF151821), width: 2),
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
                        style: const TextStyle(
                            color: Colors.white,
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
                        child: const Text('You',
                            style: TextStyle(
                                color: Color(0xFF8B949E), fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.email,
                    style: const TextStyle(
                        color: Color(0xFF8B949E), fontSize: 12)),
                const SizedBox(height: 2),
                Text(_joinedLabel(member.joinedAt),
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 11)),
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
              child: const Icon(Icons.more_vert,
                  color: Color(0xFF6B7280), size: 20),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2030),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: const Color(0xFF374151),
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
          const Divider(color: Color(0xFF1E212B), height: 8),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2030),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Change Role',
              style: TextStyle(
                  color: Colors.white,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F36) : const Color(0xFF202430),
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? Border.all(color: const Color(0xFF6B58FF)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF6B58FF), size: 18),
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
                    color: labelColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
