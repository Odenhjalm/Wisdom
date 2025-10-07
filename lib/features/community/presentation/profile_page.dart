import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final certificatesAsync = ref.watch(myCertificatesProvider);

    if (authState.isLoading && profile == null) {
      return const AppScaffold(
        title: 'Profil',
        neutralBackground: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const _LoginRequiredCard();
    }

    final displayName = profile.displayName?.trim().isNotEmpty == true
        ? profile.displayName!
        : profile.email;
    final subtitle = profile.bio?.trim().isNotEmpty == true
        ? profile.bio!
        : 'Medlem sedan ${profile.createdAt.toLocal().toString().split(' ').first}';

    return AppScaffold(
      title: 'Profil',
      neutralBackground: true,
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(displayName),
              subtitle: Text(subtitle),
              trailing: FilledButton(
                onPressed: () => _logout(context, ref),
                child: const Text('Logga ut'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Ansök som lärare'),
              subtitle: const Text(
                'Publicera ceremonier, sessioner och läsningar.',
              ),
              trailing: OutlinedButton(
                onPressed: () => _applyAsTeacher(context, ref),
                child: const Text('Ansök'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          certificatesAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(_friendlyError(error)),
              ),
            ),
            data: (certs) => _CertificatesCard(certificates: certs),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _addCertificate(context, ref),
            icon: const Icon(Icons.file_upload_rounded),
            label: const Text('Lägg till certifikat'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Redigera profil'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    showSnack(context, 'Utloggad');
    context.go('/landing');
  }

  Future<void> _applyAsTeacher(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(studioRepositoryProvider);
    try {
      await repo.applyAsTeacher();
      if (!context.mounted) return;
      showSnack(context, 'Ansökan inskickad. Tack!');
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (!context.mounted) return;
      showSnack(context, 'Kunde inte skicka: ${failure.message}');
    }
  }

  Future<void> _addCertificate(BuildContext context, WidgetRef ref) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCertificateDialog(),
    );
    if (res == true) {
      ref.invalidate(myCertificatesProvider);
    }
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _CertificatesCard extends StatelessWidget {
  const _CertificatesCard({required this.certificates});

  final List<Certificate> certificates;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mina certifikat',
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (certificates.isEmpty)
              const Text('Du har inte publicerat några certifikat ännu.')
            else
              ...certificates.map(_certificateTile),
          ],
        ),
      ),
    );
  }

  Widget _certificateTile(Certificate certificate) {
    final notes = certificate.notes?.trim();
    final evidence = certificate.evidenceUrl?.trim();
    final updated = certificate.updatedAt;
    final title =
        certificate.title.trim().isEmpty ? 'Certifikat' : certificate.title;
    final details = <String>[
      'Status: ${_certificateStatusLabel(certificate)}',
      if (notes != null && notes.isNotEmpty) notes,
      if (evidence != null && evidence.isNotEmpty) 'Bevis: $evidence',
      if (updated != null)
        'Uppdaterad: ${updated.toLocal().toString().split(' ').first}',
    ];
    return ListTile(
      leading: Icon(
        _certificateIcon(certificate),
        color: _certificateColor(certificate),
      ),
      title: Text(title),
      subtitle: Text(details.join('\n')),
      isThreeLine: details.length > 2,
    );
  }

  static IconData _certificateIcon(Certificate certificate) {
    if (certificate.isVerified) return Icons.verified_rounded;
    if (certificate.isPending) return Icons.hourglass_top_rounded;
    if (certificate.isRejected) return Icons.highlight_off_rounded;
    return Icons.description_outlined;
  }

  static Color? _certificateColor(Certificate certificate) {
    if (certificate.isVerified) return Colors.lightGreen;
    if (certificate.isRejected) return Colors.redAccent;
    if (certificate.isPending) return Colors.orangeAccent;
    return null;
  }

  static String _certificateStatusLabel(Certificate certificate) {
    switch (certificate.status) {
      case CertificateStatus.pending:
        return 'Under granskning';
      case CertificateStatus.verified:
        return 'Verifierat';
      case CertificateStatus.rejected:
        return 'Avslaget';
      case CertificateStatus.unknown:
        return certificate.statusRaw;
    }
  }
}

class _LoginRequiredCard extends StatelessWidget {
  const _LoginRequiredCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Profil',
      neutralBackground: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logga in för att fortsätta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Du behöver ett konto för att se din profil.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/login?redirect=%2Fprofile'),
                    child: const Text('Logga in'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.go('/signup?redirect=%2Fprofile'),
                    child: const Text('Skapa konto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCertificateDialog extends ConsumerStatefulWidget {
  const _AddCertificateDialog();

  @override
  ConsumerState<_AddCertificateDialog> createState() =>
      _AddCertificateDialogState();
}

class _AddCertificateDialogState extends ConsumerState<_AddCertificateDialog> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _evidenceUrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _evidenceUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nytt certifikat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titel'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Beskrivning (valfritt)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _evidenceUrl,
            decoration: const InputDecoration(
              labelText: 'Bevislänk (valfritt)',
              hintText: 'https://…',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _submit(context),
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Spara'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(certificatesRepositoryProvider);
      await repo.addCertificate(
        title: title,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        evidenceUrl:
            _evidenceUrl.text.trim().isEmpty ? null : _evidenceUrl.text.trim(),
      );
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (!context.mounted) return;
      showSnack(context, 'Kunde inte spara: ${failure.message}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
