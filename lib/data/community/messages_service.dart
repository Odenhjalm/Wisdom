import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class MessagesService {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listDmChannels() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _sb.app
        .from('messages')
        .select('channel, created_at')
        .like('channel', 'dm:%')
        .order('created_at', ascending: false);
    final set = <String, DateTime>{};
    for (final r in (rows as List? ?? [])) {
      final m = Map<String, dynamic>.from(r as Map);
      final ch = m['channel'] as String?;
      final at =
          DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now();
      if (ch == null) continue;
      set[ch] = (set[ch] == null || at.isAfter(set[ch]!)) ? at : set[ch]!;
    }
    final list = set.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in list)
        {'channel': e.key, 'last_at': e.value.toIso8601String()}
    ];
  }

  Future<List<Map<String, dynamic>>> listServiceChannels() async {
    final rows = await _sb.app
        .from('messages')
        .select('channel, created_at')
        .like('channel', 'service:%')
        .order('created_at', ascending: false);
    final set = <String, DateTime>{};
    for (final r in (rows as List? ?? [])) {
      final m = Map<String, dynamic>.from(r as Map);
      final ch = m['channel'] as String?;
      final at =
          DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now();
      if (ch == null) continue;
      set[ch] = (set[ch] == null || at.isAfter(set[ch]!)) ? at : set[ch]!;
    }
    final list = set.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in list)
        {'channel': e.key, 'last_at': e.value.toIso8601String()}
    ];
  }

  Future<List<Map<String, dynamic>>> listMessages(String channel) async {
    final rows = await _sb.app
        .from('messages')
        .select('id, sender_id, content, created_at')
        .eq('channel', channel)
        .order('created_at');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> send(String channel, String content) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Inte inloggad');
    await _sb.app
        .from('messages')
        .insert({'channel': channel, 'sender_id': uid, 'content': content});
  }
}
