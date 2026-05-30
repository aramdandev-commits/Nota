/// Payload sent to Laravel's PATCH /api/spaces/{id} endpoint.
class SpaceSettingsModel {
  final String name;
  final String description;
  final bool allowMembersToEdit;
  final List<String> invitedEmails;

  const SpaceSettingsModel({
    required this.name,
    required this.description,
    required this.allowMembersToEdit,
    required this.invitedEmails,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'allow_members_to_edit': allowMembersToEdit,
      'invited_emails': invitedEmails,
    };
  }
}
