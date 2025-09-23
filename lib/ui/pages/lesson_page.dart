import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/course_service.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/data/progress_service.dart';

class LessonPage extends StatefulWidget {
  final String lessonId;
  const LessonPage({super.key, required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final _svc = CourseService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _lesson;
  List<Map<String, dynamic>> _siblings = [];
  int _indexInModule = -1;
  List<Map<String, dynamic>> _media = [];
  List<Map<String, dynamic>> _allLessons = [];
  int _globalIndex = -1;
  final _progress = ProgressService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final l = await _svc.getLesson(widget.lessonId);
      if (!mounted) return;
      if (l == null) {
        setState(() {
          _error = 'Den här lektionen är låst eller saknas.';
          _loading = false;
        });
        return;
      }
      // Fetch siblings in same module to compute prev/next
      final moduleId = l['module_id'] as String?;
      var siblings = <Map<String, dynamic>>[];
      var idx = -1;
      if (moduleId != null) {
        siblings = await _svc.listLessonsForModule(moduleId);
        idx = siblings.indexWhere((e) => e['id'] == l['id']);
      }
      final media = await _svc.listLessonMedia(l['id'] as String);

      // Build global lesson order across modules
      List<Map<String, dynamic>> global = [];
      int globalIdx = -1;
      if (moduleId != null) {
        final mod = await _svc.getModule(moduleId);
        if (mod != null) {
          final courseId = mod['course_id'] as String;
          final modules = await _svc.listModules(courseId);
          for (final m in modules) {
            final ls = await _svc.listLessonsForModule(m['id'] as String);
            for (final entry in ls) {
              if (globalIdx == -1 && entry['id'] == l['id']) {
                globalIdx = global.length;
              }
              global.add(entry);
            }
          }
        }
      }
      setState(() {
        _lesson = l;
        _siblings = siblings;
        _indexInModule = idx;
        _media = media;
        _allLessons = global;
        _globalIndex = globalIdx;
        _loading = false;
      });
      // Uppdatera lokal progress per kurs (approx): position / antal
      try {
        if (moduleId != null && global.isNotEmpty && globalIdx >= 0) {
          // Hämta kursId via mod
          // Vi har redan mod ovan (mod), använd dess course_id
          final courseId =
              (await _svc.getModule(moduleId))?['course_id'] as String?;
          if (courseId != null) {
            final pct = (globalIdx + 1) / global.length;
            // ignore: unawaited_futures
            _progress.setProgress(courseId, pct);
          }
        }
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Kunde inte ladda lektionen: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Lektion',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return AppScaffold(
        title: 'Lektion',
        body: Center(child: Text(_error!)),
      );
    }
    final l = _lesson!;
    final String title = (l['title'] as String?) ?? 'Lektion';
    final String md = (l['content_markdown'] as String?) ?? 'Inget innehåll.';

    return AppScaffold(
      title: title,
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Markdown(
                  data: md,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
              ),
            ),
          ),
          if (_media.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Media'),
                    const SizedBox(height: 6),
                    ..._media.map((m) => _MediaItem(item: m)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _prevId == null
                    ? null
                    : () => context.go('/lesson/${_prevId!}'),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Föregående'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _nextId == null
                    ? null
                    : () => context.go('/lesson/${_nextId!}'),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Nästa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? get _prevId {
    if (_indexInModule <= 0) return null;
    return _siblings[_indexInModule - 1]['id'] as String?;
  }

  String? get _nextId {
    // Prefer within module; fall back to global order
    if (_indexInModule >= 0 && _indexInModule + 1 < _siblings.length) {
      return _siblings[_indexInModule + 1]['id'] as String?;
    }
    if (_globalIndex >= 0 && _globalIndex + 1 < _allLessons.length) {
      return _allLessons[_globalIndex + 1]['id'] as String?;
    }
    return null;
  }
}

class _MediaItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MediaItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final kind = (item['kind'] as String?) ?? 'other';
    final path = (item['storage_path'] as String?) ?? '';
    final url = Supa.client.storage.from('media').getPublicUrl(path);
    switch (kind) {
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
          title: Text(kind),
          subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            // No webview here; users can copy URL or open externally if platform supports.
          },
        );
    }
  }
}
