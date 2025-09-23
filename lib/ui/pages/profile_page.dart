import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/data/auth_profile_service.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/gate.dart';
import 'package:andlig_app/core/supabase_ext.dart';
import 'package:andlig_app/data/certificates_service.dart';
import 'package:andlig_app/data/models/certificate.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _svc = AuthProfileService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = true;
  Map<String, dynamic>? _profile;
  String? _error;
  bool _busy = false;
  List<Certificate> _certs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _svc.getMyProfile();
      final certs = await CertificatesService().myCertificates();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _certs = certs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _addCertificate() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCertificateDialog(),
    );
    if (res == true) await _load();
  }

  Future<void> _applyAsTeacher() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    try {
      await Supa.client.app.from('teacher_requests').upsert({
        'user_id': u.id,
        'message': 'Ansökan efter certifikat(er) från profil',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ansökan inskickad. Tack!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skicka: $e')),
      );
    }
  }

  Future<void> _signInUp() async {
    final email = _email.text.trim();
    final pw = _password.text;
    if (email.isEmpty || pw.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _svc.signInOrSignUp(email: email, password: pw);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inloggning misslyckades: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await _svc.signOut();
    gate.reset();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utloggad')),
    );
    context.go('/landing');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Profil',
        neutralBackground: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = Supa.client.auth.currentUser;
    if (user == null || _profile == null) {
      // Ljus, vänlig login med neutral bakgrund
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'E‑post',
                        hintText: 'namn@exempel.se',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Lösenord'),
                      obscureText: true,
                      onSubmitted: (_) => _busy ? null : _signInUp(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _signInUp,
                          icon: _busy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.login_rounded),
                          label: Text(
                              _busy ? 'Loggar in…' : 'Logga in / Skapa konto'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Glömt lösenord?'),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final p = _profile!;
    final role = (_profile?['role'] as String?) ?? 'user';
    final isTeacher = role == 'teacher' || role == 'admin';
    return AppScaffold(
      title: 'Profil',
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inloggad som: ${user.email ?? user.id}'),
              const SizedBox(height: 8),
              Text('Namn: ${p['display_name'] ?? user.email ?? '—'}'),
              Text('Roll: ${p['role'] ?? 'user'}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Hem'),
                  ),
                  const SizedBox(width: 8),
                  if (isTeacher)
                    OutlinedButton(
                      onPressed: () => context.go('/studio'),
                      child: const Text('Öppna Studio (lärare)'),
                    ),
                  if (!isTeacher && _certs.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _applyAsTeacher,
                      icon: const Icon(Icons.school_rounded),
                      label: const Text('Ansök som lärare'),
                    ),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Logga ut'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: .1)),
              const SizedBox(height: 12),
              Text('Certifikat',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (_certs.isEmpty)
                Row(
                  children: [
                    const Expanded(
                        child: Text(
                            'Inga certifikat ännu. Lägg till ditt första för att låsa upp communityn.')),
                    ElevatedButton.icon(
                      onPressed: _addCertificate,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Lägg till'),
                    ),
                  ],
                )
              else ...[
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _addCertificate,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Lägg till certifikat'),
                  ),
                ),
              ],
            ],
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
  final _issuedAt = TextEditingController(); // YYYY-MM-DD
  final _credentialId = TextEditingController();
  final _credentialUrl = TextEditingController();
  final _specialties = TextEditingController(); // comma-separated
  bool _saving = false;

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    try {
      DateTime? issued;
      if (_issuedAt.text.trim().isNotEmpty) {
        issued = DateTime.tryParse(_issuedAt.text.trim());
      }
      final specs = _specialties.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      await CertificatesService().addCertificate(Certificate(
        id: '',
        userId: '',
        title: title,
        issuer: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
        issuedAt: issued,
        specialties: specs,
        credentialId: _credentialId.text.trim().isEmpty
            ? null
            : _credentialId.text.trim(),
        credentialUrl: _credentialUrl.text.trim().isEmpty
            ? null
            : _credentialUrl.text.trim(),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte spara: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text('Nytt certifikat',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _title,
                decoration: const InputDecoration(
                    labelText: 'Titel *',
                    hintText: 'Ex: Reiki Master Level II')),
            const SizedBox(height: 8),
            TextField(
                controller: _issuer,
                decoration: const InputDecoration(
                    labelText: 'Utfärdare',
                    hintText: 'Ex: Svenska Reiki Akademin')),
            const SizedBox(height: 8),
            TextField(
                controller: _issuedAt,
                decoration:
                    const InputDecoration(labelText: 'Utfärdat (YYYY-MM-DD)')),
            const SizedBox(height: 8),
            TextField(
                controller: _specialties,
                decoration: const InputDecoration(
                    labelText: 'Specialiteter (kommaseparerat)',
                    hintText: 't.ex. Reiki, Healing, Ritual')),
            const SizedBox(height: 8),
            TextField(
                controller: _credentialId,
                decoration: const InputDecoration(labelText: 'Credential ID')),
            const SizedBox(height: 8),
            TextField(
                controller: _credentialUrl,
                decoration: const InputDecoration(labelText: 'Credential URL')),
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
