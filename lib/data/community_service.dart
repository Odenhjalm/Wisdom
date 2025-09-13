import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class CommunityService {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listTeachers() async {
    final rows = await _sb
        .app
        .from('teacher_directory')
        .select('user_id, headline, specialties, rating, created_at')
        .order('created_at', ascending: false)
        .limit(100);
    final list = (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final ids = list.map((e) => e['user_id'] as String?).whereType<String>().toList();
    if (ids.isNotEmpty) {
      final inList = '(${ids.map((e) => '"$e"').join(',')})';
      final profs = await _sb
          .app
          .from('profiles')
          .select('user_id, display_name, photo_url')
          .filter('user_id', 'in', inList);
      final profMap = <String, Map<String, dynamic>>{
        for (final p in (profs as List? ?? [])) (p['user_id'] as String): Map<String, dynamic>.from(p as Map)
      };
      for (final t in list) {
        final id = t['user_id'] as String?;
        if (id != null && profMap.containsKey(id)) {
          t['profile'] = profMap[id];
        }
      }
    }
    return list;
  }

  Future<Map<String, dynamic>?> getTeacher(String userId) async {
    final dir = await _sb
        .app
        .from('teacher_directory')
        .select('user_id, headline, specialties, rating')
        .eq('user_id', userId)
        .maybeSingle();
    if (dir == null) return null;
    final prof = await _sb
        .app
        .from('profiles')
        .select('user_id, display_name, photo_url')
        .eq('user_id', userId)
        .maybeSingle();
    final map = Map<String, dynamic>.from(dir as Map);
    map['profile'] = prof == null ? null : Map<String, dynamic>.from(prof as Map);
    return map;
  }

  Future<List<Map<String, dynamic>>> listServices(String userId) async {
    final rows = await _sb
        .app
        .from('services')
        .select('id, title, description, price_cents, active')
        .eq('provider_id', userId)
        .order('created_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> listMeditations(String userId) async {
    final rows = await _sb
        .app
        .from('meditations')
        .select('id, title, description, audio_path, duration_seconds, is_public')
        .eq('teacher_id', userId)
        .order('created_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, int>> listVerifiedCertCount(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final inList = '(${userIds.map((e) => '"$e"').join(',')})';
    final rows = await _sb
        .app
        .from('certificates')
        .select('user_id')
        .filter('user_id', 'in', inList)
        .eq('verified', true);
    final map = <String, int>{};
    for (final r in (rows as List? ?? [])) {
      final id = (r as Map)['user_id'] as String?;
      if (id != null) map[id] = (map[id] ?? 0) + 1;
    }
    return map;
  }

  Future<Map<String, List<String>>> listVerifiedCertSpecialties(
      List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final inList = '(${userIds.map((e) => '"$e"').join(',')})';
    final rows = await _sb
        .app
        .from('certificates')
        .select('user_id, specialties')
        .filter('user_id', 'in', inList)
        .eq('verified', true);
    final map = <String, Set<String>>{};
    for (final r in (rows as List? ?? [])) {
      final m = Map<String, dynamic>.from(r as Map);
      final id = m['user_id'] as String?;
      final specs = (m['specialties'] as List?)?.cast<String>() ?? const [];
      if (id == null) continue;
      map.putIfAbsent(id, () => <String>{}).addAll(specs);
    }
    return {for (final e in map.entries) e.key: e.value.toList()};
  }

  Future<Map<String, dynamic>> startServiceOrder({required String serviceId, required int amountCents}) async {
    final res = await _sb.schema('app').rpc('start_service_order', params: {
      'p_service_id': serviceId,
      'p_amount_cents': amountCents,
    });
    if (res is Map<String, dynamic>) return res;
    if (res is List && res.isNotEmpty) return Map<String, dynamic>.from(res.first as Map);
    throw Exception('Kunde inte skapa order');
  }

  Future<List<Map<String, dynamic>>> listMessages(String channel) async {
    final rows = await _sb
        .app
        .from('messages')
        .select('id, sender_id, content, created_at')
        .eq('channel', channel)
        .order('created_at');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> sendMessage({required String channel, required String content}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Inte inloggad');
    await _sb
        .app
        .from('messages')
        .insert({'channel': channel, 'sender_id': uid, 'content': content});
  }
}
