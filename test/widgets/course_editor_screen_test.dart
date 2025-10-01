import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/studio/data/studio_repository.dart';
import 'package:wisdom/features/studio/data/teacher_repository.dart';
import 'package:wisdom/features/studio/presentation/course_editor_page.dart';
import 'package:wisdom/domain/services/auth_service.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthService extends Mock implements AuthService {}

class _MockStudioRepository extends Mock implements StudioRepository {}

class _MockTeacherRepository extends Mock implements TeacherRepository {}

class _MockCoursesRepository extends Mock implements CoursesRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration());
  });

  testWidgets('CourseEditorScreen renders provided course data', (tester) async {
    final supabase = _MockSupabaseClient();
    final auth = _MockGoTrueClient();
    when(() => supabase.auth).thenReturn(auth);
    final user = User.fromJson({
      'id': 'user-1',
      'email': 'teacher@example.com',
      'aud': 'authenticated',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': DateTime.now().toIso8601String(),
    })!;
    when(() => auth.currentUser).thenReturn(user);

    final authService = _MockAuthService();
    when(() => authService.isTeacher()).thenAnswer((_) async => true);

    final studioRepo = _MockStudioRepository();
    final coursesRepo = _MockCoursesRepository();
    final teacherRepo = _MockTeacherRepository();

    when(() => studioRepo.myCourses()).thenAnswer((_) async => [
          {'id': 'course-1', 'title': 'Tarot Basics'}
        ]);
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

    const courseDetail = CourseDetailData(
      course: CourseSummary(
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
      modules: [
        CourseModule(id: 'module-1', title: 'Intro', position: 1),
      ],
      lessonsByModule: {
        'module-1': [
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
        child: MaterialApp(
          home: CourseEditorScreen(
            supabaseClient: supabase,
            authService: authService,
            studioRepository: studioRepo,
            teacherRepository: teacherRepo,
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
