import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherRepository {
  final SupabaseClient client;
  TeacherRepository({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  SupabaseQuerySchema get _app => client.schema('app');

  Future<List<Map<String, dynamic>>> myCourses() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _app
        .from('courses')
        .select(
            'id,title,description,slug,price_cents,is_free_intro,is_published,created_by,created_at')
        .eq('created_by', uid)
        .order('created_at', ascending: false);
    return (res as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> modules(String courseId) async {
    final rows = await _app
        .from('modules')
        .select(
            'id, course_id, title, position, lessons(id,title,position,is_intro,content_markdown,lesson_media(id,kind,storage_path,storage_bucket,position))')
        .eq('course_id', courseId)
        .order('position');

    return (rows as List)
        .map((raw) => _mapModule(raw as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _mapModule(Map<String, dynamic> raw) {
    final module = Map<String, dynamic>.from(raw);
    final lessons = (module['lessons'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    lessons
        .sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));
    final lesson = lessons.isNotEmpty ? lessons.first : null;
    final lessonMedia = (lesson?['lesson_media'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    lessonMedia
        .sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));

    String type = 'text';
    String? body;
    String? mediaUrl;
    if (lessonMedia.isNotEmpty) {
      final media = lessonMedia.first;
      type = _kindToType(media['kind'] as String? ?? 'other');
      final storagePath = media['storage_path'] as String?;
      mediaUrl = _resolveMediaUrl(storagePath);
      body = storagePath;
    } else {
      body = lesson?['content_markdown'] as String?;
    }

    return {
      'id': module['id'],
      'course_id': module['course_id'],
      'position': module['position'],
      'type': type,
      'title': module['title'] ?? lesson?['title'],
      'body': body,
      'media_url': mediaUrl,
      'lesson_id': lesson?['id'],
    };
  }

  Future<Map<String, dynamic>> upsertModule(Map<String, dynamic> data) async {
    final courseId = data['course_id'] as String;
    final type = (data['type'] as String?) ?? 'text';
    final title = (data['title'] as String?)?.trim();
    final body = data['body'] as String?;
    final mediaUrl = data['media_url'] as String?;
    final position = data['position'] as int? ?? 0;

    final moduleRow = await _app
        .from('modules')
        .insert({
          'course_id': courseId,
          'title': title?.isNotEmpty == true ? title : type.toUpperCase(),
          'position': position,
        })
        .select('id, course_id, title, position')
        .single();

    final moduleId = moduleRow['id'] as String;

    final lessonRow = await _app
        .from('lessons')
        .insert({
          'module_id': moduleId,
          'title': title?.isNotEmpty == true ? title : 'Innehåll',
          'position': 0,
          'is_intro': position == 0,
          'content_markdown': type == 'text' ? body : null,
        })
        .select('id, content_markdown')
        .single();

    if (type != 'text') {
      final storagePath = mediaUrl?.isNotEmpty == true
          ? mediaUrl
          : (body?.isNotEmpty == true ? body : null);
      if (storagePath == null || storagePath.isEmpty) {
        throw StateError('Media saknas för $type-modul');
      }
      await _app.from('lesson_media').insert({
        'lesson_id': lessonRow['id'],
        'kind': _typeToKind(type),
        'storage_path': storagePath,
        'position': 0,
      });
    }

    return _mapModule({
      'id': moduleId,
      'course_id': courseId,
      'title': moduleRow['title'],
      'position': moduleRow['position'],
      'lessons': [
        {
          'id': lessonRow['id'],
          'title': title,
          'position': 0,
          'is_intro': position == 0,
          'content_markdown': lessonRow['content_markdown'],
          'lesson_media': type == 'text'
              ? []
              : [
                  {
                    'id': null,
                    'kind': _typeToKind(type),
                    'storage_path': mediaUrl ?? body,
                    'position': 0,
                  }
                ],
        }
      ],
    });
  }

  Future<void> deleteModule(String id) async {
    await _app.from('modules').delete().eq('id', id);
  }

  Future<String> uploadToCourseMedia({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final storage = client.storage.from('media');
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );
    return storage.getPublicUrl(path);
  }

  // Legacy quiz helpers (using public.* tables). These rely on legacy schema.
  Future<Map<String, dynamic>> ensureQuiz(String courseId) async {
    final list = await client
        .from('course_quizzes')
        .select('id,course_id,title,pass_score,created_by,created_at')
        .eq('course_id', courseId)
        .limit(1);
    final existing = (list as List).cast<Map<String, dynamic>>();
    if (existing.isNotEmpty) return existing.first;
    final inserted = await client
        .from('course_quizzes')
        .insert({
          'course_id': courseId,
          'title': 'Quiz',
          'pass_score': 80,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(inserted);
  }

  Future<List<Map<String, dynamic>>> quizQuestions(String quizId) async {
    final res = await client
        .from('quiz_questions')
        .select('id,quiz_id,position,kind,prompt,options,correct,created_at')
        .eq('quiz_id', quizId)
        .order('position');
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> upsertQuestion(Map<String, dynamic> data) async {
    final res =
        await client.from('quiz_questions').upsert(data).select().single();
    return Map<String, dynamic>.from(res);
  }

  Future<void> deleteQuestion(String id) async {
    await client.from('quiz_questions').delete().eq('id', id);
  }

  String? _resolveMediaUrl(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    if (storagePath.startsWith('http')) return storagePath;
    return client.storage.from('media').getPublicUrl(storagePath);
  }

  String _kindToType(String kind) {
    switch (kind) {
      case 'video':
        return 'video';
      case 'audio':
        return 'audio';
      case 'image':
        return 'image';
      default:
        return 'text';
    }
  }

  String _typeToKind(String type) {
    switch (type) {
      case 'video':
        return 'video';
      case 'audio':
        return 'audio';
      case 'image':
        return 'image';
      default:
        return 'other';
    }
  }
}
