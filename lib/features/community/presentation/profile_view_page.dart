import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/features/community/data/follows_repository.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class ProfileViewPage extends ConsumerStatefulWidget {
  const ProfileViewPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends ConsumerState<ProfileViewPage> {
  bool _toggling = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewProvider(widget.userId));
    return profileAsync.when(
      loading: () => const AppScaffold(
        title: 'Profil',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Profil',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (state) {
        final profile = state.profile;
        if (profile == null) {
          return const AppScaffold(
            title: 'Profil',
            body: Center(child: Text('Profil hittades inte')),
          );
        }
        final t = Theme.of(context).textTheme;
        final name = (profile['display_name'] as String?) ?? 'Användare';
        final bio = (profile['bio'] as String?) ?? '';
        final services = state.services;
        final meditations = state.meditations;
        final following = state.isFollowing;

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
                        radius: 28,
                        child: Icon(Icons.person_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: t.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (bio.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(bio, style: t.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed:
                            _toggling ? null : () => _toggleFollow(following),
                        icon: Icon(
                          following
                              ? Icons.check_rounded
                              : Icons.person_add_alt_1_rounded,
                        ),
                        label: Text(following ? 'Följer' : 'Följ'),
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
                          style: t.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      if (services.isEmpty)
                        const Text('Inga tjänster.')
                      else
                        ...services.map(
                          (service) => ListTile(
                            leading: const Icon(Icons.work_rounded),
                            title:
                                Text(service['title'] as String? ?? 'Tjänst'),
                            subtitle:
                                Text(service['description'] as String? ?? ''),
                            trailing: Text(
                                '${((service['price_cents'] as int?) ?? 0) / 100} kr'),
                            onTap: () =>
                                context.push('/service/${service['id']}'),
                          ),
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
                      Text('Meditationer',
                          style: t.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      if (meditations.isEmpty)
                        const Text('Inga meditationer ännu.')
                      else
                        ...meditations.map(
                          (m) => ListTile(
                            leading: const Icon(Icons.graphic_eq_rounded),
                            title: Text(m['title'] as String? ?? 'Meditation'),
                            subtitle: Text(m['description'] as String? ?? ''),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFollow(bool currentlyFollowing) async {
    final me = Supabase.instance.client.auth.currentUser;
    if (me == null) {
      if (!mounted) return;
      showSnack(context, 'Logga in för att följa');
      return;
    }
    setState(() => _toggling = true);
    try {
      final repo = FollowsRepository();
      if (currentlyFollowing) {
        await repo.unfollow(widget.userId);
      } else {
        await repo.follow(widget.userId);
      }
      ref.invalidate(profileViewProvider(widget.userId));
    } catch (error) {
      if (!mounted) return;
      showSnack(context, _friendlyError(error));
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
