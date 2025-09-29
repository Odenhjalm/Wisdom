enum UserRole { user, professional, teacher }

UserRole parseUserRole(String? value) {
  switch (value) {
    case 'teacher':
      return UserRole.teacher;
    case 'professional':
      return UserRole.professional;
    default:
      return UserRole.user;
  }
}

class Profile {
  final String id;
  final String roleLegacy;
  final UserRole userRole;
  final bool isAdmin;
  final String? displayName;
  final String? photoUrl;

  const Profile({
    required this.id,
    required this.roleLegacy,
    required this.userRole,
    required this.isAdmin,
    this.displayName,
    this.photoUrl,
  });

  Profile copyWith({
    String? id,
    String? roleLegacy,
    UserRole? userRole,
    bool? isAdmin,
    String? displayName,
    String? photoUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      roleLegacy: roleLegacy ?? this.roleLegacy,
      userRole: userRole ?? this.userRole,
      isAdmin: isAdmin ?? this.isAdmin,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final legacy = (json['role'] as String?) ?? 'user';
    final userRoleValue = json['role_v2'] as String?;
    final admin = json['is_admin'] == true || legacy == 'admin';

    return Profile(
      id: (json['user_id'] ?? json['id']) as String,
      roleLegacy: legacy,
      userRole: admin ? UserRole.teacher : parseUserRole(userRoleValue),
      isAdmin: admin,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  bool get isTeacher => userRole == UserRole.teacher;
  bool get isProfessional =>
      userRole == UserRole.professional || userRole == UserRole.teacher;
}
