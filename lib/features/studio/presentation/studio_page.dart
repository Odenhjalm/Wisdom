import 'package:flutter/material.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';
import 'package:visdom/data/repositories/profile_repository.dart';
import 'package:visdom/data/models/profile.dart';
import 'package:visdom/data/supabase/supabase_client.dart';
import 'package:visdom/core/supabase_ext.dart';
import 'package:visdom/features/studio/data/studio_repository.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'package:visdom/shared/widgets/hero_background.dart';
import 'package:visdom/features/studio/data/certificates_repository.dart';
import 'package:visdom/domain/services/auth_service.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/glass_card.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final _repo = ProfileRepository();
  Profile? _me;
  bool _loading = true;
  bool _sending = false;
  int _verifiedCerts = 0;
  bool _hasTeacherAccess = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    bool teacherAccess = false;
    try {
      final p = await _repo.getMe();
      // verified certs for gating
      final certs =
          await CertificatesRepository().myCertificates(verifiedOnly: true);
      teacherAccess = await AuthService().isTeacher();
      if (!mounted) return;
      setState(() {
        _me = p;
        _verifiedCerts = certs.length;
        _hasTeacherAccess = teacherAccess;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasTeacherAccess = teacherAccess;
        _loading = false;
      });
    }
  }

  Future<void> _applyAsTeacher() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    setState(() => _sending = true);
    try {
      await Supa.client.app.from('teacher_requests').upsert({
        'user_id': u.id,
        'message': 'Jag vill bli lärare. (ansökan från app)'
      });
      if (!mounted) return;
      showSnack(context, 'Ansökan inskickad. Tack!');
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte skicka: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Studio',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final u = Supa.client.auth.currentUser;
    if (u == null) {
      return const AppScaffold(
        title: 'Studio',
        body: Center(child: Text('Logga in för att fortsätta.')),
      );
    }

    final role = _me?.role ?? 'user';
    final isTeacher = _hasTeacherAccess || role == 'teacher' || role == 'admin';
    if (isTeacher) {
      return const _StudioShell();
    }

    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: 'Studio',
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      background: const HeroBackground(
        asset: 'assets/images/bakgrund.png',
        alignment: Alignment.topCenter,
        opacity: 0.72,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ansök som lärare',
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  _verifiedCerts > 0
                      ? 'För att få tillgång till Studio behöver du bli godkänd lärare. Skicka in en ansökan så återkommer vi.'
                      : 'Du behöver minst ett verifierat certifikat för att kunna ansöka som lärare. Lägg till certifikat på din profil och invänta verifiering, därefter kan du skicka ansökan.',
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: (_sending || _verifiedCerts == 0)
                      ? null
                      : _applyAsTeacher,
                  child: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_verifiedCerts == 0
                          ? 'Certifikat krävs'
                          : 'Ansök som lärare'),
                ),
                if (_verifiedCerts == 0) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile'),
                    child: const Text(
                        'Gå till profil för att lägga till certifikat'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioShell extends StatefulWidget {
  const _StudioShell();
  @override
  State<_StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<_StudioShell> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const _MyCoursesPage(),
      const _ModulesLessonsPage(),
      const _MediaPage(),
      const _TeacherSettingsPage(),
    ];
    return AppScaffold(
      title: 'Studio',
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      background: const HeroBackground(
        asset: 'assets/images/bakgrund.png',
        alignment: Alignment.topCenter,
        opacity: 0.78,
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    label: Text('Mina kurser'),
                    icon: Icon(Icons.menu_book_rounded)),
                ButtonSegment(
                    value: 1,
                    label: Text('Moduler & Lektioner'),
                    icon: Icon(Icons.view_list_rounded)),
                ButtonSegment(
                    value: 2,
                    label: Text('Media'),
                    icon: Icon(Icons.perm_media_rounded)),
                ButtonSegment(
                    value: 3,
                    label: Text('Inställningar'),
                    icon: Icon(Icons.settings_rounded)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
            const SizedBox(height: 12),
            Expanded(child: pages[_tab]),
          ],
        ),
      ),
    );
  }
}

