import 'package:flutter/material.dart';
import '../model/space_note_model.dart';
import '../model/space_member_model.dart';
import '../model/space_model.dart';

class SpaceDetailsRepository {
  /// Simulates fetching notes for a specific space from the backend.
  /// Replace [Future.delayed] + mock data with real http.get() call later.
  Future<List<SpaceNoteModel>> getNotesForSpace(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data keyed by spaceId for realistic simulation
    final Map<String, List<SpaceNoteModel>> mockData = {
      '1': [
        SpaceNoteModel(
          id: 'n1',
          title: 'Q4 Marketing Strategy',
          content:
              'Detailed strategy for Q4 campaigns including social media, email, and content marketing...',
          authorName: 'Sarah Khan',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isFavorite: true,
          tags: ['strategy', 'marketing'],
        ),
        SpaceNoteModel(
          id: 'n2',
          title: 'Campaign Ideas Brainstorm',
          content:
              'Collection of creative campaign concepts for the upcoming product launch...',
          authorName: 'Ahmed Ali',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['ideas', 'brainstorm'],
        ),
        SpaceNoteModel(
          id: 'n3',
          title: 'Budget Planning 2025',
          content:
              'Annual budget allocations and projections for marketing department...',
          authorName: 'Sarah Khan',
          createdAt: DateTime(2025, 2, 18),
          isFavorite: true,
          tags: ['budget', 'planning'],
        ),
        SpaceNoteModel(
          id: 'n4',
          title: 'Brand Guidelines Update',
          content:
              'Updated brand voice, color palette, and typography standards...',
          authorName: 'Ahmed Ali',
          createdAt: DateTime(2025, 2, 15),
          tags: ['brand'],
        ),
      ],
      '3': [
        SpaceNoteModel(
          id: 'n5',
          title: 'Design System v2',
          content:
              'Complete component library with tokens, spacing, and color system...',
          authorName: 'Sara Al-Mansouri',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isFavorite: true,
          tags: ['design-system'],
        ),
        SpaceNoteModel(
          id: 'n6',
          title: 'Icon Set Guidelines',
          content:
              'Standard icon sizes, stroke widths, and naming conventions...',
          authorName: 'Sara Al-Mansouri',
          createdAt: DateTime(2025, 2, 10),
          tags: ['icons', 'guidelines'],
        ),
      ],
    };

    return mockData[spaceId] ?? [];
  }

  Future<List<SpaceMemberModel>> getMembersForSpace(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final Map<String, List<SpaceMemberModel>> members = {
      '1': [
        SpaceMemberModel(
          id: 'm1',
          name: 'You',
          email: 'you@nota.app',
          role: SpaceRole.admin,
          joinedAt: DateTime(2024, 10, 1),
          isCurrentUser: true,
          avatarColor: const Color(0xFFD838B5),
        ),
        SpaceMemberModel(
          id: 'm2',
          name: 'Sarah Khan',
          email: 'sarah@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 5),
          avatarColor: const Color(0xFF238EFA),
        ),
        SpaceMemberModel(
          id: 'm3',
          name: 'Ahmed Ali',
          email: 'ahmed@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 12),
          avatarColor: const Color(0xFF07C168),
        ),
        SpaceMemberModel(
          id: 'm4',
          name: 'Maria Garcia',
          email: 'maria@team.com',
          role: SpaceRole.viewer,
          joinedAt: DateTime(2024, 10, 18),
          avatarColor: const Color(0xFFFF5621),
        ),
      ],
      '2': [
        SpaceMemberModel(
          id: 'm5',
          name: 'Alex Chen',
          email: 'alex@team.com',
          role: SpaceRole.admin,
          joinedAt: DateTime(2024, 9, 10),
          avatarColor: const Color(0xFF238EFA),
        ),
        SpaceMemberModel(
          id: 'm6',
          name: 'You',
          email: 'you@nota.app',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 9, 20),
          isCurrentUser: true,
          avatarColor: const Color(0xFFD838B5),
        ),
        SpaceMemberModel(
          id: 'm7',
          name: 'Lisa Wang',
          email: 'lisa@team.com',
          role: SpaceRole.contributor,
          joinedAt: DateTime(2024, 10, 1),
          avatarColor: const Color(0xFF9B59B6),
        ),
      ],
    };

    return members[spaceId] ?? [];
  }
}
