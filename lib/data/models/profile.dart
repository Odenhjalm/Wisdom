class Profile {
  final String id;
  final String role;
  final String? displayName;
  final String? photoUrl;

  Profile({
    required this.id,
    required this.role,
    this.displayName,
    this.photoUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    id: j['id'] as String,
    role: (j['role'] as String?) ?? 'free',
    displayName: j['display_name'] as String?,
    photoUrl: j['photo_url'] as String?,
  );
}
