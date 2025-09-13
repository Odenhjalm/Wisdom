import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';
import 'package:flutter/foundation.dart';

class CourseService {
  final _sb = Supabase.instance.client;
  Future<Map<String, dynamic>?> getAppConfig() async {
    final rows = await _sb.app.from('app_config').select('*').eq('id', 1).maybeSingle();
    if (rows == null) return null;
    return Map<String, dynamic>.from(rows as Map);
  }

  Future<Map<String, dynamic>?> firstFreeIntroCourse() async {
    final rows = await _sb
        .app.from('courses')
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

  Future<Map<String, dynamic>?> getCourseBySlug(String slug) async {
    final rows = await _sb
        .app.from('courses')
        .select('id, slug, title, description, is_free_intro, is_published')
        .eq('slug', slug)
        .limit(1);
    if (rows is List && rows.isNotEmpty) {
      return Map<String, dynamic>.from(rows.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> listModules(String courseId) async {
    final rows = await _sb
        .app.from('modules')
        .select('id, title, position')
        .eq('course_id', courseId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getModule(String moduleId) async {
    final row = await _sb
        .app.from('modules')
        .select('id, course_id, title, position')
        .eq('id', moduleId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<List<Map<String, dynamic>>> listLessonsForModule(String moduleId,
      {bool onlyIntro = false}) async {
    final base = _sb
        .app.from('lessons')
        .select('id, title, position, is_intro, content_markdown')
        .eq('module_id', moduleId);
    final rows = onlyIntro
        ? await base.eq('is_intro', true).order('position')
        : await base.order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getLesson(String lessonId) async {
    final row = await _sb
        .app.from('lessons')
        .select('id, title, content_markdown, is_intro, module_id')
        .eq('id', lessonId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<List<Map<String, dynamic>>> listLessonMedia(String lessonId) async {
    final rows = await _sb
        .app.from('lesson_media')
        .select('id, kind, storage_path, position')
        .eq('lesson_id', lessonId)
        .order('position');
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> enrollFreeIntro(String courseId) async {
    await _sb.schema('app').rpc('enroll_free_intro', params: {
      'p_course_id': courseId,
    });
  }

  Future<Map<String, dynamic>> startOrder({required String courseId, required int amountCents}) async {
    final res = await _sb.schema('app').rpc('start_order', params: {
      'p_course_id': courseId,
      'p_amount_cents': amountCents,
    });
    if (res is Map<String, dynamic>) return res;
    // Some PostgREST clients return a List with single row
    if (res is List && res.isNotEmpty) {
      return Map<String, dynamic>.from(res.first as Map);
    }
    throw Exception('Kunde inte skapa order');
  }

  Future<Map<String, dynamic>?> latestOrderForCourse(String courseId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    final rows = await _sb
        .app.from('orders')
        .select('id, status, amount_cents, created_at')
        .eq('user_id', uid)
        .eq('course_id', courseId)
        .order('created_at', ascending: false)
        .limit(1);
    if (rows is List && rows.isNotEmpty) {
      return Map<String, dynamic>.from(rows.first as Map);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> myEnrolledCourses() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final enr = await _sb
        .app
        .from('enrollments')
        .select('course_id')
        .eq('user_id', uid);
    final ids = (enr as List? ?? [])
        .map((e) => (e as Map)['course_id'] as String?)
        .whereType<String>()
        .toList();
    if (ids.isEmpty) return [];
    // Some postgrest versions lack `in_`; use generic filter with SQL 'in' operator
    final inList = '(${ids.map((e) => '"$e"').join(',')})';
    final rows = await _sb
        .app
        .from('courses')
        .select('id, slug, title, description, cover_url, is_published')
        .filter('id', 'in', inList);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<String?> createCheckoutSession({
    required String orderId,
    required int amountCents,
    String currency = 'sek',
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
  }) async {
    try {
      final res = await _sb.functions.invoke('stripe_checkout', body: {
        'order_id': orderId,
        'amount_cents': amountCents,
        'currency': currency,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
        if (customerEmail != null) 'customer_email': customerEmail,
      });
      final data = res.data;
      if (data is Map && data['url'] is String) return data['url'] as String;
      return null;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('createCheckoutSession error: $e');
      }
      rethrow;
    }
  }

  Future<int> freeConsumedCount() async {
    try {
      final res = await _sb.schema('app').rpc('free_consumed_count');
      if (res is int) return res;
      if (res is num) return res.toInt();
    } catch (_) {}
    return 0;
  }

  Future<bool> isEnrolled(String courseId) async {
    try {
      final res = await _sb.schema('app').rpc('can_access_course', params: {'p_course': courseId});
      if (res is bool) return res;
    } catch (_) {}
    return false;
  }
}
