import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class PostsService {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> feed({int limit = 50}) async {
    final rows = await _sb.app
        .from('posts')
        .select('id, author_id, content, media_paths, created_at')
        .order('created_at', ascending: false)
        .limit(limit);
    final list = (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    // Attach profile
    final ids =
        list.map((e) => e['author_id'] as String?).whereType<String>().toList();
    if (ids.isNotEmpty) {
      final inList = '(${ids.map((e) => '"$e"').join(',')})';
      final profs = await _sb.app
          .from('profiles')
          .select('user_id, display_name, photo_url')
          .filter('user_id', 'in', inList);
      final map = <String, Map<String, dynamic>>{
        for (final p in (profs as List? ?? []))
          (p['user_id'] as String): Map<String, dynamic>.from(p as Map)
      };
      for (final p in list) {
        final id = p['author_id'] as String?;
        if (id != null && map.containsKey(id)) p['profile'] = map[id];
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> create(
      {required String content, List<String>? mediaPaths}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Inte inloggad');
    final res = await _sb.app
        .from('posts')
        .insert({
          'author_id': uid,
          'content': content,
          if (mediaPaths != null) 'media_paths': mediaPaths
        })
        .select()
        .maybeSingle();
    if (res == null) throw Exception('Misslyckades skapa inlägg');
    return Map<String, dynamic>.from(res as Map);
  }
}