class _MyCoursesPage extends StatefulWidget {
  const _MyCoursesPage();
  @override
  State<_MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<_MyCoursesPage> {
  final _svc = StudioRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _svc.myCourses();
    if (!mounted) return;
    setState(() {
      _items = rows;
      _loading = false;
    });
  }

  Future<void> _openEditor({Map<String, dynamic>? course}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _CourseEditorDialog(initial: course),
    );
    if (res == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ny kurs'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          const Center(child: Text('Inga kurser ännu. Skapa din första.'))
        else
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = _items[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      c['is_published'] == true
                          ? Icons.public_rounded
                          : Icons.lock_clock_rounded,
                    ),
                    title: Text(c['title'] ?? 'Untitled',
                        style: t.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle: Text(c['slug'] ?? ''),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          tooltip: 'Redigera',
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () => _openEditor(course: c),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CourseEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const _CourseEditorDialog({this.initial});
  @override
  State<_CourseEditorDialog> createState() => _CourseEditorDialogState();
}

class _CourseEditorDialogState extends State<_CourseEditorDialog> {
  final _svc = StudioRepository();
  final _title = TextEditingController();
  final _slug = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController(text: '0');
  bool _freeIntro = false;
  bool _published = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    if (c != null) {
      _title.text = c['title'] ?? '';
      _slug.text = c['slug'] ?? '';
      _desc.text = c['description'] ?? '';
      _price.text = (c['price_cents']?.toString() ?? '0');
      _freeIntro = c['is_free_intro'] == true;
      _published = c['is_published'] == true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  String _slugify(String s) {
    final a = s.trim().toLowerCase();
    final b = a.replaceAll(RegExp(r'[^a-z0-9åäö\s-]'), '');
    return b.replaceAll(RegExp(r'[\s_]+'), '-');
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    String slug = _slug.text.trim();
    if (title.isEmpty) return;
    if (slug.isEmpty) slug = _slugify(title);
    final price = int.tryParse(_price.text.trim()) ?? 0;

    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await _svc.createCourse(
          title: title,
          slug: slug,
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          priceCents: price,
          isFreeIntro: _freeIntro,
        );
      } else {
        await _svc.updateCourse(widget.initial!['id'] as String, {
          'title': title,
          'slug': slug,
          'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          'price_cents': price,
          'is_free_intro': _freeIntro,
          'is_published': _published,
        });
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte spara: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Ny kurs' : 'Redigera kurs'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Titel')),
              const SizedBox(height: 8),
              TextField(
                  controller: _slug,
                  decoration: const InputDecoration(labelText: 'Slug')),
              const SizedBox(height: 8),
              TextField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Beskrivning'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Pris (öre)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _freeIntro,
                onChanged: (v) => setState(() => _freeIntro = v),
                title: const Text('Intro-kurs (gratis förhandsvisning)'),
              ),
              if (widget.initial != null)
                SwitchListTile(
                  value: _published,
                  onChanged: (v) => setState(() => _published = v),
                  title: const Text('Publicerad'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Avbryt')),
        ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Sparar…' : 'Spara')),
      ],
    );
  }
}

class _TeacherSettingsPage extends StatefulWidget {
  const _TeacherSettingsPage();
  @override
  State<_TeacherSettingsPage> createState() => _TeacherSettingsPageState();
}

