import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/gate.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/widgets/base_page.dart';

class LegacyLoginPage extends ConsumerStatefulWidget {
  const LegacyLoginPage({super.key});

  @override
  ConsumerState<LegacyLoginPage> createState() => _LegacyLoginPageState();
}

class _LegacyLoginPageState extends ConsumerState<LegacyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sb = ref.watch(supabaseMaybeProvider);
    if (sb == null) {
      return const _UnconfiguredScaffold(
        title: 'Logga in',
        message:
            'Supabase är inte konfigurerat. Starta appen med SUPABASE_URL och SUPABASE_ANON_KEY.',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Logga in')),
      body: BasePage(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Välkommen tillbaka',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Logga in med din e-postadress för att fortsätta.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailCtrl,
                              autofillHints: const [AutofillHints.username],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-postadress',
                                hintText: 'namn@example.com',
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordCtrl,
                              autofillHints: const [AutofillHints.password],
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted:
                                  _loading ? null : (_) => _submit(sb),
                              decoration: const InputDecoration(
                                labelText: 'Lösenord',
                                hintText: 'Minst 6 tecken',
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _loading ? null : () => _submit(sb),
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Logga in'),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => context.goNamed('signup'),
                                child: const Text('Skapa konto'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(SupabaseClient client) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);
    try {
      await client.auth.signInWithPassword(email: email, password: password);
      gate.allow();
      if (!mounted) return;
      showSnack(context, 'Inloggad som $email');
      if (!mounted || !context.mounted) return;
      context.go('/');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showSnack(context, 'Fel: $message');
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ange en e-postadress.';
    }
    const pattern = r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\$';
    final regex = RegExp(pattern, caseSensitive: false, multiLine: false);
    if (!regex.hasMatch(email)) {
      return 'Ogiltig e-postadress.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Lösenordet måste vara minst 6 tecken.';
    }
    return null;
  }
}

class _UnconfiguredScaffold extends StatelessWidget {
  final String title;
  final String message;

  const _UnconfiguredScaffold({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BasePage(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
