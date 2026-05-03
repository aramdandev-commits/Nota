import 'package:flutter/material.dart';
import '../model/space_model.dart';

class SpacesRepository {
  // Simulates a network delay and returns mock data.
  // This can easily be swapped out for actual HTTP requests later.
  Future<List<SpaceModel>> getSpaces() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    return [
      SpaceModel(
        id: '1',
        title: 'Marketing Team',
        description: 'Marketing campaigns and strategy',
        role: SpaceRole.admin,
        memberCount: 4,
        noteCount: 4,
        iconColor: const Color(0xFFD838B5), // Pinkish purple
        iconData: Icons.people_outline,
        privacy: SpacePrivacy.private,
      ),
      SpaceModel(
        id: '2',
        title: 'Product Development',
        description: 'Product roadmap and features',
        role: SpaceRole.contributor,
        memberCount: 3,
        noteCount: 3,
        iconColor: const Color(0xFF238EFA), // Blue
        iconData: Icons.folder_open,
        privacy: SpacePrivacy.private,
      ),
      SpaceModel(
        id: '3',
        title: 'Design Resources',
        description: 'Shared design assets and guidelines',
        role: SpaceRole.viewer,
        memberCount: 2,
        noteCount: 2,
        iconColor: const Color(0xFF07C168), // Green
        iconData: Icons.folder_open,
        privacy: SpacePrivacy.public,
      ),
      SpaceModel(
        id: '4',
        title: 'Engineering',
        description: 'Technical documentation and architecture',
        role: SpaceRole.admin,
        memberCount: 3,
        noteCount: 2,
        iconColor: const Color(0xFFFF5621), // Orange
        iconData: Icons.people_outline,
        privacy: SpacePrivacy.private,
      ),
    ];
  }
}
