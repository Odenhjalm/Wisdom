import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/supabase_ext.dart';
import 'package:wisdom/data/models/certificate.dart';

class CertificatesRepository {
  final _sb = Supabase.instance.client;

  Future<List<Certificate>> myCertificates({bool verifiedOnly = false}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    var q = _sb.app.from('certificates').select('*').eq('user_id', uid);
    if (verifiedOnly) q = q.eq('verified', true);
    final rows = await q.order('issued_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Certificate>> certificatesOf(String userId,
      {bool verifiedOnly = true}) async {
    var q = _sb.app.from('certificates').select('*').eq('user_id', userId);
    if (verifiedOnly) q = q.eq('verified', true);
    final rows = await q.order('issued_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Certificate?> addCertificate(Certificate c) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Inte inloggad');
    final payload = c.toInsertJson();
    final res = await _sb.app
        .from('certificates')
        .insert(payload)
        .select()
        .maybeSingle();
    if (res == null) return null;
    return Certificate.fromJson(Map<String, dynamic>.from(res));
  }
}
