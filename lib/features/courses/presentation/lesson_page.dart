import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:visdom/core/errors/app_failure.dart';
import 'package:visdom/data/supabase/supabase_client.dart';
import 'package:visdom/features/courses/application/course_providers.dart';
import 'package:visdom/features/courses/data/courses_repository.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  @override
  void initState() {
    super.initState();
    ref.listen<AsyncValue<LessonDetailData>>(
      lessonDetailProvider(widget.lessonId),
      (previous, next) {
        next.whenData(_updateProgress);
      },
    );
  }

  Future<void> _updateProgress(LessonDetailData data) async {
    final courseId = data.module?.courseId;
    if (courseId == null || data.courseLessons.isEmpty) return;
    final index = data.courseLessons.indexWhere((l) => l.id == data.lesson.id);
    if (index < 0) return;
    final progress = (index + 1) / data.courseLessons.length;
    final progressRepo = ref.read(progressRepositoryProvider);
    unawaited(progressRepo.setProgress(courseId, progress));
  }

  @override
  Widget build(BuildContext context) {
    final asyncLesson = ref.watch(lessonDetailProvider(widget.lessonId));
    return asyncLesson.when(
      loading: () => const AppScaffold(
        title: 'Lektion',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Lektion',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (data) => _LessonContent(detail: data),
    );
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return 'Kunde inte ladda lektionen.';
  }
}

class _LessonContent extends StatelessWidget {
  const _LessonContent({required this.detail});

  final LessonDetailData detail;

  @override
  Widget build(BuildContext context) {
    final lesson = detail.lesson;
    final media = detail.media;

    return AppScaffold(
      title: lesson.title,
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Markdown(
                  data: lesson.contentMarkdown ?? 'Inget innehåll.',
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
              ),
            ),
          ),
          if (media.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Media'),
                    const SizedBox(height: 6),
                    ...media.map((item) => _MediaItem(item: item)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: detail.previousLesson == null
                    ? null
                    : () => context.go('/lesson/${detail.previousLesson!.id}'),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Föregående'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: detail.nextLesson == null
                    ? null
                    : () => context.go('/lesson/${detail.nextLesson!.id}'),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Nästa'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({required this.item});

  final LessonMediaItem item;

  @override
  Widget build(BuildContext context) {
    final url = Supa.client.storage.from('media').getPublicUrl(item.storagePath);
    switch (item.kind) {
      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.cover),
          ),
        );
      default:
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.perm_media_rounded),
          title: Text(item.kind),
          subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {},
        );
    }
  }
}
