import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/community/data/posts_repository.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';
import 'package:wisdom/shared/widgets/courses_grid.dart';
import 'package:wisdom/shared/widgets/home_hero_panel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _composer = TextEditingController();
  RealtimeChannel? _postsChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _subscribeToPosts());
  }

  Future<void> _subscribeToPosts() async {
    try {
      final repo = ref.read(postsRepositoryProvider);
      _postsChannel = await repo.subscribeToFeed(
        onChanged: () => ref.invalidate(postsProvider),
      );
    } catch (_) {
      // Ignore subscription errors; feed still available via manual refresh.
    }
  }

  @override
  void dispose() {
    _composer.dispose();
    if (_postsChannel != null) {
      Supabase.instance.client.removeChannel(_postsChannel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(myCoursesProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final postsAsync = ref.watch(postsProvider);
    final feedPublisher = ref.watch(postPublisherProvider);

    final progressAsync = coursesAsync.when<AsyncValue<Map<String, double>>>(
      data: (courses) {
        if (courses.isEmpty) {
          return const AsyncValue.data({});
        }
        final ids = courses.map((c) => c.id).toList();
        return ref.watch(courseProgressProvider(CourseProgressRequest(ids)));
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );

    return AppScaffold(
      title: 'Andlig Väg',
      disableBack: true,
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      appBarForegroundColor: Colors.white,
      background: FullBleedBackground(
        image: const AssetImage('assets/images/bakgrund.png'),
        alignment: Alignment.center,
        topOpacity: 0.28,
        overlayColor: Theme.of(context).brightness != Brightness.dark
            ? const Color(0xFFFFE2B8).withValues(alpha: 0.10)
            : null,
        child: const SizedBox.shrink(),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Inställningar',
        ),
        IconButton(
          onPressed: () => context.push('/profile'),
          icon: const Icon(Icons.person_rounded),
          tooltip: 'Profil',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsProvider);
          ref.invalidate(myCoursesProvider);
          ref.invalidate(myProfileProvider);
        },
        child: ListView(
          children: [
            profileAsync.maybeWhen(
              data: (profile) => HomeHeroPanel(
                displayName: (profile?['display_name'] as String?) ??
                    (profile?['email'] as String?),
              ),
              orElse: () => const HomeHeroPanel(),
            ),
            _ComposerCard(
              controller: _composer,
              onPublish: _publishPost,
              isPublishing: feedPublisher.isLoading,
              error: feedPublisher.whenOrNull(error: (error, _) => error),
            ),
            const SizedBox(height: 12),
            postsAsync.when(
              loading: () => const _FeedCard.loading(),
              error: (error, _) => _FeedCard.error(message: _errorText(error)),
              data: (posts) => _FeedCard(posts: posts),
            ),
            const SizedBox(height: 18),
            _ShortcutCards(),
            const SizedBox(height: 18),
            _CoursesCard(
              coursesAsync: coursesAsync,
              progressAsync: progressAsync,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishPost(String content) async {
    final text = content.trim();
    if (text.isEmpty) return;
    await ref.read(postPublisherProvider.notifier).publish(content: text);
    final state = ref.read(postPublisherProvider);
    state.when(
      data: (post) {
        _composer.clear();
        ref.invalidate(postsProvider);
        if (post != null) {
          if (!mounted || !context.mounted) return;
          showSnack(context, 'Inlägget publicerades.');
        }
      },
      error: (error, _) {
        if (!mounted || !context.mounted) return;
        showSnack(
          context,
          'Kunde inte publicera: ${_errorText(error)}',
        );
      },
      loading: () {},
    );
  }

  String _errorText(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.controller,
    required this.onPublish,
    required this.isPublishing,
    required this.error,
  });

  final TextEditingController controller;
  final Future<void> Function(String text) onPublish;
  final bool isPublishing;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dela något i communityt',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration:
                  const InputDecoration(hintText: 'Skriv ett inlägg...'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed:
                    isPublishing ? null : () => onPublish(controller.text),
                child: isPublishing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publicera'),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage(error),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is AppFailure) return error.message;
    return error?.toString() ?? 'Ett okänt fel inträffade.';
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard._({
    required this.posts,
    required this.loading,
    required this.errorMessage,
  });

  const _FeedCard({required List<CommunityPost> posts})
      : this._(posts: posts, loading: false, errorMessage: null);

  const _FeedCard.loading()
      : this._(posts: const [], loading: true, errorMessage: null);

  const _FeedCard.error({required String message})
      : this._(posts: const [], loading: false, errorMessage: message);

  final List<CommunityPost> posts;
  final bool loading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(errorMessage!, style: t.bodyMedium),
        ),
      );
    }
    if (posts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text('Inga inlägg ännu.', style: t.bodyMedium),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nyligen i communityt',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...posts.map(
              (post) => ListTile(
                leading: const Icon(Icons.person_rounded),
                title: Text(post.profile?.displayName ?? 'Användare'),
                subtitle: Text(post.content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Välkommen hem.',
                style: t.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Utforska introduktionskurser (gratis förhandsvisningar).',
              style: t.bodyLarge,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/course/intro'),
                  child: const Text('Öppna introduktionskurs'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/studio'),
                  child: const Text('Gå till Studio (lärare)'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/community'),
                  child: const Text('Community'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/tarot'),
                  child: const Text('Tarotförfrågan'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/booking'),
                  child: const Text('Bokningar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesCard extends StatelessWidget {
  const _CoursesCard({
    required this.coursesAsync,
    required this.progressAsync,
  });

  final AsyncValue<List<CourseSummary>> coursesAsync;
  final AsyncValue<Map<String, double>> progressAsync;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mina kurser',
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            coursesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text(
                error is AppFailure ? error.message : error.toString(),
                style: t.bodyMedium,
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return Text('Du är ännu inte anmäld till någon kurs.',
                      style: t.bodyMedium);
                }
                return progressAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    error is AppFailure ? error.message : error.toString(),
                    style: t.bodyMedium,
                  ),
                  data: (progress) => CoursesGrid(
                    courses: courses,
                    progress: progress,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
