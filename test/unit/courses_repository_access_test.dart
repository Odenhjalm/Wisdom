import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/features/courses/data/course_access_api.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _FakeAccessApi implements CourseAccessApi {
  _FakeAccessApi({this.primary = false, this.fallback = false, this.throwPrimary = false, this.throwFallback = false});

  final bool primary;
  final bool fallback;
  final bool throwPrimary;
  final bool throwFallback;

  @override
  Future<bool> fallbackHasAccess(String courseId) async {
    if (throwFallback) throw Exception('fallback');
    return fallback;
  }

  @override
  Future<bool> hasAccess(String courseId) async {
    if (throwPrimary) throw Exception('primary');
    return primary;
  }
}

void main() {
  group('CoursesRepository.hasAccess', () {
    test('returns true when primary api grants access', () async {
      final repo = CoursesRepository(
        client: _MockSupabaseClient(),
        accessApi: _FakeAccessApi(primary: true, fallback: false),
      );

      final result = await repo.hasAccess('course-1');

      expect(result, isTrue);
    });

    test('falls back when primary throws', () async {
      final repo = CoursesRepository(
        client: _MockSupabaseClient(),
        accessApi: _FakeAccessApi(
          primary: false,
          fallback: true,
          throwPrimary: true,
        ),
      );

      final result = await repo.hasAccess('course-2');

      expect(result, isTrue);
    });

    test('returns false when both fail', () async {
      final repo = CoursesRepository(
        client: _MockSupabaseClient(),
        accessApi: _FakeAccessApi(
          primary: false,
          fallback: false,
          throwPrimary: true,
          throwFallback: true,
        ),
      );

      final result = await repo.hasAccess('course-3');

      expect(result, isFalse);
    });
  });
}
