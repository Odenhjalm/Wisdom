import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/community_service.dart';
import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/data/course_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/data/certificates_service.dart';
import 'package:andlig_app/data/models/certificate.dart';

class TeacherProfilePage extends StatefulWidget {
  final String userId;
  const TeacherProfilePage({super.key, required this.userId});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  final _svc = CommunityService();
  final _orders = CourseService();
  bool _loading = true;
  Map<String, dynamic>? _teacher;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _meditations = [];
  List<Certificate> _certs = [];
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await _svc.getTeacher(widget.userId);
    final svcs = await _svc.listServices(widget.userId);
    final med = await _svc.listMeditations(widget.userId);
    final certs = await CertificatesService().certificatesOf(widget.userId);
    if (!mounted) return;
    setState(() {
      _teacher = t;
      _services = svcs;
      _meditations = med;
      _certs = certs;
      _loading = false;
    });
  }

  Future<void> _buyService(Map<String, dynamic> s) async {
    final id = s['id'] as String?;
    final price = (s['price_cents'] as int?) ?? 0;
    if (id == null || price <= 0) return;
    setState(() => _buying = true);
    try {
      final order =
          await _svc.startServiceOrder(serviceId: id, amountCents: price);
      final url = await _orders.createCheckoutSession(
        orderId: order['id'] as String,
        amountCents: price,
        successUrl:
            'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
      );
      if (url != null) await launchUrlString(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kunde inte initiera köp: $e')));
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  String _publicUrl(String path) =>
      Supa.client.storage.from('media').getPublicUrl(path);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_loading) {
      return const AppScaffold(
          title: 'Lärare', body: Center(child: CircularProgressIndicator()));
    }
    final prof = (_teacher?['profile'] as Map?)?.cast<String, dynamic>();
    final display = prof?['display_name'] as String? ?? 'Lärare';
    final headline = (_teacher?['headline'] as String?) ?? '';

    return AppScaffold(
      title: display,
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: Text(display,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              subtitle: Text(headline),
              trailing: OutlinedButton(
                onPressed: () => context.push('/messages/dm/${widget.userId}'),
                child: const Text('Meddelande'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Certifikat',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (_certs.isEmpty)
                    const Text('Inga certifikat publicerade ännu.')
                  else
                    ..._certs.map((c) => ListTile(
                          leading: const Icon(Icons.verified_rounded,
                              color: Colors.lightGreen),
                          title: Text(c.title),
                          subtitle: Text([
                            if ((c.issuer ?? '').isNotEmpty) c.issuer,
                            if (c.issuedAt != null)
                              'Utfärdat: ${c.issuedAt!.toLocal().toString().split(' ').first}',
                          ].whereType<String>().join(' • ')),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tjänster',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (_services.isEmpty)
                    const Text('Inga tjänster ännu.')
                  else ...[
                    ..._services.map((s) => ListTile(
                          leading: const Icon(Icons.work_rounded),
                          title: Text(s['title'] as String? ?? 'Tjänst'),
                          subtitle: Text(s['description'] as String? ?? ''),
                          trailing: ElevatedButton(
                            onPressed: _buying ? null : () => _buyService(s),
                            child: _buying
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Text(
                                    'Boka/köp ${(s['price_cents'] ?? 0) / 100} kr'),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meditationer',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (_meditations.isEmpty)
                    const Text('Inga meditationer ännu.')
                  else ...[
                    ..._meditations.map((m) => _MeditationTile(
                          title: m['title'] as String? ?? 'Meditation',
                          description: m['description'] as String? ?? '',
                          url: _publicUrl(m['audio_path'] as String),
                          durationSeconds: (m['duration_seconds'] as int?) ?? 0,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationTile extends StatefulWidget {
  final String title;
  final String description;
  final String url;
  final int durationSeconds;
  const _MeditationTile(
      {required this.title,
      required this.description,
      required this.url,
      required this.durationSeconds});

  @override
  State<_MeditationTile> createState() => _MeditationTileState();
}

class _MeditationTileState extends State<_MeditationTile> {
  late final AudioPlayer _player;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  PlayerState _state = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onDurationChanged.listen((d) => setState(() => _dur = d));
    _player.onPositionChanged.listen((p) => setState(() => _pos = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => _state = s));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final total = _dur.inMilliseconds > 0
        ? _dur
        : Duration(seconds: widget.durationSeconds);
    final progress = total.inMilliseconds > 0
        ? _pos.inMilliseconds / total.inMilliseconds
        : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (widget.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(widget.description, style: t.bodySmall),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(_state == PlayerState.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  onPressed: _toggle,
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_fmt(_pos)),
                const Text(' / '),
                Text(_fmt(total)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
