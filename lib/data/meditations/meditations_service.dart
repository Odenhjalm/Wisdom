import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class MeditationsService {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> publicMeditations({int limit = 50}) async {
    final rows = await _sb.app
        .from('meditations')
        .select(
            'id, teacher_id, title, description, audio_path, duration_seconds')
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> byTeacher(String userId) async {
    final rows = await _sb.app
        .from('meditations')
        .select(
            'id, teacher_id, title, description, audio_path, duration_seconds, is_public')
        .eq('teacher_id', userId)
        .order('created_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  String publicUrl(String path) => _sb.storage.from('media').getPublicUrl(path);
}
