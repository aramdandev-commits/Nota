import 'package:flutter/material.dart';

enum SpaceRole { admin, contributor, viewer }

class SpaceModel {
  final String id;
  final String title;
  final String description;
  final SpaceRole role;
  final int memberCount;
  final int noteCount;
  final Color iconColor;
  final IconData iconData;
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
    this.lastEditedBy,
    this.lastEditedAction,
    this.lastEditedAt,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'].toString(),
      title: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      role: SpaceRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => SpaceRole.admin,
      ),
      memberCount: json['member_count'] as int? ?? 1,
      noteCount: json['note_count'] as int? ?? 0,
      iconColor: json['icon_color'] != null 
          ? Color(int.parse(json['icon_color'].toString().replaceAll('#', '0xff'))) 
          : const Color(0xFF6B58FF),
      iconData: json['icon_code_point'] != null 
          ? IconData(json['icon_code_point'] as int, fontFamily: 'MaterialIcons') 
          : Icons.folder_open,
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
      'last_edited_by': lastEditedBy,
      'last_edited_action': lastEditedAction,
      'last_edited_at': lastEditedAt?.toIso8601String(),
    };
  }
}