class _TeacherSettingsPageState extends State<_TeacherSettingsPage> {
  final _headline = TextEditingController();
  final _specialties = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = Supa.client.auth.currentUser;
    if (u != null) {
      final res = await Supa.client.app
          .from('teacher_directory')
          .select('headline, specialties')
          .eq('user_id', u.id)
          .maybeSingle();
      final row = (res as Map?)?.cast<String, dynamic>();
      if (row != null) {
        _headline.text = (row['headline'] as String?) ?? '';
        final specs = (row['specialties'] as List?)?.cast<String>() ?? [];
        _specialties.text = specs.join(', ');
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    setState(() => _saving = true);
    try {
      final specs = _specialties.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await Supa.client.app.from('teacher_directory').upsert({
        'user_id': u.id,
        'headline':
            _headline.text.trim().isEmpty ? null : _headline.text.trim(),
        'specialties': specs.isEmpty ? null : specs,
      });
      if (!mounted) return;
      showSnack(context, 'Inställningar sparade.');
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte spara: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _headline.dispose();
    _specialties.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _headline,
                decoration:
                    const InputDecoration(labelText: 'Rubrik (headline)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _specialties,
                decoration: const InputDecoration(
                  labelText: 'Specialiteter (komma-separerade)',
                  hintText: 'tarot, ritual, meditation',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Sparar…' : 'Spara'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModulesLessonsPage extends StatefulWidget {
  const _ModulesLessonsPage();
  @override
  State<_ModulesLessonsPage> createState() => _ModulesLessonsPageState();
}

class _ModulesLessonsPageState extends State<_ModulesLessonsPage> {
  final _svc = StudioRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  List<Map<String, dynamic>> _modules = [];
  final Map<String, List<Map<String, dynamic>>> _lessonsByModule = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loading = true);
    final rows = await _svc.myCourses();
    String? pick = _selectedCourseId;
    if (rows.isNotEmpty &&
        (pick == null || !rows.any((c) => c['id'] == pick))) {
      pick = rows.first['id'] as String;
    }
    if (!mounted) return;
    setState(() {
      _courses = rows;
      _selectedCourseId = pick;
      _loading = false;
    });
    if (pick != null) await _loadModules(pick);
  }

  Future<void> _loadModules(String courseId) async {
    setState(() => _loading = true);
    final mods = await _svc.listModules(courseId);
    final lessonsMap = <String, List<Map<String, dynamic>>>{};
    for (final m in mods) {
      final ls = await _svc.listLessons(m['id'] as String);
      lessonsMap[m['id'] as String] = ls;
    }
    if (!mounted) return;
    setState(() {
      _modules = mods;
      _lessonsByModule
        ..clear()
        ..addAll(lessonsMap);
      _loading = false;
    });
  }

  Future<void> _addOrEditModule({Map<String, dynamic>? module}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _ModuleEditorDialog(
        courseId: _selectedCourseId!,
        initial: module,
      ),
    );
    if (res == true && _selectedCourseId != null) {
      if (!mounted) return;
      await _loadModules(_selectedCourseId!);
    }
  }

  Future<void> _deleteModule(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ta bort modul?'),
        content: const Text('Detta tar även bort dess lektioner.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Avbryt')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ta bort')),
        ],
      ),
    );
    if (ok == true) {
      await _svc.deleteModule(id);
      if (!mounted) return;
      if (_selectedCourseId != null) await _loadModules(_selectedCourseId!);
    }
  }

  Future<void> _addOrEditLesson(
      {required String moduleId, Map<String, dynamic>? lesson}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _LessonEditorDialog(moduleId: moduleId, initial: lesson),
    );
    if (res == true && _selectedCourseId != null) {
      if (!mounted) return;
      await _loadModules(_selectedCourseId!);
    }
  }

  Future<void> _deleteLesson(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ta bort lektion?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Avbryt')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ta bort')),
        ],
      ),
    );
    if (ok == true && _selectedCourseId != null) {
      await _svc.deleteLesson(id);
      if (!mounted) return;
      await _loadModules(_selectedCourseId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_selectedCourseId == null || _courses.isEmpty) {
      return const Center(
          child: Text('Skapa en kurs under "Mina kurser" först.'));
    }
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Kurs: '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedCourseId,
            items: _courses
                .map((c) => DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['title'] as String? ?? 'Untitled'),
                    ))
                .toList(),
            onChanged: (v) async {
              if (v == null) return;
              setState(() => _selectedCourseId = v);
              await _loadModules(v);
            },
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _addOrEditModule(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ny modul'),
          ),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _modules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = _modules[i];
              final lessons = _lessonsByModule[m['id']] ?? const [];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m['title'] as String? ?? 'Modul',
                              style: t.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Redigera',
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () => _addOrEditModule(module: m),
                          ),
                          IconButton(
                            tooltip: 'Ta bort',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () => _deleteModule(m['id'] as String),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _addOrEditLesson(moduleId: m['id'] as String),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Ny lektion'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (lessons.isEmpty)
                        const Text('Inga lektioner')
                      else
                        ...lessons.map((l) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.menu_book_outlined),
                              title: Text(l['title'] as String? ?? 'Lektion'),
                              subtitle: Text(
                                  'Pos ${l['position'] ?? 0}${(l['is_intro'] == true) ? ' • Intro' : ''}'),
                              trailing: Wrap(spacing: 8, children: [
                                IconButton(
                                  tooltip: 'Redigera',
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () => _addOrEditLesson(
                                      moduleId: m['id'] as String, lesson: l),
                                ),
                                IconButton(
                                  tooltip: 'Ta bort',
                                  icon:
                                      const Icon(Icons.delete_outline_rounded),
                                  onPressed: () =>
                                      _deleteLesson(l['id'] as String),
                                ),
                              ]),
                            )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModuleEditorDialog extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic>? initial;
  const _ModuleEditorDialog({required this.courseId, this.initial});
  @override
  State<_ModuleEditorDialog> createState() => _ModuleEditorDialogState();
}

