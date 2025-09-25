import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/core/errors/app_failure.dart';
import 'package:visdom/core/supabase_ext.dart';
import 'package:visdom/features/community/application/community_providers.dart';
import 'package:visdom/gate.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final certsAsync = ref.watch(myCertificatesProvider);
    return profileAsync.when(
      loading: () => const AppScaffold(
        title: 'Profil',
        neutralBackground: true,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Profil',
        neutralBackground: true,
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (profile) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null || profile == null) {
          return _LoginCard(
            emailController: _email,
            passwordController: _password,
            busy: _busy,
            onSubmit: _signInUp,
          );
        }
        return AppScaffold(
          title: 'Profil',
          neutralBackground: true,
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(profile['display_name'] as String? ?? user.email ?? user.id),
                  subtitle: Text(profile['bio'] as String? ?? ''),
                  trailing: FilledButton(
                    onPressed: _signOut,
                    child: const Text('Logga ut'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: const Text('Ansök som lärare'),
                  subtitle: const Text('Publicera ceremonier, sessioner och läsningar.'),
                  trailing: OutlinedButton(
                    onPressed: _applyAsTeacher,
                    child: const Text('Ansök'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              certsAsync.when(
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
                data: (certs) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mina certifikat',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        if (certs.isEmpty)
                          const Text('Du har inte publicerat några certifikat ännu.')
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
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addCertificate,
                icon: const Icon(Icons.file_upload_rounded),
                label: const Text('Lägg till certifikat'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addCertificate() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCertificateDialog(),
    );
    if (res == true) {
      ref.invalidate(myCertificatesProvider);
    }
  }

  Future<void> _applyAsTeacher() async {
    final client = Supabase.instance.client;
    final u = client.auth.currentUser;
    if (u == null) return;
    try {
      await client.app.from('teacher_requests').upsert({
        'user_id': u.id,
        'message': 'Ansökan efter certifikat(er) från profil',
      });
      if (!context.mounted) return;
      showSnack(context, 'Ansökan inskickad. Tack!');
    } catch (error) {
      if (!context.mounted) return;
      showSnack(context, 'Kunde inte skicka: ${_friendlyError(error)}');
    }
  }

  Future<void> _signInUp() async {
    final email = _email.text.trim();
    final pw = _password.text;
    if (email.isEmpty || pw.isEmpty) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(authProfileRepositoryProvider);
      await repo.signInOrSignUp(email: email, password: pw);
      ref.invalidate(myProfileProvider);
      if (!context.mounted) return;
      context.go('/home');
    } catch (error) {
      if (!context.mounted) return;
      showSnack(context, 'Inloggning misslyckades: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final repo = ref.read(authProfileRepositoryProvider);
    await repo.signOut();
    gate.reset();
    ref.invalidate(myProfileProvider);
    if (!context.mounted) return;
    showSnack(context, 'Utloggad');
    context.go('/landing');
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool busy;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: 'Profil',
      neutralBackground: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Logga in eller skapa konto',
                    style:
                        t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E‑post',
                      hintText: 'namn@exempel.se',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Lösenord'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: busy ? null : onSubmit,
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Logga in / Skapa konto'),
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

class _AddCertificateDialog extends StatefulWidget {
  const _AddCertificateDialog();

  @override
  State<_AddCertificateDialog> createState() => _AddCertificateDialogState();
}

class _AddCertificateDialogState extends State<_AddCertificateDialog> {
  final _title = TextEditingController();
  final _issuer = TextEditingController();
  DateTime? _issuedAt;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _issuer.dispose();
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
          TextField(
            controller: _issuer,
            decoration: const InputDecoration(labelText: 'Utfärdare'),
          ),
          Row(
            children: [
              Text(_issuedAt == null
                  ? 'Ingen datum vald'
                  : 'Utfärdat: ${_issuedAt!.toLocal().toString().split(' ').first}'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final res = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (res != null) {
                    setState(() => _issuedAt = res);
                  }
                },
                child: const Text('Välj datum'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  final title = _title.text.trim();
                  if (title.isEmpty) return;
                  setState(() => _saving = true);
                  try {
                    final client = Supabase.instance.client;
                    await client.app.from('certificates').insert({
                      'title': title,
                      if (_issuer.text.trim().isNotEmpty)
                        'issuer': _issuer.text.trim(),
                      if (_issuedAt != null)
                        'issued_at': _issuedAt!.toIso8601String(),
                    });
                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  } catch (_) {
                    if (!context.mounted) return;
                    showSnack(context, 'Kunde inte spara certifikat.');
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
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
}
