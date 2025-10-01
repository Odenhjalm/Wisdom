enum CertificateStatus { pending, verified, rejected, unknown }

CertificateStatus certificateStatusFrom(String? value) {
  switch (value) {
    case 'pending':
      return CertificateStatus.pending;
    case 'verified':
      return CertificateStatus.verified;
    case 'rejected':
      return CertificateStatus.rejected;
    default:
      return CertificateStatus.unknown;
  }
}

class Certificate {
  const Certificate({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.statusRaw,
    this.notes,
    this.evidenceUrl,
    this.createdAt,
    this.updatedAt,
  });

  static const String teacherApplicationTitle = 'Läraransökan';

  final String id;
  final String userId;
  final String title;
  final CertificateStatus status;
  final String statusRaw;
  final String? notes;
  final String? evidenceUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => status == CertificateStatus.pending;
  bool get isVerified => status == CertificateStatus.verified;
  bool get isRejected => status == CertificateStatus.rejected;

  Certificate copyWith({
    String? id,
    String? userId,
    String? title,
    CertificateStatus? status,
    String? statusRaw,
    String? notes,
    String? evidenceUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      status: status ?? this.status,
      statusRaw: statusRaw ?? this.statusRaw,
      notes: notes ?? this.notes,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] as String?)?.toLowerCase();
    return Certificate(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Certifikat',
      status: certificateStatusFrom(rawStatus),
      statusRaw: rawStatus ?? 'unknown',
      notes: json['notes'] as String?,
      evidenceUrl: json['evidence_url'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        'status': statusRaw,
        if (notes != null) 'notes': notes,
        if (evidenceUrl != null) 'evidence_url': evidenceUrl,
      };

  static DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