class _ModuleEditorDialogState extends State<_ModuleEditorDialog> {
  final _svc = StudioRepository();
  final _title = TextEditingController();
  final _position = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    if (m != null) {
      _title.text = m['title'] ?? '';
      _position.text = (m['position']?.toString() ?? '0');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final pos = int.tryParse(_position.text.trim()) ?? 0;
    if (title.isEmpty) return;
    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await _svc.createModule(
            courseId: widget.courseId, title: title, position: pos);
      } else {
        await _svc.updateModule(widget.initial!['id'] as String, {
          'title': title,
          'position': pos,
        });
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte spara: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Ny modul' : 'Redigera modul'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Titel')),
            const SizedBox(height: 8),
            TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Position'),
                keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Avbryt')),
        ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Sparar…' : 'Spara')),
      ],
    );
  }
}

class _LessonEditorDialog extends StatefulWidget {
  final String moduleId;
  final Map<String, dynamic>? initial;
  const _LessonEditorDialog({required this.moduleId, this.initial});
  @override
  State<_LessonEditorDialog> createState() => _LessonEditorDialogState();
}

class _LessonEditorDialogState extends State<_LessonEditorDialog> {
  final _svc = StudioRepository();
  final _title = TextEditingController();
  final _position = TextEditingController(text: '0');
  final _content = TextEditingController();
  bool _isIntro = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final l = widget.initial;
    if (l != null) {
      _title.text = l['title'] ?? '';
      _position.text = (l['position']?.toString() ?? '0');
      _isIntro = l['is_intro'] == true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _position.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final pos = int.tryParse(_position.text.trim()) ?? 0;
    setState(() => _saving = true);
    try {
      await _svc.upsertLesson(
        id: widget.initial?['id'] as String?,
        moduleId: widget.moduleId,
        title: title,
        contentMarkdown: _content.text.trim().isEmpty ? null : _content.text,
        position: pos,
        isIntro: _isIntro,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte spara: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Ny lektion' : 'Redigera lektion'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Titel')),
              const SizedBox(height: 8),
              TextField(
                  controller: _position,
                  decoration: const InputDecoration(labelText: 'Position'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              SwitchListTile(
                  value: _isIntro,
                  onChanged: (v) => setState(() => _isIntro = v),
                  title: const Text('Intro (förhandsvisning)')),
              const SizedBox(height: 8),
              TextField(
                controller: _content,
                decoration:
                    const InputDecoration(labelText: 'Innehåll (Markdown)'),
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Avbryt')),
        ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Sparar…' : 'Spara')),
      ],
    );
  }
}

class _MediaPage extends StatefulWidget {
  const _MediaPage();
  @override
  State<_MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<_MediaPage> {
  final _svc = StudioRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _courses = [];
  String? _courseId;
  List<Map<String, dynamic>> _modules = [];
  String? _moduleId;
  List<Map<String, dynamic>> _lessons = [];
  String? _lessonId;
  List<Map<String, dynamic>> _media = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loading = true);
    final cs = await _svc.myCourses();
    if (!mounted) return;
    setState(() {
      _courses = cs;
      _courseId = cs.isNotEmpty ? (cs.first['id'] as String) : null;
    });
    if (_courseId != null) await _loadModules(_courseId!);
  }

