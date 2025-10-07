import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/payments/presentation/paywall_prompt.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';
import 'package:wisdom/features/payments/application/payments_providers.dart';

class CoursePage extends ConsumerStatefulWidget {
  const CoursePage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends ConsumerState<CoursePage> {
  bool _ordering = false;

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(courseDetailProvider(widget.slug));
    return asyncDetail.when(
      loading: () => const AppScaffold(
        title: 'Kurs',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Kurs',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (detail) => _CourseContent(
        detail: detail,
        ordering: _ordering,
        onEnroll: () => _handleEnroll(detail),
        onStartCheckout: () => _startCheckout(detail),
        onRefreshOrderStatus: () async {
          final repo = ref.read(coursesRepositoryProvider);
          await repo.latestOrderForCourse(detail.course.id);
          ref.invalidate(courseDetailProvider(widget.slug));
        },
        enrollState: ref.watch(enrollProvider(detail.course.id)),
      ),
    );
  }

  Future<void> _handleEnroll(CourseDetailData detail) async {
    final notifier = ref.read(enrollProvider(detail.course.id).notifier);
    await notifier.enroll();
    final state = ref.read(enrollProvider(detail.course.id));
    state.when(
      data: (_) {
        if (!mounted || !context.mounted) return;
        showSnack(context, 'Du är nu anmäld till introduktionen.');
        ref.invalidate(courseDetailProvider(widget.slug));
      },
      error: (error, _) {
        if (!mounted || !context.mounted) return;
        showSnack(context, 'Kunde inte anmäla: ${_friendlyError(error)}');
      },
      loading: () {},
    );
  }

  Future<void> _startCheckout(CourseDetailData detail) async {
    final courseId = detail.course.id;
    final price = detail.course.priceCents ?? 0;
    if (price <= 0) return;
    setState(() => _ordering = true);
    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final order = await repo.startCourseOrder(
        courseId: courseId,
        amountCents: price,
      );
      if (!mounted || !context.mounted) return;
      final url = await repo.checkoutUrl(
        orderId: order['id'] as String,
        successUrl:
            'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
      );
      if (url.isNotEmpty) {
        await launchUrlString(url);
        ref.invalidate(courseDetailProvider(widget.slug));
      } else {
        if (!mounted || !context.mounted) return;
        showSnack(context, 'Kunde inte initiera betalning.');
      }
    } catch (error) {
      if (!mounted || !context.mounted) return;
      showSnack(
        context,
        'Kunde inte skapa order: ${_friendlyError(error)}',
      );
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({
    required this.detail,
    required this.ordering,
    required this.onEnroll,
    required this.onStartCheckout,
    required this.onRefreshOrderStatus,
    required this.enrollState,
  });

  final CourseDetailData detail;
  final bool ordering;
  final VoidCallback onEnroll;
  final VoidCallback onStartCheckout;
  final Future<void> Function() onRefreshOrderStatus;
  final AsyncValue<void> enrollState;

  @override
  Widget build(BuildContext context) {
    final course = detail.course;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final priceCents = course.priceCents ?? 0;
    final hasAccess = detail.hasAccess;
    final isEnrolled = detail.isEnrolled;
    final hasSubscription = detail.hasActiveSubscription;
    final enrolledText = hasAccess
        ? (hasSubscription && !isEnrolled
            ? '• Prenumeration aktiv'
            : '• Du är anmäld')
        : '';
    final isEnrolling = enrollState.isLoading;
    final enrollError = enrollState.whenOrNull(
      error: (error, _) => error,
    );
    final canPurchase = priceCents > 0 && !hasAccess;

    return AppScaffold(
      title: course.title,
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style:
                        t.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  if (course.description != null)
                    Text(
                      course.description!,
                      style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isEnrolling ? null : onEnroll,
                          child: isEnrolling
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Starta gratis intro'),
                        ),
                      ),
                      if (priceCents > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: ordering || !canPurchase
                                ? null
                                : onStartCheckout,
                            child: ordering
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(hasAccess
                                    ? (hasSubscription && !isEnrolled
                                        ? 'Prenumeration aktiv'
                                        : 'Åtkomst aktiverad')
                                    : 'Köp hela kursen (${priceCents / 100} kr)'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Använda gratis-intros: ${detail.freeConsumed}/${detail.freeLimit} $enrolledText',
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (hasAccess && priceCents > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Du har redan full åtkomst till kursen.',
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (hasSubscription && !isEnrolled)
                      Text(
                        'Din prenumeration ger dig åtkomst till allt innehåll.',
                        style:
                            t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                  const SizedBox(height: 8),
                  if (detail.latestOrder != null)
                    Row(
                      children: [
                        Text('Betalstatus: ${detail.latestOrder!.status}',
                            style: t.bodySmall),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () => onRefreshOrderStatus(),
                          child: const Text('Uppdatera status'),
                        ),
                      ],
                    ),
                  if (enrollError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _friendlyError(enrollError),
                        style: t.bodySmall?.copyWith(color: cs.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...detail.modules.map(
            (module) {
              final lessons = detail.lessonsByModule[module.id] ?? const [];
              if (lessons.isEmpty) {
                return const SizedBox.shrink();
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style:
                            t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...lessons.map(
                        (lesson) {
                          final isLocked = !lesson.isIntro && !hasAccess;
                          return ListTile(
                            leading: Icon(
                              isLocked
                                  ? Icons.lock_outline_rounded
                                  : Icons.play_circle_outline_rounded,
                            ),
                            title: Text(lesson.title),
                            subtitle: lesson.isIntro
                                ? const Text('Förhandsvisning')
                                : (isLocked
                                    ? const Text('Låst innehåll')
                                    : null),
                            enabled: !isLocked,
                            onTap: () => _handleLessonTap(
                              context,
                              lesson,
                              detail,
                              isLocked,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openLesson(BuildContext context, String lessonId) {
    context.push('/lesson/$lessonId');
  }

  void _handleLessonTap(
    BuildContext context,
    LessonSummary lesson,
    CourseDetailData detail,
    bool isLocked,
  ) {
    if (!isLocked) {
      _openLesson(context, lesson.id);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Material(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PaywallPrompt(courseId: detail.course.id),
              ),
            ),
          ),
        );
      },
    );
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
