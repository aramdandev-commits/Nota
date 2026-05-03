import 'package:flutter/material.dart';

enum SpaceRole { admin, contributor, viewer }
enum SpacePrivacy { private, public }

class SpaceModel {
  final String id;
  final String title;
  final String description;
  final SpaceRole role;
  final int memberCount;
  final int noteCount;
  final Color iconColor;
  final IconData iconData;
  final SpacePrivacy privacy;
  final String? lastEditedBy;
  final String? lastEditedAction;
  final DateTime? lastEditedAt;

  SpaceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.role,
    required this.memberCount,
    required this.noteCount,
    required this.iconColor,
    required this.iconData,
    required this.privacy,
    this.lastEditedBy,
    this.lastEditedAction,
    this.lastEditedAt,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      role: SpaceRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => SpaceRole.viewer,
      ),
      memberCount: json['member_count'] as int? ?? 0,
      noteCount: json['note_count'] as int? ?? 0,
      iconColor: Color(int.parse(json['icon_color'].toString().replaceAll('#', '0xff'))),
      iconData: IconData(json['icon_code_point'] as int, fontFamily: 'MaterialIcons'),
      privacy: SpacePrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == json['privacy'],
        orElse: () => SpacePrivacy.private,
      ),
      lastEditedBy: json['last_edited_by'] as String?,
      lastEditedAction: json['last_edited_action'] as String?,
      lastEditedAt: json['last_edited_at'] != null 
          ? DateTime.parse(json['last_edited_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'role': role.toString().split('.').last,
      'member_count': memberCount,
      'note_count': noteCount,
      'icon_color': '#${iconColor.value.toRadixString(16).substring(2)}',
      'icon_code_point': iconData.codePoint,
      'privacy': privacy.toString().split('.').last,
      'last_edited_by': lastEditedBy,
      'last_edited_action': lastEditedAction,
      'last_edited_at': lastEditedAt?.toIso8601String(),
    };
  }
}
