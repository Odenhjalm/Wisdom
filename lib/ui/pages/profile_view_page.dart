import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/community_service.dart';
import 'package:andlig_app/data/community/follows_service.dart';
import 'package:andlig_app/data/meditations/meditations_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileViewPage extends StatefulWidget {
  final String userId;
  const ProfileViewPage({super.key, required this.userId});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  final _community = CommunityService();
  final _follows = FollowsService();
  final _meds = MeditationsService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _following = false;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _meditations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sb = Supabase.instance.client;
      final prof = await sb
          .schema('app')
          .from('profiles')
          .select('user_id, display_name, photo_url, bio, role')
          .eq('user_id', widget.userId)
          .maybeSingle();
      final me = sb.auth.currentUser?.id;
      bool following = false;
      if (me != null) {
        final f = await sb
            .schema('app')
            .from('follows')
            .select('follower_id')
            .eq('follower_id', me)
            .eq('followee_id', widget.userId)
            .maybeSingle();
        following = f != null;
      }
      final svcs = await _community.listServices(widget.userId);
      final meds = await _meds.byTeacher(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = (prof as Map?)?.cast<String, dynamic>();
        _following = following;
        _services = svcs;
        _meditations = meds;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final me = Supabase.instance.client.auth.currentUser;
    if (me == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logga in för att följa')));
      return;
    }
    setState(() => _following = !_following);
    try {
      if (_following) {
        await _follows.follow(widget.userId);
      } else {
        await _follows.unfollow(widget.userId);
      }
    } catch (_) {
      setState(() => _following = !_following); // rollback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
          title: 'Profil', body: Center(child: CircularProgressIndicator()));
    }
    final p = _profile;
    if (p == null) {
      return const AppScaffold(
          title: 'Profil', body: Center(child: Text('Profil hittades inte')));
    }
    final t = Theme.of(context).textTheme;
    final name = (p['display_name'] as String?) ?? 'Användare';
    final bio = (p['bio'] as String?) ?? '';

    return AppScaffold(
      title: name,
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                      radius: 28, child: Icon(Icons.person_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: t.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        if (bio.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(bio, style: t.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _toggleFollow,
                    icon: Icon(_following
                        ? Icons.check_rounded
                        : Icons.person_add_alt_1_rounded),
                    label: Text(_following ? 'Följer' : 'Följ'),
                  ),
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
                    const Text('Inga tjänster.')
                  else ...[
                    ..._services.map((s) => ListTile(
                          leading: const Icon(Icons.work_rounded),
                          title: Text(s['title'] as String? ?? 'Tjänst'),
                          subtitle: Text(s['description'] as String? ?? ''),
                          trailing: Text(
                              '${((s['price_cents'] as int?) ?? 0) / 100} kr'),
                          onTap: () => context.push('/service/${s['id']}'),
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
                    ..._meditations.map((m) => ListTile(
                          leading: const Icon(Icons.graphic_eq_rounded),
                          title: Text(m['title'] as String? ?? 'Meditation'),
                          subtitle: Text(m['description'] as String? ?? ''),
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
