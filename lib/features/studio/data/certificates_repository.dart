import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/supabase_ext.dart';
import 'package:wisdom/data/models/certificate.dart';

class CertificatesRepository {
  CertificatesRepository({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  final SupabaseClient _sb;

  static const _defaultSelect =
      'id, user_id, title, status, notes, evidence_url, created_at, updated_at';

  Future<List<Certificate>> myCertificates({bool verifiedOnly = false}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return const <Certificate>[];
    final query =
        _sb.app.from('certificates').select(_defaultSelect).eq('user_id', uid);
    if (verifiedOnly) {
      query.eq('status', 'verified');
    }
    final rows = await query.order('updated_at', ascending: false);
    return _mapCertificates(rows);
  }

  Future<List<Certificate>> certificatesOf(
    String userId, {
    bool verifiedOnly = true,
  }) async {
    final query = _sb.app
        .from('certificates')
        .select(_defaultSelect)
        .eq('user_id', userId);
    if (verifiedOnly) {
      query.eq('status', 'verified');
    }
    final rows = await query.order('updated_at', ascending: false);
    return _mapCertificates(rows);
  }

  Future<Certificate?> teacherApplicationOf(String userId) async {
    final res = await _sb.app
        .from('certificates')
        .select(_defaultSelect)
        .eq('user_id', userId)
        .eq('title', Certificate.teacherApplicationTitle)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (res == null) return null;
    return Certificate.fromJson(Map<String, dynamic>.from(res));
  }

  Future<Certificate?> myTeacherApplication() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    return teacherApplicationOf(uid);
  }

  Future<Certificate?> addCertificate({
    required String title,
    String status = 'pending',
    String? notes,
    String? evidenceUrl,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Inte inloggad');
    }
    final payload = {
      'user_id': uid,
      'title': title,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (evidenceUrl != null && evidenceUrl.isNotEmpty)
        'evidence_url': evidenceUrl,
    };
    final res = await _sb.app
        .from('certificates')
        .insert(payload)
        .select(_defaultSelect)
        .maybeSingle();
    if (res == null) return null;
    return Certificate.fromJson(Map<String, dynamic>.from(res));
  }

  List<Certificate> _mapCertificates(Object? rows) {
    final list = (rows as List? ?? const []);
    return list
        .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }
}
