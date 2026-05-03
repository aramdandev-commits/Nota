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
    return SpaceMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: SpaceRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => SpaceRole.viewer,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      isCurrentUser: json['is_current_user'] as bool? ?? false,
      avatarColor: Color(
          int.parse(json['avatar_color'].toString().replaceAll('#', '0xff'))),
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
