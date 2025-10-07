import 'dart:async';

import 'package:wisdom/api/api_client.dart';
import 'package:wisdom/core/errors/app_failure.dart';

import 'course_access_api.dart';

class CoursesRepository {
  CoursesRepository({required ApiClient client, CourseAccessApi? accessApi})
      : _client = client,
        _accessApi = accessApi ?? CourseAccessApi(client);

  final ApiClient _client;
  final CourseAccessApi _accessApi;

  Future<List<CourseSummary>> fetchPublishedCourses({
    bool onlyFreeIntro = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'published_only': true,
      };
      if (onlyFreeIntro) params['free_intro'] = true;
      final res = await _client.get<Map<String, dynamic>>(
        '/courses',
        queryParameters: params,
      );
      final items = (res['items'] as List? ?? [])
          .map((e) =>
              CourseSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return items;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<CourseSummary>> myEnrolledCourses() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/courses/me');
      final items = (res['items'] as List? ?? [])
          .map((e) =>
              CourseSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return items;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseSummary?> getCourseById(String courseId) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/courses/$courseId');
      final course = res['course'];
      if (course is Map<String, dynamic>) {
        return CourseSummary.fromJson(course);
      }
      return null;
    } catch (error, stackTrace) {
      if (error is AppFailure && error.kind == AppFailureKind.notFound) {
        return null;
      }
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseDetailData> fetchCourseDetailBySlug(String slug) async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/by-slug/$slug');
      final detail = _mapCourseDetail(res);
      return _augmentCourseDetail(detail);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseDetailData> fetchCourseDetailById(String courseId) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/courses/$courseId');
      final detail = _mapCourseDetail(res);
      return _augmentCourseDetail(detail);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  CourseDetailData _mapCourseDetail(Map<String, dynamic> payload) {
    final course = CourseSummary.fromJson(
        Map<String, dynamic>.from(payload['course'] as Map));
    final modules = (payload['modules'] as List? ?? [])
        .map((e) => CourseModule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final lessonsMap = <String, List<LessonSummary>>{};
    final lessonsRaw = payload['lessons'];
    if (lessonsRaw is Map) {
      lessonsRaw.forEach((key, value) {
        final list = (value as List? ?? [])
            .map((e) =>
                LessonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        lessonsMap[key.toString()] = list;
      });
    }
    return CourseDetailData(
      course: course,
      modules: modules,
      lessonsByModule: lessonsMap,
    );
  }

  Future<CourseDetailData> _augmentCourseDetail(
    CourseDetailData detail,
  ) async {
    final courseId = detail.course.id;

    try {
      final snapshot = await _fetchCourseAccess(courseId);
      return detail.copyWith(
        hasAccess: snapshot.hasAccess,
        isEnrolled: snapshot.enrolled,
        hasActiveSubscription: snapshot.hasActiveSubscription,
        freeConsumed: snapshot.freeConsumed,
        freeLimit: snapshot.freeLimit,
        latestOrder: snapshot.latestOrder,
      );
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (failure.kind == AppFailureKind.unauthorized) {
        return detail;
      }
      throw failure;
    }
  }

  Future<CourseSummary?> firstFreeIntroCourse() async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/intro-first');
      final course = res['course'];
      if (course is Map) {
        return CourseSummary.fromJson(Map<String, dynamic>.from(course));
      }
      return null;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<CourseModule>> listModules(String courseId) async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/$courseId/modules');
      return (res['items'] as List? ?? [])
          .map(
              (e) => CourseModule.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<LessonSummary>> listLessonsForModule(String moduleId) async {
    try {
      final res = await _client
          .get<Map<String, dynamic>>('/courses/modules/$moduleId/lessons');
      return (res['items'] as List? ?? [])
          .map((e) =>
              LessonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<LessonDetailData> fetchLessonDetail(String lessonId) async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/lessons/$lessonId');
      final lesson = LessonDetail.fromJson(
          Map<String, dynamic>.from(res['lesson'] as Map));
      final moduleRaw = res['module'];
      CourseModule? module;
      if (moduleRaw is Map) {
        module = CourseModule.fromJson(Map<String, dynamic>.from(moduleRaw));
      }
      final moduleLessons = (res['module_lessons'] as List? ?? [])
          .map((e) =>
              LessonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final courseLessons = (res['course_lessons'] as List? ?? [])
          .map((e) =>
              LessonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final media = (res['media'] as List? ?? [])
          .map((e) =>
              LessonMediaItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
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

  Future<void> enrollFreeIntro(String courseId) async {
    try {
      await _client.post('/courses/$courseId/enroll');
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<int> freeConsumedCount() async {
    final quota = await fetchFreeQuota();
    return quota.consumed;
  }

  Future<bool> hasAccess(String courseId) async {
    try {
      final snapshot = await _fetchCourseAccess(courseId);
      return snapshot.hasAccess;
    } catch (error, stackTrace) {
      try {
        return await _accessApi.fallbackHasAccess(courseId);
      } catch (_) {
        final failure = AppFailure.from(error, stackTrace);
        if (failure.kind == AppFailureKind.unauthorized) {
          return false;
        }
        return false;
      }
    }
  }

  Future<bool> isEnrolled(String courseId) async {
    return hasAccess(courseId);
  }

  Future<CourseOrderSummary?> latestOrderForCourse(String courseId) async {
    try {
      final snapshot = await _fetchCourseAccess(courseId);
      return snapshot.latestOrder;
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (failure.kind == AppFailureKind.unauthorized) {
        return null;
      }
      throw failure;
    }
  }

  Future<FreeQuota> fetchFreeQuota() async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/free-consumed');
      return FreeQuota.fromJson(res);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CourseAccessData> _fetchCourseAccess(String courseId) async {
    final res =
        await _client.get<Map<String, dynamic>>('/courses/$courseId/access');
    return CourseAccessData.fromJson(res);
  }

  Future<CourseQuizInfo> fetchQuizInfo(String courseId) async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/courses/$courseId/quiz');
      return CourseQuizInfo.fromJson(res);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String quizId) async {
    try {
      final res = await _client
          .get<Map<String, dynamic>>('/courses/quiz/$quizId/questions');
      return (res['items'] as List? ?? [])
          .map(
              (e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
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
      final res = await _client.post<Map<String, dynamic>>(
        '/courses/quiz/$quizId/submit',
        body: {'answers': answers},
      );
      return res;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }
}

class CourseDetailData {
  CourseDetailData({
    required this.course,
    required this.modules,
    required this.lessonsByModule,
    this.hasAccess = false,
    this.isEnrolled = false,
    this.hasActiveSubscription = false,
    this.freeConsumed = 0,
    this.freeLimit = 0,
    this.latestOrder,
  });

  final CourseSummary course;
  final List<CourseModule> modules;
  final Map<String, List<LessonSummary>> lessonsByModule;
  final bool hasAccess;
  final bool isEnrolled;
  final bool hasActiveSubscription;
  final int freeConsumed;
  final int freeLimit;
  final CourseOrderSummary? latestOrder;

  CourseDetailData copyWith({
    bool? hasAccess,
    bool? isEnrolled,
    bool? hasActiveSubscription,
    int? freeConsumed,
    int? freeLimit,
    CourseOrderSummary? latestOrder,
  }) {
    return CourseDetailData(
      course: course,
      modules: modules,
      lessonsByModule: lessonsByModule,
      hasAccess: hasAccess ?? this.hasAccess,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      freeConsumed: freeConsumed ?? this.freeConsumed,
      freeLimit: freeLimit ?? this.freeLimit,
      latestOrder: latestOrder ?? this.latestOrder,
    );
  }
}

class FreeQuota {
  const FreeQuota({required this.consumed, required this.limit});

  final int consumed;
  final int limit;

  factory FreeQuota.fromJson(Map<String, dynamic> json) => FreeQuota(
        consumed: (json['consumed'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? 0,
      );
}

class CourseAccessData {
  const CourseAccessData({
    required this.hasAccess,
    required this.enrolled,
    required this.hasActiveSubscription,
    required this.freeConsumed,
    required this.freeLimit,
    this.latestOrder,
  });

  final bool hasAccess;
  final bool enrolled;
  final bool hasActiveSubscription;
  final int freeConsumed;
  final int freeLimit;
  final CourseOrderSummary? latestOrder;

  factory CourseAccessData.fromJson(Map<String, dynamic> json) {
    final order = json['latest_order'];
    final orderMap = order is Map ? Map<String, dynamic>.from(order) : null;
    return CourseAccessData(
      hasAccess: json['has_access'] == true,
      enrolled: json['enrolled'] == true,
      hasActiveSubscription: json['has_active_subscription'] == true,
      freeConsumed: CourseSummary._asInt(json['free_consumed']) ?? 0,
      freeLimit: CourseSummary._asInt(json['free_limit']) ?? 0,
      latestOrder:
          orderMap != null ? CourseOrderSummary.fromJson(orderMap) : null,
    );
  }
}

class LessonDetailData {
  const LessonDetailData({
    required this.lesson,
    this.module,
    this.moduleLessons = const [],
    this.courseLessons = const [],
    this.media = const [],
  });

  final LessonDetail lesson;
  final CourseModule? module;
  final List<LessonSummary> moduleLessons;
  final List<LessonSummary> courseLessons;
  final List<LessonMediaItem> media;
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

  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
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

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        id: json['id'] as String,
        title: (json['title'] ?? '') as String,
        position: CourseSummary._asInt(json['position']) ?? 0,
        courseId: json['course_id'] as String?,
      );
}

class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    required this.position,
    this.isIntro = false,
    this.contentMarkdown,
    this.moduleId,
  });

  final String id;
  final String title;
  final int position;
  final bool isIntro;
  final String? contentMarkdown;
  final String? moduleId;

  factory LessonSummary.fromJson(Map<String, dynamic> json) => LessonSummary(
        id: json['id'] as String,
        title: (json['title'] ?? '') as String,
        position: CourseSummary._asInt(json['position']) ?? 0,
        isIntro: json['is_intro'] == true,
        contentMarkdown: json['content_markdown'] as String?,
        moduleId: json['module_id'] as String?,
      );
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

  factory LessonDetail.fromJson(Map<String, dynamic> json) => LessonDetail(
        id: json['id'] as String,
        title: (json['title'] ?? '') as String,
        contentMarkdown: json['content_markdown'] as String?,
        isIntro: json['is_intro'] == true,
        moduleId: json['module_id'] as String?,
        position: CourseSummary._asInt(json['position']) ?? 0,
      );
}

class LessonMediaItem {
  const LessonMediaItem({
    required this.id,
    required this.kind,
    required this.storagePath,
    this.storageBucket,
    this.downloadUrl,
    this.mediaId,
    this.byteSize,
    this.contentType,
    this.originalName,
    this.position = 0,
  });

  final String id;
  final String kind;
  final String storagePath;
  final String? storageBucket;
  final String? downloadUrl;
  final String? mediaId;
  final int? byteSize;
  final String? contentType;
  final String? originalName;
  final int position;

  factory LessonMediaItem.fromJson(Map<String, dynamic> json) =>
      LessonMediaItem(
        id: json['id'] as String,
        kind: (json['kind'] ?? '') as String,
        storagePath: (json['storage_path'] ?? '') as String,
        storageBucket: json['storage_bucket'] as String?,
        downloadUrl: json['download_url'] as String?,
        mediaId: json['media_id'] as String?,
        byteSize: CourseSummary._asInt(json['byte_size']),
        contentType: json['content_type'] as String?,
        originalName: json['original_name'] as String?,
        position: CourseSummary._asInt(json['position']) ?? 0,
      );

  bool get isPublicBucket => (storageBucket ?? '').startsWith('public');

  String get fileName =>
      (originalName == null || originalName!.isEmpty)
          ? storagePath.split('/').last
          : originalName!;
}

class CourseOrderSummary {
  const CourseOrderSummary({
    required this.id,
    required this.status,
    this.amountCents,
    required this.createdAt,
  });

  final String id;
  final String status;
  final int? amountCents;
  final DateTime createdAt;

  factory CourseOrderSummary.fromJson(Map<String, dynamic> json) =>
      CourseOrderSummary(
        id: json['id'] as String,
        status: (json['status'] ?? '') as String,
        amountCents: CourseSummary._asInt(json['amount_cents']),
        createdAt: _parseDate(json['created_at']),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class CourseQuizInfo {
  const CourseQuizInfo({this.quizId, this.certified = false});

  final String? quizId;
  final bool certified;

  factory CourseQuizInfo.fromJson(Map<String, dynamic> json) => CourseQuizInfo(
        quizId: json['quiz_id'] as String?,
        certified: json['certified'] == true,
      );
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

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        position: CourseSummary._asInt(json['position']) ?? 0,
        kind: (json['kind'] ?? '') as String,
        prompt: (json['prompt'] ?? '') as String,
        options: _parseOptions(json['options']),
      );
}

List<String> _parseOptions(Object? rawOptions) {
  if (rawOptions is List) {
    return rawOptions.map((value) => value.toString()).toList(growable: false);
  }
  if (rawOptions is Map) {
    return rawOptions.values
        .map((value) => value.toString())
        .toList(growable: false);
  }
  if (rawOptions is String && rawOptions.trim().isNotEmpty) {
    return rawOptions.split('\n').map((value) => value.trim()).toList();
  }
  return const <String>[];
}
