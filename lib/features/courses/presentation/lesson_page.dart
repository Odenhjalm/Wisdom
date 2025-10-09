import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/courses/presentation/course_access_gate.dart';
import 'package:wisdom/features/media/application/media_providers.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  ProviderSubscription<AsyncValue<LessonDetailData>>? _lessonSub;

  @override
  void initState() {
    super.initState();
    _lessonSub = ref.listenManual<AsyncValue<LessonDetailData>>(
      lessonDetailProvider(widget.lessonId),
      (previous, next) {
        next.whenData(_updateProgress);
      },
    );
  }

  @override
  void dispose() {
    _lessonSub?.close();
    super.dispose();
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
    final courseLessons = detail.courseLessons;
    LessonSummary? previous;
    LessonSummary? next;
    if (courseLessons.isNotEmpty) {
      final index =
          courseLessons.indexWhere((element) => element.id == lesson.id);
      if (index > 0) {
        previous = courseLessons[index - 1];
      }
      if (index >= 0 && index < courseLessons.length - 1) {
        next = courseLessons[index + 1];
      }
    }

    final coreContent = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Markdown(
              data: lesson.contentMarkdown ?? 'Inget innehåll.',
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            ),
          ),
        ),
        if (media.isNotEmpty) ...[
          const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final prev = previous;
                  if (prev == null) return;
                  context.go('/lesson/${prev.id}');
                },
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Föregående'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final nxt = next;
                  if (nxt == null) return;
                  context.go('/lesson/${nxt.id}');
                },
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Nästa'),
              ),
            ),
          ],
        ),
      ],
    );

    final courseId = detail.module?.courseId;
    final gatedContent = (!lesson.isIntro && courseId != null)
        ? CourseAccessGate(
            courseId: courseId,
            child: coreContent,
          )
        : coreContent;

    return AppScaffold(
      title: lesson.title,
      body: gatedContent,
    );
  }
}

class _MediaItem extends ConsumerWidget {
  const _MediaItem({required this.item});

  final LessonMediaItem item;

  String get _fileName => item.fileName;

  IconData _iconForKind() {
    switch (item.kind) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.movie_creation_outlined;
      case 'audio':
        return Icons.audiotrack_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaRepo = ref.watch(mediaRepositoryProvider);
    String? downloadUrl;
    if (item.downloadUrl != null) {
      try {
        downloadUrl = mediaRepo.resolveUrl(item.downloadUrl!);
      } catch (_) {
        downloadUrl = item.downloadUrl;
      }
    }
    final extension = () {
      final name = _fileName;
      final index = name.lastIndexOf('.');
      if (index <= 0 || index == name.length - 1) return null;
      final ext = name.substring(index + 1).toLowerCase();
      return ext.isEmpty ? null : ext;
    }();

    if (item.kind == 'image' && item.downloadUrl != null) {
      final future = mediaRepo.cacheMediaBytes(
        cacheKey: item.mediaId ?? item.id,
        downloadPath: item.downloadUrl!,
        fileExtension: extension,
      );
      return FutureBuilder<Uint8List>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            if (downloadUrl == null) {
              return ListTile(
                leading: Icon(_iconForKind()),
                title: Text(_fileName),
                subtitle: const Text('Kunde inte läsa bilden'),
              );
            }
            final url = downloadUrl;
            return ListTile(
              leading: Icon(_iconForKind()),
              title: Text(_fileName),
              subtitle: const Text('Kunde inte läsa bilden'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () => launchUrlString(url),
              ),
              onTap: () => launchUrlString(url),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(snapshot.data!, fit: BoxFit.cover),
            ),
          );
        },
      );
    }

    if (downloadUrl == null) {
      return ListTile(
        leading: Icon(_iconForKind()),
        title: Text(_fileName),
      );
    }

    final url = downloadUrl;
    return ListTile(
      leading: Icon(_iconForKind()),
      title: Text(_fileName),
      subtitle: Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new_rounded),
        onPressed: () => launchUrlString(url),
      ),
      onTap: () => launchUrlString(url),
    );
  }
}
