import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.type,
    required this.summary,
    required this.occurredAt,
    this.actorId,
    this.subjectTable,
    this.subjectId,
    this.metadata = const {},
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value.toUtc();
      if (value is String) {
        return DateTime.tryParse(value)?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return Activity(
      id: json['id'] as String,
      type: (json['activity_type'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      occurredAt: parseDate(json['occurred_at']),
      actorId: json['actor_id'] as String?,
      subjectTable: json['subject_table'] as String?,
      subjectId: json['subject_id'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  final String id;
  final String type;
  final String summary;
  final DateTime occurredAt;
  final String? actorId;
  final String? subjectTable;
  final String? subjectId;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        type,
        summary,
        occurredAt,
        actorId,
        subjectTable,
        subjectId,
        metadata,
      ];
}
