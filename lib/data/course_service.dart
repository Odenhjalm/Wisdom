import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final _sb = Supabase.instance.client;

  Future<Map<String, dynamic>?> firstFreeIntroCourse() async {
    final rows = await _sb
        .from('courses')
        .select('id, slug, title, description, is_free_intro, is_published')
        .eq('is_published', true)
        .eq('is_free_intro', true)
        .order('created_at')
        .limit(1);
    if (rows is List && rows.isNotEmpty) {
      return Map<String, dynamic>.from(rows.first);
    }
    return null;
  }

  Future<void> enrollFreeIntro(String courseId) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from('enrollments').upsert(
      {'user_id': uid, 'course_id': courseId, 'source': 'free_intro'},
      onConflict: 'user_id,course_id',
    );
  }
}
