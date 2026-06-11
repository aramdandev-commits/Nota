import 'dart:ui';

import '../model/space_model.dart';

class SpaceMemberModel {
  final String id;
  final String name;
  final String email;
  SpaceRole role;
  final DateTime joinedAt;
  final bool isCurrentUser;
  final Color avatarColor;

  SpaceMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.isCurrentUser = false,
    required this.avatarColor,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  factory SpaceMemberModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>?;
    final String id = pivot != null ? pivot['user_id'].toString() : json['id']?.toString() ?? '';
    final String roleStr = pivot != null ? pivot['role'].toString() : json['role']?.toString() ?? 'viewer';

    return SpaceMemberModel(
      id: id,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: () {
        final r = roleStr.toLowerCase();
        if (r == 'owner') return SpaceRole.owner;
        if (r == 'admin') return SpaceRole.admin;
        if (r == 'editor') return SpaceRole.editor;
        if (r == 'viewer') return SpaceRole.viewer;
        return SpaceRole.viewer;
      }(),
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at'] as String) : DateTime.now(),
      isCurrentUser: json['is_current_user'] as bool? ?? false,
      avatarColor: json['avatar_color'] != null 
          ? Color(int.parse(json['avatar_color'].toString().replaceAll('#', '0xff'))) 
          : const Color(0xFF6B58FF),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'joined_at': joinedAt.toIso8601String(),
      'is_current_user': isCurrentUser,
      'avatar_color': '#${avatarColor.value.toRadixString(16).substring(2)}',
    };
  }
}
