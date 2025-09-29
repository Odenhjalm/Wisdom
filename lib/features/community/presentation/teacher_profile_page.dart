import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/data/supabase/supabase_client.dart';
import 'package:wisdom/domain/services/payments/payments_service.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class TeacherProfilePage extends ConsumerStatefulWidget {
  const TeacherProfilePage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends ConsumerState<TeacherProfilePage> {
  bool _buying = false;

  @override
  Widget build(BuildContext context) {
    final asyncProfile = ref.watch(teacherProfileProvider(widget.userId));
    return asyncProfile.when(
      loading: () => const AppScaffold(
        title: 'Lärare',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Lärare',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (state) {
        final teacher = state.teacher;
        if (teacher == null) {
          return const AppScaffold(
            title: 'Lärare',
            body: Center(child: Text('Läraren hittades inte.')),
          );
        }
        final profile = (teacher['profile'] as Map?)?.cast<String, dynamic>();
        final display = profile?['display_name'] as String? ?? 'Lärare';
        final headline = (teacher['headline'] as String?) ?? '';

        return AppScaffold(
          title: display,
          body: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: Text(
                    display,
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  subtitle: Text(headline),
                  trailing: OutlinedButton(
                    onPressed: () => context.push('/messages/dm/${widget.userId}'),
                    child: const Text('Meddelande'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _CertificatesCard(certs: state.certificates),
              const SizedBox(height: 8),
              _ServicesCard(
                services: state.services,
                buying: _buying,
                onBuy: (service) => _buyService(service),
              ),
              const SizedBox(height: 8),
              _MeditationsCard(meditations: state.meditations),
            ],
          ),
        );
      },
    );
  }

  Future<void> _buyService(Map<String, dynamic> service) async {
    final serviceId = service['id'] as String?;
    final price = (service['price_cents'] as int?) ?? 0;
    if (serviceId == null || price <= 0) return;
    setState(() => _buying = true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      final order = await repo.startServiceOrder(
        serviceId: serviceId,
        amountCents: price,
      );
      final pay = PaymentsService();
      final url = await pay.createCheckoutSession(
        orderId: order['id'] as String,
        amountCents: price,
        successUrl:
            'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
      );
      if (url != null) {
        await launchUrlString(url);
      } else {
        _showSnack('Kunde inte initiera betalning.');
      }
    } catch (error) {
      _showSnack('Kunde inte initiera köp: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    showSnack(context, message);
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _CertificatesCard extends StatelessWidget {
  const _CertificatesCard({required this.certs});

  final List<Certificate> certs;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Certifikat',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (certs.isEmpty)
              const Text('Inga certifikat publicerade ännu.')
            else
              ...certs.map(
                (c) => ListTile(
                  leading: const Icon(Icons.verified_rounded,
                      color: Colors.lightGreen),
                  title: Text(c.title),
                  subtitle: Text([
                    if ((c.issuer ?? '').isNotEmpty) c.issuer,
                    if (c.issuedAt != null)
                      'Utfärdat: ${c.issuedAt!.toLocal().toString().split(' ').first}',
                  ].whereType<String>().join(' • ')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServicesCard extends StatelessWidget {
  const _ServicesCard({
    required this.services,
    required this.buying,
    required this.onBuy,
  });

  final List<Map<String, dynamic>> services;
  final bool buying;
  final Future<void> Function(Map<String, dynamic>) onBuy;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tjänster',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (services.isEmpty)
              const Text('Inga tjänster ännu.')
            else
              ...services.map(
                (service) => ListTile(
                  leading: const Icon(Icons.work_rounded),
                  title: Text(service['title'] as String? ?? 'Tjänst'),
                  subtitle: Text(service['description'] as String? ?? ''),
                  trailing: ElevatedButton(
                    onPressed: buying ? null : () => onBuy(service),
                    child: buying
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Boka/köp ${(service['price_cents'] ?? 0) / 100} kr'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeditationsCard extends StatelessWidget {
  const _MeditationsCard({required this.meditations});

  final List<Map<String, dynamic>> meditations;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meditationer',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (meditations.isEmpty)
              const Text('Inga meditationer ännu.')
            else
              ...meditations.map(
                (m) => _MeditationTile(
                  title: m['title'] as String? ?? 'Meditation',
                  description: m['description'] as String? ?? '',
                  url: Supa.client.storage
                      .from('media')
                      .getPublicUrl(m['audio_path'] as String),
                  durationSeconds: (m['duration_seconds'] as int?) ?? 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeditationTile extends StatefulWidget {
  const _MeditationTile({
    required this.title,
    required this.description,
    required this.url,
    required this.durationSeconds,
  });

  final String title;
  final String description;
  final String url;
  final int durationSeconds;

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
