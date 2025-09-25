import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visdom/core/supabase_ext.dart';
import 'dart:typed_data';

class StudioRepository {
  final _sb = Supabase.instance.client;

  String? get _uid => _sb.auth.currentUser?.id;

  // ----- Courses (owned by teacher via created_by) -----
  Future<List<Map<String, dynamic>>> myCourses() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _sb.app
        .from('courses')
        .select(
            'id, slug, title, description, is_free_intro, price_cents, is_published, updated_at')
        .eq('created_by', uid)
        .order('updated_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String slug,
    String? description,
    int priceCents = 0,
    bool isFreeIntro = false,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    final row = await _sb.app
        .from('courses')
        .insert({
          'title': title,
          'slug': slug,
          'description': description,
          'price_cents': priceCents,
          'is_free_intro': isFreeIntro,
          'is_published': false,
          'created_by': uid,
        })
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Insert failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> updateCourse(
      String id, Map<String, dynamic> patch) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    final row = await _sb.app
        .from('courses')
        .update(patch)
        .eq('id', id)
        .eq('created_by', uid)
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Update failed or not allowed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteCourse(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _sb.app.from('courses').delete().eq('id', id).eq('created_by', uid);
  }

  // ----- Modules -----
  Future<List<Map<String, dynamic>>> listModules(String courseId) async {
    final rows = await _sb.app
        .from('modules')
        .select('id, title, position')
        .eq('course_id', courseId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> createModule({
    required String courseId,
    required String title,
    int position = 0,
  }) async {
    final row = await _sb.app
        .from('modules')
        .insert({'course_id': courseId, 'title': title, 'position': position})
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Create module failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> updateModule(
      String id, Map<String, dynamic> patch) async {
    final row = await _sb.app
        .from('modules')
        .update(patch)
        .eq('id', id)
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Update module failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteModule(String id) async {
    await _sb.app.from('modules').delete().eq('id', id);
  }

  // ----- Lessons -----
  Future<List<Map<String, dynamic>>> listLessons(String moduleId) async {
    final rows = await _sb.app
        .from('lessons')
        .select('id, title, position, is_intro')
        .eq('module_id', moduleId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> upsertLesson({
    String? id,
    required String moduleId,
    required String title,
    String? contentMarkdown,
    int position = 0,
    bool isIntro = false,
  }) async {
    final data = {
      'module_id': moduleId,
      'title': title,
      'content_markdown': contentMarkdown,
      'position': position,
      'is_intro': isIntro,
    };
    final builder = id == null
        ? _sb.app.from('lessons').insert(data)
        : _sb.app.from('lessons').update(data).eq('id', id);
    final row = await builder.select().maybeSingle();
    if (row == null) throw Exception('Upsert lesson failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteLesson(String id) async {
    await _sb.app.from('lessons').delete().eq('id', id);
  }

  // ----- Media -----
  Future<List<Map<String, dynamic>>> listLessonMedia(String lessonId) async {
    final rows = await _sb.app
        .from('lesson_media')
        .select('id, kind, storage_path, position, created_at')
        .eq('lesson_id', lessonId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _kindFromContentType(String ct) {
    if (ct.startsWith('image/')) return 'image';
    if (ct.startsWith('video/')) return 'video';
    if (ct.startsWith('audio/')) return 'audio';
    if (ct == 'application/pdf') return 'pdf';
    return 'other';
  }

  Future<Map<String, dynamic>> uploadLessonMedia({
    required String lessonId,
    required Uint8List data,
    required String filename,
    required String contentType,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');

    final path =
        '$uid/$lessonId/${DateTime.now().millisecondsSinceEpoch}_$filename';
    await _sb.storage.from('media').uploadBinary(path, data,
        fileOptions: FileOptions(upsert: true, contentType: contentType));

    // Hitta nästa position
    final last = await _sb.app
        .from('lesson_media')
        .select('position')
        .eq('lesson_id', lessonId)
        .order('position', ascending: false)
        .limit(1);
    int nextPos = 1;
    if (last.isNotEmpty) {
      final p = (last.first as Map)['position'] as int?;
      if (p != null) nextPos = p + 1;
    }

    final row = await _sb.app
        .from('lesson_media')
        .insert({
          'lesson_id': lessonId,
          'kind': _kindFromContentType(contentType),
          'storage_path': path,
          'position': nextPos,
        })
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Insert media failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteLessonMedia(String id) async {
    final row = await _sb.app
        .from('lesson_media')
        .select('storage_path')
        .eq('id', id)
        .maybeSingle();
    final map = (row as Map?)?.cast<String, dynamic>();
    final path = map?['storage_path'] as String?;
    if (path != null && path.isNotEmpty) {
      await _sb.storage.from('media').remove([path]);
    }
    await _sb.app.from('lesson_media').delete().eq('id', id);
  }
}
