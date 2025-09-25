import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visdom/core/supabase_ext.dart';

class NotificationsRepository {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> myNotifications(
      {bool unreadOnly = false}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    var q = _sb.app
        .from('notifications')
        .select('id, kind, payload, is_read, created_at')
        .eq('user_id', uid);
    if (unreadOnly) q = q.eq('is_read', true);
    final rows = await q.order('created_at', ascending: false).limit(100);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> markRead(String id, {bool read = true}) async {
    await _sb.app.from('notifications').update({'is_read': read}).eq('id', id);
  }
}
