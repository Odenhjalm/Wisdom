import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:wisdom/api/api_client.dart';

class StudioRepository {
  StudioRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<StudioStatus> fetchStatus() async {
    final res = await _client.get<Map<String, dynamic>>('/studio/status');
    return StudioStatus.fromJson(res);
  }

  Future<void> applyAsTeacher() async {
    await _client.post('/studio/apply');
  }

  Future<List<Map<String, dynamic>>> myCourses() async {
    final res = await _client.get<Map<String, dynamic>>('/studio/courses');
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String slug,
    String? description,
    int? priceCents,
    bool isFreeIntro = false,
    bool isPublished = false,
    String? coverUrl,
    String? videoUrl,
    String? branch,
  }) async {
    final body = {
      'title': title,
      'slug': slug,
      if (description != null) 'description': description,
      if (priceCents != null) 'price_cents': priceCents,
      'is_free_intro': isFreeIntro,
      'is_published': isPublished,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (branch != null) 'branch': branch,
    };
    final res = await _client.post<Map<String, dynamic>>(
      '/studio/courses',
      body: body,
    );
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>?> fetchCourseMeta(String courseId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/courses/$courseId',
    );
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> updateCourse(
    String courseId,
    Map<String, dynamic> patch,
  ) async {
    final res = await _client.patch<Map<String, dynamic>>(
      '/studio/courses/$courseId',
      body: patch,
    );
    return Map<String, dynamic>.from(res!);
  }

  Future<void> deleteCourse(String courseId) async {
    await _client.delete('/studio/courses/$courseId');
  }

  Future<List<Map<String, dynamic>>> listModules(String courseId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/courses/$courseId/modules',
    );
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createModule({
    required String courseId,
    required String title,
    int position = 0,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/studio/modules',
      body: {'course_id': courseId, 'title': title, 'position': position},
    );
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> updateModule(
    String moduleId,
    Map<String, dynamic> patch,
  ) async {
    final res = await _client.patch<Map<String, dynamic>>(
      '/studio/modules/$moduleId',
      body: patch,
    );
    return Map<String, dynamic>.from(res!);
  }

  Future<void> deleteModule(String moduleId) async {
    await _client.delete('/studio/modules/$moduleId');
  }

  Future<List<Map<String, dynamic>>> listLessons(String moduleId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/modules/$moduleId/lessons',
    );
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> upsertLesson({
    String? id,
    required String moduleId,
    required String title,
    String? contentMarkdown,
    int position = 0,
    bool isIntro = false,
  }) async {
    if (id == null) {
      final res = await _client.post<Map<String, dynamic>>(
        '/studio/lessons',
        body: {
          'module_id': moduleId,
          'title': title,
          'content_markdown': contentMarkdown,
          'position': position,
          'is_intro': isIntro,
        },
      );
      return Map<String, dynamic>.from(res);
    } else {
      final body = <String, dynamic>{
        'title': title,
        if (contentMarkdown != null) 'content_markdown': contentMarkdown,
        'position': position,
        'is_intro': isIntro,
      };
      final res = await _client.patch<Map<String, dynamic>>(
        '/studio/lessons/$id',
        body: body,
      );
      return Map<String, dynamic>.from(res!);
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    await _client.delete('/studio/lessons/$lessonId');
  }

  Future<void> updateLessonIntro({
    required String lessonId,
    required bool isIntro,
  }) async {
    await _client.patch(
      '/studio/lessons/$lessonId/intro',
      body: {'is_intro': isIntro},
    );
  }

  Future<List<Map<String, dynamic>>> listLessonMedia(String lessonId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/lessons/$lessonId/media',
    );
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> uploadLessonMedia({
    required String courseId,
    required String lessonId,
    required Uint8List data,
    required String filename,
    required String contentType,
    required bool isIntro,
    void Function(UploadProgress progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      'is_intro': isIntro,
      'file': MultipartFile.fromBytes(
        data,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    });

    final res = await _client.postForm<Map<String, dynamic>>(
      '/studio/lessons/$lessonId/media',
      formData,
      onSendProgress: onProgress == null
          ? null
          : (sent, total) {
              if (total <= 0) return;
              onProgress(UploadProgress(sent: sent, total: total));
            },
      cancelToken: cancelToken,
    );
    return Map<String, dynamic>.from(res ?? const {});
  }

  Future<void> deleteLessonMedia(String mediaId) async {
    await _client.delete('/studio/media/$mediaId');
  }

  Future<void> reorderLessonMedia(
    String lessonId,
    List<String> orderedMediaIds,
  ) async {
    await _client.patch(
      '/studio/lessons/$lessonId/media/reorder',
      body: {'media_ids': orderedMediaIds},
    );
  }

  Future<Uint8List> downloadMedia(String mediaId) {
    return _client.getBytes('/studio/media/$mediaId');
  }

  Future<Map<String, dynamic>> ensureQuiz(String courseId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/studio/courses/$courseId/quiz',
    );
    return Map<String, dynamic>.from(res['quiz'] as Map);
  }

  Future<List<Map<String, dynamic>>> myCertificates({
    bool verifiedOnly = false,
  }) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/certificates',
      queryParameters: {'verified_only': verifiedOnly},
    );
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> addCertificate({
    required String title,
    String status = 'pending',
    String? notes,
    String? evidenceUrl,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/studio/certificates',
      body: {
        'title': title,
        'status': status,
        if (notes != null) 'notes': notes,
        if (evidenceUrl != null) 'evidence_url': evidenceUrl,
      },
    );
    return Map<String, dynamic>.from(res);
  }

  Future<List<Map<String, dynamic>>> quizQuestions(String quizId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/studio/quizzes/$quizId/questions',
    );
    final list = res['items'] as List? ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> upsertQuestion({
    required String quizId,
    String? id,
    required Map<String, dynamic> data,
  }) async {
    final body = {...data}..remove('quiz_id');
    if (id == null) {
      final res = await _client.post<Map<String, dynamic>>(
        '/studio/quizzes/$quizId/questions',
        body: body,
      );
      return Map<String, dynamic>.from(res);
    } else {
      final res = await _client.patch<Map<String, dynamic>>(
        '/studio/quizzes/$quizId/questions/$id',
        body: body,
      );
      return Map<String, dynamic>.from(res!);
    }
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _client.delete('/studio/quizzes/$quizId/questions/$questionId');
  }
}

class UploadProgress {
  const UploadProgress({required this.sent, required this.total});

  final int sent;
  final int total;

  double get fraction => total == 0 ? 0 : sent / total;
}

class StudioStatus {
  const StudioStatus({
    required this.isTeacher,
    required this.verifiedCertificates,
    required this.hasApplication,
  });

  final bool isTeacher;
  final int verifiedCertificates;
  final bool hasApplication;

  factory StudioStatus.fromJson(Map<String, dynamic> json) => StudioStatus(
        isTeacher: json['is_teacher'] == true,
        verifiedCertificates:
            (json['verified_certificates'] as num?)?.toInt() ?? 0,
        hasApplication: json['has_application'] == true,
      );
}
