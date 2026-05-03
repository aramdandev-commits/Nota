/// Payload sent to Laravel's PATCH /api/spaces/{id} endpoint.
class SpaceSettingsModel {
  final String name;
  final String description;
  final bool isPublic;
  final bool allowMembersToEdit;
  final List<String> invitedEmails;

  const SpaceSettingsModel({
    required this.name,
    required this.description,
    required this.isPublic,
    required this.allowMembersToEdit,
    required this.invitedEmails,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'is_public': isPublic,
      'allow_members_to_edit': allowMembersToEdit,
      'invited_emails': invitedEmails,
    };
  }
}
