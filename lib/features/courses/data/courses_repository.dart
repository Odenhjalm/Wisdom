import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/core/supabase_ext.dart';

class CoursesRepository {
  CoursesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<CourseDetailData> fetchCourseDetailBySlug(String slug) async {
    try {
      final row = await _client.app
          .from('courses')
          .select(
              'id, slug, title, description, cover_url, video_url, is_free_intro, is_published, price_cents')
          .eq('slug', slug)
          .limit(1)
          .maybeSingle();
      if (row == null) {
        throw NotFoundFailure(message: 'Kursen kunde inte hittas.');
      }
      final course = CourseSummary.fromJson(row);
      final modules = await listModules(course.id);
      final lessons = <String, List<LessonSummary>>{};
      for (final module in modules) {
        lessons[module.id] = await listLessonsForModule(module.id);
      }

      final freeCountFuture = freeConsumedCount();
      final isEnrolledFuture = isEnrolled(course.id);
      final latestOrderFuture = latestOrderForCourse(course.id);
      final freeLimitFuture = _fetchFreeLimit();

      final freeCount = await freeCountFuture;
      final enrolled = await isEnrolledFuture;
      final latestOrder = await latestOrderFuture;
      final freeLimit = await freeLimitFuture;

      return CourseDetailData(
        course: course,
        modules: modules,
        lessonsByModule: lessons,
        freeConsumed: freeCount,
        freeLimit: freeLimit,
        isEnrolled: enrolled,
        latestOrder: latestOrder,
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<int> _fetchFreeLimit() async {
    try {
      final row = await _client.app
          .from('app_config')
          .select('free_course_limit')
          .eq('id', 1)
          .maybeSingle();
      if (row == null) return 5;
      final raw = (row as Map)['free_course_limit'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw) ?? 5;
      return 5;
    } catch (_) {
      return 5;
    }
  }

  Future<CourseSummary?> firstFreeIntroCourse() async {
    try {
      final res = await _client.app
          .from('courses')
          .select(
              'id, slug, title, description, cover_url, video_url, is_free_intro, is_published, price_cents')
          .eq('is_published', true)
          .eq('is_free_intro', true)
          .order('created_at')
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return CourseSummary.fromJson(res);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseSummary?> getCourseById(String courseId) async {
    try {
      final row = await _client.app
          .from('courses')
          .select(
              'id, slug, title, description, cover_url, video_url, is_free_intro, is_published, price_cents')
          .eq('id', courseId)
          .maybeSingle();
      if (row == null) return null;
      return CourseSummary.fromJson(row);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<CourseSummary>> fetchPublishedCourses({bool onlyFreeIntro = false}) async {
    try {
      final query = _client.app.from('courses').select(
          'id, slug, title, description, cover_url, video_url, is_free_intro, is_published, price_cents');
      final res = await query.eq('is_published', true);
      final list = (res as List? ?? [])
          .map((row) => CourseSummary.fromJson(row as Map<String, dynamic>))
          .toList();
      if (!onlyFreeIntro) return list;
      return list.where((c) => c.isFreeIntro).toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<CourseModule>> listModules(String courseId) async {
    try {
      final rows = await _client.app
          .from('modules')
          .select('id, title, position')
          .eq('course_id', courseId)
          .order('position');
      final list = (rows as List? ?? [])
          .map((row) => CourseModule.fromJson(row as Map<String, dynamic>))
          .toList();
      return list;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseModule?> getModule(String moduleId) async {
    try {
      final row = await _client.app
          .from('modules')
          .select('id, course_id, title, position')
          .eq('id', moduleId)
          .maybeSingle();
      if (row == null) return null;
      return CourseModule.fromJson(row);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<LessonSummary>> listLessonsForModule(
    String moduleId, {
    bool onlyIntro = false,
  }) async {
    try {
      var query = _client.app
          .from('lessons')
          .select('id, title, position, is_intro, content_markdown')
          .eq('module_id', moduleId);
      if (onlyIntro) {
        query = query.eq('is_intro', true);
      }
      final rows = await query.order('position');
      return (rows as List? ?? [])
          .map((row) => LessonSummary.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<LessonDetailData> fetchLessonDetail(String lessonId) async {
    try {
      final lessonRow = await _client.app
          .from('lessons')
          .select('id, title, content_markdown, is_intro, module_id, position')
          .eq('id', lessonId)
          .maybeSingle();
      if (lessonRow == null) {
        throw NotFoundFailure(message: 'Lektionen kunde inte hittas.');
      }

      final lesson = LessonDetail.fromJson(
        Map<String, dynamic>.from(lessonRow as Map),
      );
      final moduleId = lesson.moduleId;
      CourseModule? module;
      List<CourseModule> modules = const [];
      if (moduleId != null) {
        module = await getModule(moduleId);
        if (module != null) {
          modules = await listModules(module.courseId!);
        }
      }
      List<LessonSummary> moduleLessons = const [];
      if (moduleId != null) {
        moduleLessons = await listLessonsForModule(moduleId);
      }
      final media = await listLessonMedia(lesson.id);

      final courseLessons = <LessonSummary>[];
      for (final m in modules) {
        final moduleLessonList = await listLessonsForModule(m.id);
        courseLessons.addAll(moduleLessonList);
      }

      return LessonDetailData(
        lesson: lesson,
        module: module,
        moduleLessons: moduleLessons,
        courseLessons: courseLessons,
        media: media,
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<LessonMediaItem>> listLessonMedia(String lessonId) async {
    try {
      final rows = await _client.app
          .from('lesson_media')
          .select('id, kind, storage_path, position')
          .eq('lesson_id', lessonId)
          .order('position');
      return (rows as List? ?? [])
          .map((row) => LessonMediaItem.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<void> enrollFreeIntro(String courseId) async {
    try {
      await _client.schema('app').rpc('enroll_free_intro', params: {
        'p_course_id': courseId,
      });
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<int> freeConsumedCount() async {
    try {
      final res = await _client.schema('app').rpc('free_consumed_count');
      if (res is int) return res;
      if (res is num) return res.toInt();
      if (res is String) return int.tryParse(res) ?? 0;
      return 0;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<bool> isEnrolled(String courseId) async {
    try {
      final res = await _client
          .schema('app')
          .rpc('can_access_course', params: {'p_course': courseId});
      if (res is bool) return res;
      return false;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseOrderSummary?> latestOrderForCourse(String courseId) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return null;
      final rows = await _client.app
          .from('orders')
          .select('id, status, amount_cents, created_at')
          .eq('user_id', uid)
          .eq('course_id', courseId)
          .order('created_at', ascending: false)
          .limit(1);
      if (rows.isNotEmpty) {
        return CourseOrderSummary.fromJson(rows.first);
      }
      return null;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<CourseSummary>> myEnrolledCourses() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return const [];
      final enr = await _client.app
          .from('enrollments')
          .select('course_id')
          .eq('user_id', uid);
      final ids = (enr as List? ?? [])
          .map((row) => (row as Map)['course_id'] as String?)
          .whereType<String>()
          .toList();
      if (ids.isEmpty) return const [];
      final inList = '(${ids.map((e) => '"$e"').join(',')})';
      final rows = await _client.app
          .from('courses')
          .select(
              'id, slug, title, description, cover_url, video_url, is_free_intro, is_published, price_cents')
          .filter('id', 'in', inList);
      return (rows as List? ?? [])
          .map((row) => CourseSummary.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseQuizInfo> fetchQuizInfo(String courseId) async {
    try {
      final client = _client;
      final quizRow = await client
          .from('course_quizzes')
          .select('id')
          .eq('course_id', courseId)
          .limit(1)
          .maybeSingle();
      final quizId = (quizRow as Map?)?['id'] as String?;
      bool certified = false;
      final uid = client.auth.currentUser?.id;
      if (uid != null) {
        final certRes = await client
            .from('certificates')
            .select('id')
            .eq('user_id', uid)
            .eq('course_id', courseId)
            .limit(1);
        certified = (certRes as List?)?.isNotEmpty ?? false;
      }
      return CourseQuizInfo(quizId: quizId, certified: certified);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String quizId) async {
    try {
      final rows = await _client
          .from('quiz_questions')
          .select('id, position, kind, prompt, options')
          .eq('quiz_id', quizId)
          .order('position');
      return (rows as List? ?? [])
          .map((row) => QuizQuestion.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final res = await _client.schema('app').rpc('grade_quiz_and_issue_certificate', params: {
        'p_quiz': quizId,
        'p_answers': answers,
      });
      if (res is Map<String, dynamic>) return res;
      if (res is Map) return Map<String, dynamic>.from(res);
      if (res is List && res.isNotEmpty) {
        return Map<String, dynamic>.from(res.first as Map);
      }
      return const {};
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }
}

class CourseSummary {
  const CourseSummary({
    required this.id,
    this.slug,
    required this.title,
    this.description,
    this.coverUrl,
    this.videoUrl,
    this.isFreeIntro = false,
    this.isPublished = false,
    this.priceCents,
  });

  final String id;
  final String? slug;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? videoUrl;
  final bool isFreeIntro;
  final bool isPublished;
  final int? priceCents;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as String,
      slug: json['slug'] as String?,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      videoUrl: json['video_url'] as String?,
      isFreeIntro: json['is_free_intro'] == true,
      isPublished: json['is_published'] == true,
      priceCents: _asInt(json['price_cents']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.position,
    this.courseId,
  });

  final String id;
  final String title;
  final int position;
  final String? courseId;

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      position: CourseSummary._asInt(json['position']) ?? 0,
      courseId: json['course_id'] as String?,
    );
  }
}

class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    required this.position,
    this.isIntro = false,
    this.contentMarkdown,
  });

  final String id;
  final String title;
  final int position;
  final bool isIntro;
  final String? contentMarkdown;

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    return LessonSummary(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      position: CourseSummary._asInt(json['position']) ?? 0,
      isIntro: json['is_intro'] == true,
      contentMarkdown: json['content_markdown'] as String?,
    );
  }
}

class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.title,
    this.contentMarkdown,
    this.isIntro = false,
    this.moduleId,
    this.position = 0,
  });

  final String id;
  final String title;
  final String? contentMarkdown;
  final bool isIntro;
  final String? moduleId;
  final int position;

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      contentMarkdown: json['content_markdown'] as String?,
      isIntro: json['is_intro'] == true,
      moduleId: json['module_id'] as String?,
      position: CourseSummary._asInt(json['position']) ?? 0,
    );
  }
}

class LessonMediaItem {
  const LessonMediaItem({
    required this.id,
    required this.kind,
    required this.storagePath,
    required this.position,
  });

  final String id;
  final String kind;
  final String storagePath;
  final int position;

  factory LessonMediaItem.fromJson(Map<String, dynamic> json) {
    return LessonMediaItem(
      id: json['id'] as String,
      kind: (json['kind'] ?? '') as String,
      storagePath: (json['storage_path'] ?? '') as String,
      position: CourseSummary._asInt(json['position']) ?? 0,
    );
  }
}

class CourseOrderSummary {
  const CourseOrderSummary({
    required this.id,
    required this.status,
    required this.amountCents,
    required this.createdAt,
  });

  final String id;
  final String status;
  final int amountCents;
  final DateTime createdAt;

  factory CourseOrderSummary.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    return CourseOrderSummary(
      id: json['id'] as String,
      status: (json['status'] ?? '') as String,
      amountCents: CourseSummary._asInt(json['amount_cents']) ?? 0,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CourseDetailData {
  const CourseDetailData({
    required this.course,
    required this.modules,
    required this.lessonsByModule,
    required this.freeConsumed,
    required this.freeLimit,
    required this.isEnrolled,
    required this.latestOrder,
  });

  final CourseSummary course;
  final List<CourseModule> modules;
  final Map<String, List<LessonSummary>> lessonsByModule;
  final int freeConsumed;
  final int freeLimit;
  final bool isEnrolled;
  final CourseOrderSummary? latestOrder;

  List<LessonSummary> get allLessons => [
        for (final module in modules) ...?lessonsByModule[module.id],
      ];
}

class LessonDetailData {
  const LessonDetailData({
    required this.lesson,
    required this.module,
    required this.moduleLessons,
    required this.courseLessons,
    required this.media,
  });

  final LessonDetail lesson;
  final CourseModule? module;
  final List<LessonSummary> moduleLessons;
  final List<LessonSummary> courseLessons;
  final List<LessonMediaItem> media;

  LessonSummary? get previousLesson {
    final index = courseLessons.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return null;
    return courseLessons[index - 1];
  }

  LessonSummary? get nextLesson {
    final index = courseLessons.indexWhere((l) => l.id == lesson.id);
    if (index < 0) return null;
    if (index + 1 >= courseLessons.length) return null;
    return courseLessons[index + 1];
  }
}

class CourseQuizInfo {
  const CourseQuizInfo({
    required this.quizId,
    required this.certified,
  });

  final String? quizId;
  final bool certified;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.position,
    required this.kind,
    required this.prompt,
    required this.options,
  });

  final String id;
  final int position;
  final String kind;
  final String prompt;
  final List<String> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      position: CourseSummary._asInt(json['position']) ?? 0,
      kind: (json['kind'] ?? 'single') as String,
      prompt: (json['prompt'] ?? '') as String,
      options: (json['options'] as List?)
              ?.map((option) => option.toString())
              .toList() ??
          const [],
    );
  }
}
