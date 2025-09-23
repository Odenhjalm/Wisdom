import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/top_nav_action_buttons.dart';
import '../../gate.dart';
import '../../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase_client.dart';
import '../../core/widgets/course_video.dart';
import '../../ui/widgets/go_router_back_button.dart';

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
  final String courseId;
  const _IntroVideoPreview({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularCoursesProvider); // reuse fetch; small demo
    return async.when(
      loading: () => const CourseVideoSkeleton(message: 'Laddar kursintro…'),
      error: (_, __) => const CourseVideoSkeleton(
        message: 'Kunde inte ladda kursintro just nu.',
      ),
      data: (state) {
        if (state.hasError && state.items.isEmpty) {
          return CourseVideoSkeleton(
            message: state.errorMessage ??
                'Kunde inte ladda kursintro just nu.',
          );
        }
        final m = state.items.cast<Map<String, dynamic>?>().firstWhere(
                  (e) => (e?['id'] ?? '') == courseId,
                  orElse: () => null,
                ) ??
            {};
        final url = (m['video_url'] ?? '') as String?;
        if (state.hasError && state.errorMessage != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ),
              CourseVideo(url: url),
            ],
          );
        }
        return CourseVideo(url: url);
      },
    );
  }
}

class _QuizActions extends ConsumerWidget {
  final String courseId;
  const _QuizActions({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null || courseId.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        String? quizId;
        bool certified = false;
        final quizRes = await sb
            .from('course_quizzes')
            .select('id')
            .eq('course_id', courseId)
            .limit(1);
        final quizList = (quizRes as List);
        if (quizList.isNotEmpty) {
          quizId = quizList.first['id'] as String?;
        }
        final uid = sb.auth.currentUser?.id;
        if (uid != null) {
          final certRes = await sb
              .from('certificates')
              .select('id')
              .eq('user_id', uid)
              .eq('course_id', courseId)
              .limit(1);
          certified = (certRes as List).isNotEmpty;
        }
        return {'quizId': quizId, 'certified': certified};
      }(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 36, child: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data ?? const {};
        final quizId = data['quizId'] as String?;
        final certified = data['certified'] == true;
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
            if (quizId != null)
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
}
