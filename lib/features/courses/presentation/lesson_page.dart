import 'dart:async';

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/supabase/supabase_client.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/courses/presentation/course_access_gate.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

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

    final coreContent = Column(
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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: detail.previousLesson == null
                    ? null
                    : () => context.go('/lesson/${detail.previousLesson!.id}'),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Föregående'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: detail.nextLesson == null
                    ? null
                    : () => context.go('/lesson/${detail.nextLesson!.id}'),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Nästa'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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

class _MediaItem extends StatefulWidget {
  const _MediaItem({required this.item});

  final LessonMediaItem item;

  @override
  State<_MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<_MediaItem> {
  Uint8List? _data;
  bool _loading = false;
  String? _error;

  LessonMediaItem get item => widget.item;

  bool get _isPublicBucket => item.storageBucket == 'public-media';

  @override
  void initState() {
    super.initState();
    if (!_isPublicBucket) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await Supa.client.storage
          .from(item.storageBucket)
          .download(item.storagePath);
      if (!mounted) return;
      setState(() {
        _data = bytes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _fileName => item.storagePath.split('/').last;

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

  Future<void> _saveToFile() async {
    final bytes = _data;
    if (bytes == null) return;
    final location = await getSaveLocation(suggestedName: _fileName);
    if (location == null) return;
    final file = XFile.fromData(bytes, name: _fileName);
    await file.saveTo(location.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fil sparad.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPublicBucket) {
      final url = Supa.client.storage
          .from(item.storageBucket)
          .getPublicUrl(item.storagePath);
      if (item.kind == 'image') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.cover),
          ),
        );
      }
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(_iconForKind()),
        title: Text(_fileName),
        subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () {},
      );
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(_fileName),
        subtitle: Text('Kunde inte läsa media: $_error'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _load,
        ),
      );
    }
    final bytes = _data;
    if (bytes == null) {
      return const SizedBox.shrink();
    }

    if (item.kind == 'image') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, fit: BoxFit.cover),
        ),
      );
    }

    return ListTile(
      leading: Icon(_iconForKind()),
      title: Text(_fileName),
      subtitle:
          Text('${item.kind.toUpperCase()} • ${bytes.lengthInBytes} bytes'),
      trailing: IconButton(
        tooltip: 'Spara fil',
        icon: const Icon(Icons.download_outlined),
        onPressed: _saveToFile,
      ),
    );
  }
}
