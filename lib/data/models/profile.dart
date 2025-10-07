import 'package:equatable/equatable.dart';

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

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.userRole,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
    this.bio,
    this.photoUrl,
    this.avatarMediaId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final legacy = (json['role'] as String?) ?? 'user';
    final userRoleValue = json['role_v2'] as String?;
    final admin = json['is_admin'] == true || legacy == 'admin';

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value).toUtc();
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return Profile(
      id: (json['user_id'] ?? json['id']) as String,
      email: (json['email'] ?? '') as String,
      userRole: admin
          ? UserRole.teacher
          : parseUserRole(userRoleValue ?? legacy),
      isAdmin: admin,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      avatarMediaId: json['avatar_media_id'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  final String id;
  final String email;
  final UserRole userRole;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final String? bio;
  final String? photoUrl;
  final String? avatarMediaId;

  Profile copyWith({
    String? id,
    String? email,
    UserRole? userRole,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? displayName,
    String? bio,
    String? photoUrl,
    String? avatarMediaId,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
    );
  }

  bool get isTeacher => userRole == UserRole.teacher;
  bool get isProfessional =>
      userRole == UserRole.professional || userRole == UserRole.teacher;

  @override
  List<Object?> get props => [
    id,
    email,
    userRole,
    isAdmin,
    displayName,
    bio,
    photoUrl,
    avatarMediaId,
    createdAt,
    updatedAt,
  ];
}