  Future<void> _loadModules(String courseId) async {
    setState(() => _loading = true);
    final ms = await _svc.listModules(courseId);
    if (!mounted) return;
    setState(() {
      _modules = ms;
      _moduleId = ms.isNotEmpty ? (ms.first['id'] as String) : null;
    });
    if (_moduleId != null) await _loadLessons(_moduleId!);
  }

  Future<void> _loadLessons(String moduleId) async {
    setState(() => _loading = true);
    final ls = await _svc.listLessons(moduleId);
    if (!mounted) return;
    setState(() {
      _lessons = ls;
      _lessonId = ls.isNotEmpty ? (ls.first['id'] as String) : null;
    });
    if (_lessonId != null) await _loadMedia(_lessonId!);
  }

  Future<void> _loadMedia(String lessonId) async {
    setState(() => _loading = true);
    final mm = await _svc.listLessonMedia(lessonId);
    if (!mounted) return;
    setState(() {
      _media = mm;
      _loading = false;
    });
  }

  Future<void> _pickAndUpload() async {
    if (_lessonId == null) return;
    // Use file_selector to pick a file
    try {
      const typeGroup = fs.XTypeGroup(label: 'media', extensions: <String>[
        'png',
        'jpg',
        'jpeg',
        'gif',
        'mp4',
        'mov',
        'mp3',
        'wav',
        'pdf'
      ]);
      final xfile = await fs.openFile(acceptedTypeGroups: [typeGroup]);
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      final name = xfile.name;
      final ct = _guessContentType(name);
      await _svc.uploadLessonMedia(
        lessonId: _lessonId!,
        data: bytes,
        filename: name,
        contentType: ct,
      );
      await _loadMedia(_lessonId!);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Uppladdning misslyckades: $e');
    }
  }

  String _guessContentType(String name) {
    final ext = name.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  String _publicUrl(String storagePath) {
    return Supa.client.storage.from('media').getPublicUrl(storagePath);
  }

  Future<void> _deleteMedia(String id) async {
    await _svc.deleteLessonMedia(id);
    if (!mounted) return;
    if (_lessonId != null) await _loadMedia(_lessonId!);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_courses.isEmpty) {
      return const Center(child: Text('Skapa en kurs först.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text('Kurs:'),
            DropdownButton<String>(
              value: _courseId,
              items: _courses
                  .map((c) => DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['title'] as String? ?? 'Untitled')))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _courseId = v);
                await _loadModules(v);
              },
            ),
            const Text('Modul:'),
            DropdownButton<String>(
              value: _moduleId,
              items: _modules
                  .map((m) => DropdownMenuItem(
                      value: m['id'] as String,
                      child: Text(m['title'] as String? ?? 'Modul')))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _moduleId = v);
                await _loadLessons(v);
              },
            ),
            const Text('Lektion:'),
            DropdownButton<String>(
              value: _lessonId,
              items: _lessons
                  .map((l) => DropdownMenuItem(
                      value: l['id'] as String,
                      child: Text(l['title'] as String? ?? 'Lektion')))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _lessonId = v);
                await _loadMedia(v);
              },
            ),
            ElevatedButton.icon(
              onPressed: (_lessonId == null) ? null : _pickAndUpload,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Ladda upp media'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _lessonId == null
              ? const Center(child: Text('Välj en lektion'))
              : ListView.separated(
                  itemCount: _media.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final m = _media[i];
                    final url = _publicUrl(m['storage_path'] as String);
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.perm_media_rounded),
                        title: Text(m['kind'] as String? ?? 'media'),
                        subtitle: Text(url,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          tooltip: 'Ta bort',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _deleteMedia(m['id'] as String),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
