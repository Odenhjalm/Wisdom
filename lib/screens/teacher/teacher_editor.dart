import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/top_nav_action_buttons.dart';
import '../../domain/services/auth_service.dart';
import '../../supabase_client.dart';
import '../../core/widgets/glass_card.dart';
import '../../ui/widgets/go_router_back_button.dart';

class TeacherEditorPage extends ConsumerStatefulWidget {
  const TeacherEditorPage({super.key});

  @override
  ConsumerState<TeacherEditorPage> createState() => _TeacherEditorPageState();
}

class _TeacherEditorPageState extends ConsumerState<TeacherEditorPage> {
  bool _loading = true;
  bool _allowed = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  bool _isFreeIntro = false;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _videoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final supabase = ref.read(supabaseMaybeProvider);
      final user = supabase?.auth.currentUser;
      if (supabase == null || user == null) {
        setState(() {
          _allowed = false;
          _courses = const [];
          _loading = false;
        });
        return;
      }

      final allowed = await AuthService(client: supabase).isTeacher();

      List<Map<String, dynamic>> myCourses = [];
      if (allowed) {
        final res = await supabase
            .schema('app')
            .from('courses')
            .select(
                'id,title,description,video_url,is_free_intro,is_published,price_cents,slug,updated_at')
            .eq('created_by', user.id)
            .order('updated_at', ascending: false);
        myCourses = (res as List).cast<Map<String, dynamic>>();
      }

      if (!mounted) return;
      setState(() {
        _allowed = allowed;
        _courses = myCourses;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allowed = false;
        _courses = const [];
        _loading = false;
      });
    }
  }

  Future<void> _createCourse() async {
    final supabase = ref.read(supabaseMaybeProvider);
    final user = supabase?.auth.currentUser;
    if (supabase == null || user == null || !_allowed) return;

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final videoUrl = _videoUrlCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('Titel krävs.');
      return;
    }

    try {
      final slug = _slugify(title);
      await supabase.schema('app').from('courses').insert({
        'title': title,
        'description': desc.isEmpty ? null : desc,
        'slug': slug,
        'created_by': user.id,
        'is_free_intro': _isFreeIntro,
        'is_published': false,
        'price_cents': 0,
        'video_url': videoUrl.isEmpty ? null : videoUrl,
      });
      _titleCtrl.clear();
      _descCtrl.clear();
      _videoUrlCtrl.clear();
      setState(() => _isFreeIntro = false);
      await _bootstrap();
      _showSnack('Kurs skapad.');
    } on PostgrestException catch (e) {
      _showSnack('Fel: ${e.message}', isError: true);
    }
  }

  Future<void> _deleteCourse(String id) async {
    final supabase = ref.read(supabaseMaybeProvider);
    if (supabase == null || !_allowed) return;
    try {
      await supabase.schema('app').from('courses').delete().eq('id', id);
      await _bootstrap();
      _showSnack('Kurs raderad.');
    } on PostgrestException catch (e) {
      _showSnack('Fel: ${e.message}', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const GoRouterBackButton(),
        title: const Text('Kurs-editor'),
        actions: const [TopNavActionButtons()],
      ),
      body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : !_allowed
                  ? const Center(
                      child: Text('Åtkomst nekad – lärarbehörighet krävs.'),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Skapa ny kurs',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _titleCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Titel',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _descCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Beskrivning (valfri)',
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _videoUrlCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Video URL (valfri)',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SwitchListTile.adaptive(
                                  value: _isFreeIntro,
                                  onChanged: (v) =>
                                      setState(() => _isFreeIntro = v),
                                  title: const Text('Gratis introduktion'),
                                  subtitle: const Text(
                                    'Markerade kurser visas för alla utan betalning.',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: _createCourse,
                                    child: const Text('Skapa kurs'),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text('Mina kurser',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _courses.isEmpty
                                      ? const Center(
                                          child: Text('Inga kurser ännu.'),
                                        )
                                      : ListView.separated(
                                          itemCount: _courses.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (context, i) {
                                            final c = _courses[i];
                                            final chips = <Widget>[];
                                            if (c['is_free_intro'] == true) {
                                              chips.add(const Chip(
                                                label: Text('Gratis intro'),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ));
                                            }
                                            if (c['is_published'] == true) {
                                              chips.add(const Chip(
                                                label: Text('Publicerad'),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ));
                                            }
                                            return ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              tileColor: Colors.grey.shade50,
                                              title:
                                                  Text('${c['title'] ?? ''}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if ((c['description'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Text(
                                                      '${c['description']}',
                                                    ),
                                                  if ((c['video_url'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text(
                                                        'Video: ${c['video_url']}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 4,
                                                    children: [
                                                      ...chips,
                                                      Text(
                                                        'Slug: ${c['slug']}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                      Text(
                                                        'Pris: ${(c['price_cents'] ?? 0) ~/ 100} kr',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () => _deleteCourse(
                                                  c['id'] as String,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
      ),
    );
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
