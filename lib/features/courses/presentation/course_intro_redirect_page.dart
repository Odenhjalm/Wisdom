import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/shared/utils/context_safe.dart';

/// Laddar första fria introduktionskursen och navigerar vidare till dess slug.
class CourseIntroRedirectPage extends ConsumerStatefulWidget {
  const CourseIntroRedirectPage({super.key});

  @override
  ConsumerState<CourseIntroRedirectPage> createState() =>
      _CourseIntroRedirectPageState();
}

class _CourseIntroRedirectPageState
    extends ConsumerState<CourseIntroRedirectPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    ref.listen<AsyncValue<CourseSummary?>>(
      firstFreeIntroCourseProvider,
      (previous, next) => _handleState(next),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleState(ref.read(firstFreeIntroCourseProvider));
    });
  }

  void _handleState(AsyncValue<CourseSummary?> value) {
    if (_navigated) return;
    value.when(
      data: (course) {
        if (_navigated) return;
        _navigated = true;
        final slug = course?.slug;
        context.ifMounted((c) {
          if (slug != null && slug.isNotEmpty) {
            c.go('/course/$slug');
          } else {
            c.go('/');
          }
        });
      },
      error: (_, __) {
        if (_navigated) return;
        _navigated = true;
        context.ifMounted((c) => c.go('/'));
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourse = ref.watch(firstFreeIntroCourseProvider);
    return Scaffold(
      body: Center(
        child: asyncCourse.when(
          loading: () => const CircularProgressIndicator(),
          data: (_) => const CircularProgressIndicator(),
          error: (error, _) {
            final message = _messageForError(error);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Till startsidan'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _messageForError(Object error) {
    if (error is AppFailure) return error.message;
    return 'Kunde inte hitta en introduktionskurs just nu.';
  }
}
