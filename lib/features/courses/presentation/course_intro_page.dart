import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/gate.dart';
import 'package:wisdom/shared/widgets/course_video.dart';
import 'package:wisdom/shared/widgets/go_router_back_button.dart';
import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';

class CourseIntroPage extends ConsumerWidget {
  const CourseIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final qp = state.uri.queryParameters;
    final courseId = qp['id'] ?? '';
    final title = qp['title'] ?? 'Introduktionskurs';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const GoRouterBackButton(),
        title: Text(title),
        actions: const [TopNavActionButtons()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        courseId.isEmpty
                            ? 'Detta är en introduktionskurs.'
                            : 'Detta är introduktionen för kursen med ID: $courseId.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      _IntroVideoPreview(courseId: courseId),
                      const SizedBox(height: 16),
                      _QuizActions(courseId: courseId),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            gate.allow();
                            context.go('/home');
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Gå vidare till Home'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroVideoPreview extends ConsumerWidget {
  const _IntroVideoPreview({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courseId.isEmpty) {
      return const CourseVideoSkeleton(
        message: 'Ingen kurs vald. Välj en kurs för att se introduktionen.',
      );
    }
    final course = ref.watch(courseByIdProvider(courseId));
    return course.when(
      loading: () => const CourseVideoSkeleton(message: 'Laddar kursintro…'),
      error: (error, _) => CourseVideoSkeleton(
        message: _friendlyError(error),
      ),
      data: (summary) {
        if (summary == null) {
          return const CourseVideoSkeleton(
            message: 'Kursen hittades inte.',
          );
        }
        final url = summary.videoUrl;
        if (url == null || url.isEmpty) {
          return const CourseVideoSkeleton(
            message: 'Ingen introduktionsvideo är publicerad ännu.',
          );
        }
        return CourseVideo(url: url);
      },
    );
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return 'Kunde inte ladda kursintro just nu.';
  }
}

class _QuizActions extends ConsumerWidget {
  const _QuizActions({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courseId.isEmpty) {
      return const SizedBox.shrink();
    }
    final info = ref.watch(courseQuizInfoProvider(courseId));
    return info.when(
      loading: () => const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _friendlyError(error),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (data) {
        final quizId = data.quizId;
        final certified = data.certified;
        if (quizId == null) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Text('Det finns inget quiz för denna kurs ännu.'),
          );
        }
        return Row(
          children: [
            if (certified)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(Icons.verified, color: Color(0xFF16A34A)),
                  label: Text('Certifierad'),
                  backgroundColor: Color(0xFFDCFCE7),
                ),
              ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => context.push('/course-quiz?quizId=$quizId'),
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Gör provet'),
            ),
          ],
        );
      },
    );
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return 'Kunde inte ladda quiz-information just nu.';
  }
}
