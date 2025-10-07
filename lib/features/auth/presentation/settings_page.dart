import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;

    return AppScaffold(
      title: 'Inställningar',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konto',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (profile != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(profile.displayName ?? profile.email),
                subtitle: Text(profile.email),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.push('/profile/edit'),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Redigera profil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!context.mounted) return;
                  showSnack(context, 'Utloggad');
                  context.go('/landing');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logga ut'),
              ),
            ] else ...[
              const Text('Du är inte inloggad.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Logga in'),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Integritet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/legal/privacy'),
              icon: const Icon(Icons.policy_rounded),
              label: const Text('Integritetspolicy'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/legal/terms'),
              icon: const Icon(Icons.description_rounded),
              label: const Text('Villkor'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Export och radering av data kommer i nästa iteration av backend-endpoints.',
            ),
          ],
        ),
      ),
    );
  }
}
