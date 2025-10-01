import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'lesson_media_path.dart';

class StudioRepository {
  final SupabaseClient _sb;
  final LessonMediaPathBuilder _pathBuilder;

  StudioRepository({
    SupabaseClient? client,
    LessonMediaPathBuilder? pathBuilder,
  })  : _sb = client ?? Supabase.instance.client,
        _pathBuilder = pathBuilder ?? LessonMediaPathBuilder();

  SupabaseClient get client => _sb;

  SupabaseQuerySchema get _app => _sb.schema('app');

  String? get _uid => _sb.auth.currentUser?.id;

  // ----- Courses (owned by teacher via created_by) -----
  Future<List<Map<String, dynamic>>> myCourses() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _app
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
    final row = await _app
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
    final row = await _app
        .from('courses')
        .update(patch)
        .eq('id', id)
        .eq('created_by', uid)
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Update failed or not allowed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>?> fetchCourseMeta(String courseId) async {
    final row = await _app
        .from('courses')
        .select(
            'title, slug, description, price_cents, is_free_intro, is_published')
        .eq('id', courseId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteCourse(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _app.from('courses').delete().eq('id', id).eq('created_by', uid);
  }

  // ----- Modules -----
  Future<List<Map<String, dynamic>>> listModules(String courseId) async {
    final rows = await _app
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
    final row = await _app
        .from('modules')
        .insert({'course_id': courseId, 'title': title, 'position': position})
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Create module failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> updateModule(
      String id, Map<String, dynamic> patch) async {
    final row = await _app
        .from('modules')
        .update(patch)
        .eq('id', id)
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Update module failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteModule(String id) async {
    await _app.from('modules').delete().eq('id', id);
  }

  // ----- Lessons -----
  Future<List<Map<String, dynamic>>> listLessons(String moduleId) async {
    final rows = await _app
        .from('lessons')
        .select('id, title, position, is_intro')
        .eq('module_id', moduleId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> updateLessonIntro({
    required String lessonId,
    required bool isIntro,
  }) async {
    await _app.from('lessons').update({'is_intro': isIntro}).eq('id', lessonId);
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
        ? _app.from('lessons').insert(data)
        : _app.from('lessons').update(data).eq('id', id);
    final row = await builder.select().maybeSingle();
    if (row == null) throw Exception('Upsert lesson failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteLesson(String id) async {
    await _app.from('lessons').delete().eq('id', id);
  }

  // ----- Media -----
  Future<List<Map<String, dynamic>>> listLessonMedia(String lessonId) async {
    final rows = await _app
        .from('lesson_media')
        .select('id, kind, storage_path, storage_bucket, position, created_at')
        .eq('lesson_id', lessonId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<int> _nextMediaPosition(String lessonId) async {
    final last = await _app
        .from('lesson_media')
        .select('position')
        .eq('lesson_id', lessonId)
        .order('position', ascending: false)
        .limit(1);
    if (last.isNotEmpty) {
      final current = (last.first as Map)['position'] as int?;
      if (current != null) return current + 1;
    }
    return 1;
  }

  Future<Map<String, dynamic>> uploadLessonMedia({
    required String courseId,
    required String lessonId,
    required Uint8List data,
    required String filename,
    required String contentType,
    required bool isIntro,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');

    final bucket = _pathBuilder.bucketFor(isIntro: isIntro);
    final path = _pathBuilder.buildPath(
      courseId: courseId,
      lessonId: lessonId,
      filename: filename,
    );

    await _sb.storage.from(bucket).uploadBinary(
          path,
          data,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    final nextPos = await _nextMediaPosition(lessonId);

    final row = await _app
        .from('lesson_media')
        .insert({
          'lesson_id': lessonId,
          'kind': _pathBuilder.kindFromContentType(contentType),
          'storage_path': path,
          'storage_bucket': bucket,
          'position': nextPos,
        })
        .select()
        .maybeSingle();
    if (row == null) throw Exception('Insert media failed');
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteLessonMedia(String id) async {
    final row = await _app
        .from('lesson_media')
        .select('storage_path, storage_bucket')
        .eq('id', id)
        .maybeSingle();
    final map = (row as Map?)?.cast<String, dynamic>();
    final path = map?['storage_path'] as String?;
    final bucket = map?['storage_bucket'] as String? ?? 'course-media';
    if (path != null && path.isNotEmpty) {
      await _sb.storage.from(bucket).remove([path]);
    }
    await _app.from('lesson_media').delete().eq('id', id);
  }

  Future<Uint8List> downloadMedia({
    required String bucket,
    required String path,
  }) async {
    return _sb.storage.from(bucket).download(path);
  }

  Future<void> reorderLessonMedia(
    String lessonId,
    List<String> orderedMediaIds,
  ) async {
    if (orderedMediaIds.isEmpty) return;
    final payload = <Map<String, dynamic>>[];
    for (var i = 0; i < orderedMediaIds.length; i++) {
      payload.add({
        'id': orderedMediaIds[i],
        'lesson_id': lessonId,
        'position': i + 1,
      });
    }
    await _app.from('lesson_media').upsert(payload, onConflict: 'id');
  }
}
