import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/course_service.dart';
import 'package:andlig_app/data/progress_service.dart';
import 'package:andlig_app/data/auth_profile_service.dart';
import 'package:andlig_app/ui/widgets/home_hero_panel.dart';
import 'package:andlig_app/data/community/posts_service.dart';
import 'package:andlig_app/ui/widgets/courses_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _svc = CourseService();
  final _posts = PostsService();
  bool _loading = true;
  List<Map<String, dynamic>> _myCourses = [];
  Map<String, double> _progress = const {};
  String? _displayName;
  List<Map<String, dynamic>> _feed = [];
  final _composer = TextEditingController();
  bool _posting = false;
  RealtimeChannel? _postsChan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _svc.myEnrolledCourses();
      // progress
      final ids = rows
          .map((e) => (e['id'] as String?) ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      // ignore: use_build_context_synchronously
      final progressSvc = ProgressService();
      final progress = await progressSvc.getProgressForCourses(ids);
      // profile name (optional)
      final prof = await AuthProfileService().getMyProfile();
      if (!mounted) return;
      final feed = await _posts.feed(limit: 20);
      setState(() {
        _myCourses = rows;
        _progress = progress;
        _displayName =
            (prof?['display_name'] as String?) ?? (prof?['email'] as String?);
        _feed = feed;
        _loading = false;
      });
      _subscribePosts();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _subscribePosts() {
    _postsChan?.unsubscribe();
    final sb = Supabase.instance.client;
    _postsChan = sb
        .channel('posts-feed')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'app',
          table: 'posts',
          callback: (payload) async {
            try {
              final feed = await _posts.feed(limit: 20);
              if (!mounted) return;
              setState(() => _feed = feed);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _composer.dispose();
    if (_postsChan != null) {
      Supabase.instance.client.removeChannel(_postsChan!);
    }
    super.dispose();
  }

  Future<void> _createPost() async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await _posts.create(content: text);
      _composer.clear();
      final feed = await _posts.feed(limit: 20);
      if (!mounted) return;
      setState(() => _feed = feed);
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Andlig Väg',
      disableBack: true,
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      appBarForegroundColor: Colors.white,
      background: const FullBleedBackground(
        image: AssetImage('assets/images/bakgrund.png'),
        alignment: Alignment.topCenter,
        topOpacity: 0.35,
        bottomOpacity: 0.55,
        child: SizedBox.shrink(),
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
      body: ListView(
        children: [
          // Composer + feed (lätt vikt)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dela något i communityt',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _composer,
                    minLines: 2,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(hintText: 'Skriv ett inlägg...'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _posting ? null : _createPost,
                      child: _posting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Publicera'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_feed.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nyligen i communityt',
                        style: t.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ..._feed.map((p) => ListTile(
                          leading: const Icon(Icons.person_rounded),
                          title: Text(
                              (p['profile']?['display_name'] as String?) ??
                                  'Användare'),
                          subtitle: Text(p['content'] as String? ?? ''),
                        )),
                  ],
                ),
              ),
            ),
          HomeHeroPanel(displayName: _displayName),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Välkommen hem.',
                      style: t.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                      'Utforska introduktionskurser (gratis förhandsvisningar).',
                      style: t.bodyLarge),
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
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Bli certifierad och lås upp communityt'),
              subtitle:
                  const Text('Publicera ceremonier, sessioner och läsningar.'),
              trailing: ElevatedButton(
                onPressed: () => context.push('/course/intro'),
                child: const Text('Läs mer'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mina kurser',
                      style:
                          t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (_loading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator()))
                  else if (_myCourses.isEmpty)
                    Text('Du är ännu inte anmäld till någon kurs.',
                        style: t.bodyMedium)
                  else
                    CoursesGrid(courses: _myCourses, progress: _progress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
