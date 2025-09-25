import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visdom/core/supabase_ext.dart';

class ReviewsRepository {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listByService(String serviceId) async {
    final rows = await _sb.app
        .from('reviews')
        .select('id, service_id, reviewer_id, rating, comment, created_at')
        .eq('service_id', serviceId)
        .order('created_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> add(
      {required String serviceId, required int rating, String? comment}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Inte inloggad');
    await _sb.app.from('reviews').insert({
      'service_id': serviceId,
      'reviewer_id': uid,
      'rating': rating.clamp(1, 5),
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    });
  }
}
