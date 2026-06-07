class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested { "user": {...}, "token": "..." } shapes
    final user = json['user'] as Map<String, dynamic>? ?? json;
    final token =
        json['token'] as String? ?? json['access_token'] as String? ?? '';

    return UserModel(
      id: user['id']?.toString() ?? '',
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'token': token,
      };
}
