import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../components/top_nav_action_buttons.dart';
import '../../core/ui/ui_consts.dart';
import '../../core/utils/context_safe.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/teacher_repo.dart';
import '../../domain/services/auth_service.dart';
import '../../supabase_client.dart';

class CourseEditorScreen extends ConsumerStatefulWidget {
  final String? courseId;
  const CourseEditorScreen({super.key, this.courseId});

  @override
  ConsumerState<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends ConsumerState<CourseEditorScreen> {
  bool _checking = true;
  bool _allowed = false;
  bool _savingModule = false;
  String? _moduleUrlError;

  final TeacherRepo _repo = TeacherRepo();
  List<Map<String, dynamic>> _courses = <Map<String, dynamic>>[];
  String? _selectedCourseId;
  List<Map<String, dynamic>> _modules = <Map<String, dynamic>>[];

  final TextEditingController _newCourseTitle = TextEditingController();
  final TextEditingController _newCourseDesc = TextEditingController();
  final TextEditingController _moduleTitle = TextEditingController();
  final TextEditingController _moduleBody = TextEditingController();
  String _moduleType = 'text';
  String? _mediaUrl;

  Map<String, dynamic>? _quiz;
  final TextEditingController _qPrompt = TextEditingController();
  final TextEditingController _qOptions = TextEditingController();
  final TextEditingController _qCorrect = TextEditingController();
  String _qKind = 'single';
  List<Map<String, dynamic>> _questions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _moduleTitle.dispose();
    _moduleBody.dispose();
    _qPrompt.dispose();
    _qOptions.dispose();
    _qCorrect.dispose();
    _newCourseTitle.dispose();
    _newCourseDesc.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null || sb.auth.currentUser == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    try {
      final allowed = await AuthService(client: sb).isTeacher();
      List<Map<String, dynamic>> myCourses = <Map<String, dynamic>>[];
      if (allowed) {
        myCourses = await _repo.myCourses();
      }
      if (!mounted) return;
      final initialId = widget.courseId;
      final String? selected = (initialId != null &&
              myCourses.any((element) => element['id'] == initialId))
          ? initialId
          : (myCourses.isNotEmpty ? myCourses.first['id'] as String : null);
      setState(() {
        _allowed = allowed;
        _courses = myCourses;
        _selectedCourseId = selected;
        _checking = false;
      });
      if (_selectedCourseId != null) {
        await _loadModules();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allowed = false;
        _checking = false;
      });
    }
  }

  Future<void> _loadModules() async {
    final courseId = _selectedCourseId;
    if (courseId == null) return;
    try {
      final list = await _repo.modules(courseId);
      if (!mounted) return;
      setState(() => _modules = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _modules = <Map<String, dynamic>>[]);
      context.goSnack('Kunde inte läsa moduler: $e');
    }
  }

  String _slugify(String input) {
    final normalized = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9äöå]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .trim();
    final base = normalized.isNotEmpty ? normalized : 'kurs';
    final random = Random().nextInt(1 << 20).toRadixString(36);
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$base-$random-$ts';
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text('Kursstudio'),
      actions: const [TopNavActionButtons()],
    );
  }

  Future<void> _createCourse() async {
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    if (sb == null || user == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    final title = _newCourseTitle.text.trim();
    final desc = _newCourseDesc.text.trim();
    if (title.isEmpty) {
      context.goSnack('Titel krävs.');
      return;
    }
    try {
      final slug = _slugify(title);
      final inserted = await sb
          .schema('app')
          .from('courses')
          .insert({
            'title': title,
            'slug': slug,
            'description': desc.isEmpty ? null : desc,
            'created_by': user.id,
            'is_free_intro': false,
            'is_published': false,
            'price_cents': 0,
          })
          .select('id,title,description,created_by,created_at')
          .single();
      if (!mounted) return;
      final row = Map<String, dynamic>.from(inserted as Map);
      setState(() {
        _courses = <Map<String, dynamic>>[row, ..._courses];
        _selectedCourseId = row['id'] as String;
      });
      _newCourseTitle.clear();
      _newCourseDesc.clear();
      await _loadModules();
      context.goSnack('Kurs skapad.');
    } on PostgrestException catch (e) {
      context.goSnack('Kunde inte skapa: ${e.message}');
    } catch (e) {
      context.goSnack('Något gick fel: $e');
    }
  }

  Future<void> _pickAndUpload(String kind) async {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      context.goSnack('Supabase saknas.');
      return;
    }
    final file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[
        const XTypeGroup(label: 'Media', extensions: <String>['jpg', 'jpeg', 'png', 'mp4', 'mp3']),
      ],
    );
    if (file == null) return;

    final name = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\.-]'), '_');
    final uuid = const Uuid().v4();
    final path = 'course-media/$uuid-$name';

    try {
      final bytes = await file.readAsBytes();
      final contentType = file.mimeType ?? 'application/octet-stream';
      final url = await _repo.uploadToCourseMedia(
        path: path,
        bytes: bytes,
        contentType: contentType,
      );
      if (!mounted) return;
      setState(() => _mediaUrl = url);
      context.goSnack('Uppladdning klar. Kom ihåg att spara.');
    } catch (e) {
      if (!mounted) return;
      context.goSnack('Kunde inte ladda upp: $e');
    }
  }

  Future<void> _saveModule() async {
    if (_savingModule) return;
    final cid = _selectedCourseId;
    if (cid == null) return;
    final title = _moduleTitle.text.trim();
    final body = _moduleBody.text.trim();
    if (title.isEmpty &&
        !<String>['image', 'audio', 'video'].contains(_moduleType)) {
      context.goSnack('Titel krävs.');
      return;
    }
    if (_moduleType == 'video') {
      final error = _validateVideoUrl(body);
      if (error != null) {
        setState(() => _moduleUrlError = error);
        return;
      }
      if (_moduleUrlError != null) {
        setState(() => _moduleUrlError = null);
      }
    } else if (_moduleUrlError != null) {
      setState(() => _moduleUrlError = null);
    }

    final int lastPos = _modules.isEmpty
        ? -1
        : _modules
            .map((e) => (e['position'] ?? 0) as int)
            .fold<int>(0, (a, b) => a > b ? a : b);

    final data = {
      'course_id': cid,
      'position': lastPos + 1,
      'type': _moduleType,
      'title': title.isEmpty ? null : title,
      'body': body.isEmpty ? null : body,
      'media_url': _moduleType == 'text' ? null : _mediaUrl,
    };
    setState(() => _savingModule = true);
    try {
      await _repo.upsertModule(data);
      _moduleTitle.clear();
      _moduleBody.clear();
      _mediaUrl = null;
      await _loadModules();
      if (mounted) {
        context.goSnack('Sparat');
      }
    } catch (e) {
      if (mounted) {
        context.goSnack('Fel vid sparandet: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _savingModule = false);
      }
    }
  }

  Future<void> _deleteModule(String id) async {
    try {
      await _repo.deleteModule(id);
      await _loadModules();
    } catch (e) {
      if (!mounted) return;
      context.goSnack('Kunde inte radera modul: $e');
    }
  }

  Future<void> _ensureQuiz() async {
    final cid = _selectedCourseId;
    if (cid == null) return;
    try {
      final quiz = await _repo.ensureQuiz(cid);
      final qs = await _repo.quizQuestions(quiz['id'] as String);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _questions = qs;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      context.goSnack('Quiz stöds bara för äldre kurser: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      context.goSnack('Kunde inte ladda quiz: $e');
    }
  }

  Future<void> _addQuestion() async {
    if (_quiz == null) {
      await _ensureQuiz();
      if (_quiz == null) return;
    }
    if (!mounted) return;
    final quizId = _quiz!['id'] as String;
    final prompt = _qPrompt.text.trim();
    if (prompt.isEmpty) {
      context.goSnack('Frågetext krävs.');
      return;
    }
    final pos = _questions.isEmpty
        ? 0
        : _questions
                .map((e) => (e['position'] ?? 0) as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    dynamic options;
    dynamic correct;
    if (_qKind == 'single') {
      options = _qOptions.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      correct = int.tryParse(_qCorrect.text.trim());
      if (correct == null) {
        context.goSnack('Rätt svar: använd ett index (t.ex. 0).');
        return;
      }
    } else if (_qKind == 'multi') {
      options = _qOptions.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      correct = _qCorrect.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toList();
      if ((correct as List).isEmpty) {
        context.goSnack('Rätt svar: använd index (t.ex. 0,2).');
        return;
      }
    } else {
      final v = _qCorrect.text.trim().toLowerCase();
      if (v != 'true' && v != 'false') {
        context.goSnack('Rätt svar: true eller false.');
        return;
      }
      options = null;
      correct = v == 'true';
    }

    final data = {
      'quiz_id': quizId,
      'position': pos,
      'kind': _qKind,
      'prompt': prompt,
      'options': options,
      'correct': correct,
    };
    try {
      await _repo.upsertQuestion(data);
      _qPrompt.clear();
      _qOptions.clear();
      _qCorrect.clear();
      final qs = await _repo.quizQuestions(quizId);
      if (mounted) setState(() => _questions = qs);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      context.goSnack('Kunde inte spara quizfråga: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      context.goSnack('Fel vid quizfråga: $e');
    }
  }

  Future<void> _deleteQuestion(String id) async {
    try {
      await _repo.deleteQuestion(id);
      if (_quiz != null) {
        final qs = await _repo.quizQuestions(_quiz!['id'] as String);
        if (!mounted) return;
        setState(() => _questions = qs);
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      context.goSnack('Kunde inte ta bort fråga: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      context.goSnack('Fel vid borttagning: $e');
    }
  }

  String? _validateVideoUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Ange en videolänk (https://…)';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return 'Ogiltig URL';
    }
    final hasValidScheme =
        uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!hasValidScheme || uri.host.isEmpty) {
      return 'Ogiltig URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_allowed) {
      return _GlassScaffold(
        appBar: _buildAppBar(),
        child: const Center(child: Text('Behörighet krävs (läraråtkomst).')),
      );
    }
    return _GlassScaffold(
      appBar: _buildAppBar(),
      child: SingleChildScrollView(
        padding: p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Välj kurs',
              child: DropdownButtonFormField<String>(
                value: _selectedCourseId,
                items: _courses
                    .map((c) => DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text('${c['title']}'),
                        ))
                    .toList(),
                onChanged: (value) async {
                  setState(() => _selectedCourseId = value);
                  await _loadModules();
                  if (!mounted) return;
                  setState(() {
                    _quiz = null;
                    _questions = <Map<String, dynamic>>[];
                  });
                },
                decoration: const InputDecoration(hintText: 'Välj kurs'),
              ),
            ),
            gap12,
            _SectionCard(
              title: 'Skapa ny kurs',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCourseTitle,
                          decoration: const InputDecoration(labelText: 'Titel'),
                        ),
                      ),
                      gap12,
                      Expanded(
                        child: TextField(
                          controller: _newCourseDesc,
                          decoration: const InputDecoration(labelText: 'Beskrivning (valfri)'),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  gap12,
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _createCourse,
                      child: const Text('Skapa kurs'),
                    ),
                  ),
                ],
              ),
            ),
            gap16,
            _SectionCard(
              title: 'Lägg modul',
              child: Builder(
                builder: (context) {
                  final bool isVideoInvalid = _moduleType == 'video' &&
                      (_moduleBody.text.trim().isEmpty || _moduleUrlError != null);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final t in <String>['text', 'video', 'audio', 'image', 'quiz'])
                            ChoiceChip(
                              label: Text(t.toUpperCase()),
                              selected: _moduleType == t,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _moduleType = t;
                                    _moduleUrlError = null;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                      gap12,
                      TextField(
                        controller: _moduleTitle,
                        decoration: const InputDecoration(labelText: 'Titel'),
                      ),
                      gap8,
                      if (_moduleType == 'text') ...[
                        TextField(
                          controller: _moduleBody,
                          maxLines: 5,
                          decoration: const InputDecoration(labelText: 'Textinnehåll'),
                        ),
                      ] else if (_moduleType == 'video') ...[
                        TextField(
                          controller: _moduleBody,
                          decoration: InputDecoration(
                            labelText: 'Video URL',
                            errorText: _moduleUrlError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _moduleUrlError = _validateVideoUrl(value);
                            });
                          },
                        ),
                      ] else if (_moduleType == 'audio' || _moduleType == 'image') ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _mediaUrl ?? 'Ingen fil vald',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            gap8,
                            OutlinedButton.icon(
                              onPressed: () => _pickAndUpload(_moduleType),
                              icon: const Icon(Icons.upload),
                              label: const Text('Ladda upp'),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text('Denna modul markerar en Quiz-sektion. Lägg frågor nedan.'),
                      ],
                      gap12,
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _selectedCourseId == null || _savingModule || isVideoInvalid
                              ? null
                              : _saveModule,
                         child: _savingModule
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Sparar...'),
                                  ],
                                )
                              : const Text('Spara modul'),
                        ),
                      ),
                      const Divider(height: 24),
                      const Text('Moduler'),
                      gap8,
                      if (_modules.isEmpty)
                        const Text('Inga moduler ännu.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _modules.length,
                          separatorBuilder: (_, __) => gap6,
                          itemBuilder: (context, index) {
                            final m = _modules[index];
                            final type = (m['type'] ?? '') as String;
                            IconData icon;
                            switch (type) {
                              case 'text':
                                icon = Icons.notes;
                                break;
                              case 'video':
                                icon = Icons.play_circle_outline;
                                break;
                              case 'audio':
                                icon = Icons.audiotrack;
                                break;
                              case 'image':
                                icon = Icons.image_outlined;
                                break;
                              case 'quiz':
                                icon = Icons.quiz_outlined;
                                break;
                              default:
                                icon = Icons.extension_outlined;
                            }
                            return ListTile(
                              leading: Icon(icon),
                              title: Text('${m['title'] ?? type.toUpperCase()}'),
                              subtitle: Text('Pos ${m['position']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteModule(m['id'] as String),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            gap16,
            _SectionCard(
              title: 'Quiz',
              actions: [
                OutlinedButton.icon(
                  onPressed: _selectedCourseId == null ? null : _ensureQuiz,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Skapa/Hämta quiz'),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_quiz == null) const Text('Inget quiz laddat.'),
                  if (_quiz != null) ...[
                    Text('Quiz: ${_quiz!['title']} (gräns: ${_quiz!['pass_score']}%)'),
                    gap12,
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final kind in <String>['single', 'multi', 'boolean'])
                          ChoiceChip(
                            label: Text(kind),
                            selected: _qKind == kind,
                            onSelected: (selected) =>
                                setState(() => _qKind = selected ? kind : _qKind),
                          ),
                      ],
                    ),
                    gap8,
                    TextField(
                      controller: _qPrompt,
                      decoration: const InputDecoration(labelText: 'Frågetext'),
                    ),
                    if (_qKind != 'boolean') ...[
                      gap8,
                      TextField(
                        controller: _qOptions,
                        decoration: const InputDecoration(labelText: 'Alternativ (komma-separerade)'),
                      ),
                      gap8,
                      TextField(
                        controller: _qCorrect,
                        decoration: const InputDecoration(
                          labelText: 'Rätt svar (index eller index, index)',
                        ),
                      ),
                    ] else ...[
                      gap8,
                      TextField(
                        controller: _qCorrect,
                        decoration: const InputDecoration(labelText: 'Rätt svar (true/false)'),
                      ),
                    ],
                    gap10,
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _addQuestion,
                        child: const Text('Lägg till fråga'),
                      ),
                    ),
                    const Divider(height: 24),
                    const Text('Frågor'),
                    gap6,
                    if (_questions.isEmpty)
                      const Text('Inga frågor ännu.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        separatorBuilder: (_, __) => gap6,
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: Text('${q['prompt']}'),
                            subtitle: Text('Typ: ${q['kind']} • Pos: ${q['position']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteQuestion(q['id'] as String),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  const _GlassScaffold({required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const _SectionCard({required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: p16,
      borderRadius: BorderRadius.circular(20),
      opacity: 0.18,
      borderColor: Colors.white.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
          gap12,
          child,
        ],
      ),
    );
  }
}
