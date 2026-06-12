import 'package:flutter/material.dart';

enum SpaceRole { owner, admin, editor, viewer }

class SpaceModel {
  final String id;
  final String title;
  final String description;
  final SpaceRole currentUserRole;
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
    required this.currentUserRole,
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
      currentUserRole: () {
        final pivot = json['pivot'] as Map<String, dynamic>?;
        final roleStr = pivot != null ? pivot['role']?.toString() : json['role']?.toString();
        final r = roleStr?.toLowerCase();
        
        if (r == 'owner') return SpaceRole.owner;
        if (r == 'admin') return SpaceRole.admin;
        if (r == 'editor') return SpaceRole.editor;
        if (r == 'viewer') return SpaceRole.viewer;
        return SpaceRole.viewer;
      }(),
      memberCount: json['users_count'] as int? ?? json['member_count'] as int? ?? 1,
      noteCount: json['notes_count'] as int? ?? json['note_count'] as int? ?? 0,
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
      'role': currentUserRole.toString().split('.').last,
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
