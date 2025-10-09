import 'package:equatable/equatable.dart';

class Service extends Equatable {
  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.currency,
    required this.status,
    this.durationMinutes,
    this.requiresCertification = false,
    this.certifiedArea,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String? ?? '',
      priceCents: (json['price_cents'] as num? ?? 0).toInt(),
      currency: (json['currency'] ?? 'sek') as String,
      status: (json['status'] ?? 'draft') as String,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      requiresCertification: json['requires_certification'] == true,
      certifiedArea: json['certified_area'] as String?,
    );
  }

  final String id;
  final String title;
  final String description;
  final int priceCents;
  final String currency;
  final String status;
  final int? durationMinutes;
  final bool requiresCertification;
  final String? certifiedArea;

  double get price => priceCents / 100;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priceCents,
        currency,
        status,
        durationMinutes,
        requiresCertification,
        certifiedArea,
      ];
}
