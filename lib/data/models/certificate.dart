class Certificate {
  final String id;
  final String userId;
  final String title;
  final String? issuer;
  final DateTime? issuedAt;
  final bool verified;
  final List<String> specialties;
  final String? credentialId;
  final String? credentialUrl;
  final String? badgeUrl;

  Certificate({
    required this.id,
    required this.userId,
    required this.title,
    this.issuer,
    this.issuedAt,
    this.verified = false,
    this.specialties = const [],
    this.credentialId,
    this.credentialUrl,
    this.badgeUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> j) => Certificate(
        id: (j['id'] as String?) ?? '',
        userId: (j['user_id'] as String?) ?? '',
        title: (j['title'] as String?) ?? 'Certifikat',
        issuer: j['issuer'] as String?,
        issuedAt: j['issued_at'] == null
            ? null
            : DateTime.tryParse(j['issued_at'] as String),
        verified: (j['verified'] as bool?) ?? false,
        specialties:
            ((j['specialties'] as List?)?.cast<String>()) ?? const <String>[],
        credentialId: j['credential_id'] as String?,
        credentialUrl: j['credential_url'] as String?,
        badgeUrl: j['badge_url'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        if (issuer != null) 'issuer': issuer,
        if (issuedAt != null) 'issued_at': issuedAt!.toIso8601String(),
        if (specialties.isNotEmpty) 'specialties': specialties,
        if (credentialId != null) 'credential_id': credentialId,
        if (credentialUrl != null) 'credential_url': credentialUrl,
        if (badgeUrl != null) 'badge_url': badgeUrl,
      };
}
