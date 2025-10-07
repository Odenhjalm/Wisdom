import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/studio/data/studio_repository.dart';
import 'package:wisdom/features/studio/presentation/course_editor_page.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/env/app_config.dart';
import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart';
import 'package:wisdom/features/studio/application/studio_upload_queue.dart';

class _MockStudioRepository extends Mock implements StudioRepository {}

class _MockCoursesRepository extends Mock implements CoursesRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeAuthController extends AuthController {
  _FakeAuthController() : super(_MockAuthRepository()) {
    state = AuthState(
      profile: Profile(
        id: 'user-1',
        email: 'teacher@example.com',
        userRole: UserRole.teacher,
        isAdmin: false,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
  }

  @override
  Future<void> loadSession() async {}
}

class _NoopUploadQueueNotifier extends UploadQueueNotifier {
  _NoopUploadQueueNotifier(super.repo);

  @override
  String enqueueUpload({
    required String courseId,
    required String lessonId,
    required Uint8List data,
    required String filename,
    required String contentType,
    required bool isIntro,
  }) {
    return 'noop';
  }

  @override
  void cancelUpload(String id) {}

  @override
  void retryUpload(String id) {}

  @override
  void removeJob(String id) {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration());
  });

  testWidgets('CourseEditorScreen renders provided course data',
      (tester) async {
    final studioRepo = _MockStudioRepository();
    final coursesRepo = _MockCoursesRepository();

    when(() => studioRepo.myCourses()).thenAnswer((_) async => [
          {'id': 'course-1', 'title': 'Tarot Basics'}
        ]);
    when(() => studioRepo.fetchStatus()).thenAnswer((_) async =>
        const StudioStatus(
            isTeacher: true, verifiedCertificates: 1, hasApplication: false));
    when(() => studioRepo.fetchCourseMeta('course-1')).thenAnswer((_) async => {
          'title': 'Tarot Basics',
          'slug': 'tarot-basics',
          'description': 'Lär dig läsa korten',
          'price_cents': 1200,
          'is_free_intro': true,
          'is_published': false,
        });
    when(() => studioRepo.listModules('course-1')).thenAnswer((_) async => [
          {'id': 'module-1', 'title': 'Intro', 'position': 1},
        ]);
    when(() => studioRepo.listLessons('module-1')).thenAnswer((_) async => [
          {
            'id': 'lesson-1',
            'title': 'Välkommen',
            'position': 1,
            'is_intro': true,
          }
        ]);
    when(() => studioRepo.listLessonMedia('lesson-1')).thenAnswer((_) async => [
          {
            'id': 'media-1',
            'kind': 'video',
            'storage_path': 'course-1/lesson-1/video.mp4',
            'storage_bucket': 'public-media',
            'position': 1,
          }
        ]);

    final courseDetail = CourseDetailData(
      course: const CourseSummary(
        id: 'course-1',
        slug: 'tarot-basics',
        title: 'Tarot Basics',
        description: 'Lär dig läsa korten',
        coverUrl: null,
        videoUrl: null,
        isFreeIntro: true,
        isPublished: true,
        priceCents: 1200,
      ),
      modules: const [
        CourseModule(id: 'module-1', title: 'Intro', position: 1),
      ],
      lessonsByModule: {
        'module-1': const [
          LessonSummary(
            id: 'lesson-1',
            title: 'Välkommen',
            position: 1,
            isIntro: true,
            contentMarkdown: null,
          ),
        ],
      },
      freeConsumed: 0,
      freeLimit: 3,
      isEnrolled: false,
      latestOrder: null,
    );
    when(() => coursesRepo.fetchCourseDetailBySlug(any()))
        .thenAnswer((_) async => courseDetail);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig(
            apiBaseUrl: 'http://localhost:8000',
            stripePublishableKey: 'pk_test_stub',
            stripeMerchantDisplayName: 'Test Merchant',
          )),
          authControllerProvider.overrideWith((ref) => _FakeAuthController()),
          studioRepositoryProvider.overrideWithValue(studioRepo),
          coursesRepositoryProvider.overrideWithValue(coursesRepo),
          studioStatusProvider.overrideWith((ref) async => const StudioStatus(
                isTeacher: true,
                verifiedCertificates: 1,
                hasApplication: false,
              )),
          studioUploadQueueProvider.overrideWith(
            (ref) => _NoopUploadQueueNotifier(studioRepo),
          ),
        ],
        child: MaterialApp(
          home: CourseEditorScreen(
            studioRepository: studioRepo,
            coursesRepository: coursesRepo,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tarot Basics'), findsWidgets);
    expect(find.text('Moduler & lektioner'), findsOneWidget);
    expect(find.text('Välkommen'), findsWidgets);
    expect(find.text('Förhandsgranska kurs'), findsOneWidget);
  });
}
