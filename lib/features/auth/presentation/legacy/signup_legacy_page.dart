import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/gate.dart';
import 'package:visdom/supabase_client.dart';
import 'package:visdom/shared/utils/context_safe.dart';
import 'package:visdom/shared/utils/snack.dart';

class LegacySignupPage extends ConsumerStatefulWidget {
  const LegacySignupPage({super.key});

  @override
  ConsumerState<LegacySignupPage> createState() => _LegacySignupPageState();
}

class _LegacySignupPageState extends ConsumerState<LegacySignupPage> {
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
        title: 'Skapa konto',
        message:
            'Supabase är inte konfigurerat. Starta appen med SUPABASE_URL och SUPABASE_ANON_KEY.',
      );
    }
    final redirectTarget = supabaseRedirectUrl ?? kAppRedirect;

    return Scaffold(
      appBar: AppBar(title: const Text('Skapa konto')),
      body: SafeArea(
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
                            'Kom igång på några sekunder',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Skapa ett konto för att spara dina kurser och fortsätta där du slutade.',
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailCtrl,
                            autofillHints: const [AutofillHints.newUsername],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'E-postadress',
                              hintText: 'namn@example.com',
                            ),
                            validator: _validateEmailField,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            autofillHints: const [AutofillHints.newPassword],
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                _loading ? null : (_) => _createAccount(sb),
                            decoration: const InputDecoration(
                              labelText: 'Lösenord',
                              hintText: 'Minst 6 tecken',
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                _loading ? null : () => _createAccount(sb),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Skapa konto'),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => context.goNamed('login'),
                              child: const Text(
                                  'Har du redan ett konto? Logga in'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Fler sätt att skapa konto',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: _loading
                                ? null
                                : () => _sendMagicLink(sb, redirectTarget),
                            child: const Text('Skicka magisk länk'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _loading
                                ? null
                                : () => _sendOtp(sb, redirectTarget),
                            child: const Text('Skicka engångskod via e-post'),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _OauthButton(
                                label: 'Google',
                                icon: Icons.g_mobiledata,
                                onPressed: _loading
                                    ? null
                                    : () => _oauth(
                                          sb,
                                          OAuthProvider.google,
                                          redirectTarget,
                                        ),
                              ),
                              _OauthButton(
                                label: 'Microsoft',
                                icon: Icons.work_outline,
                                onPressed: _loading
                                    ? null
                                    : () => _oauth(
                                          sb,
                                          OAuthProvider.azure,
                                          redirectTarget,
                                        ),
                              ),
                              _OauthButton(
                                label: 'Facebook',
                                icon: Icons.facebook,
                                onPressed: _loading
                                    ? null
                                    : () => _oauth(
                                          sb,
                                          OAuthProvider.facebook,
                                          redirectTarget,
                                        ),
                              ),
                            ],
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
    );
  }

  Future<void> _createAccount(SupabaseClient client) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);
    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (res.user != null) {
        gate.allow();
        showSnack(context, 'Konto skapat för $email');
        context.ifMounted((c) => c.go('/'));
      } else {
        showSnack(context, 'Kontrollera din e-post för att bekräfta kontot.');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMagicLink(
    SupabaseClient client,
    String redirectTarget,
  ) async {
    final email = _emailCtrl.text.trim();
    if (!_isValidEmail(email)) {
      _showError('Ange en giltig e-postadress först.');
      return;
    }
    setState(() => _loading = true);
    try {
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTarget,
      );
      if (!mounted) return;
      showSnack(context, 'Magisk länk skickad till $email');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp(
    SupabaseClient client,
    String redirectTarget,
  ) async {
    final email = _emailCtrl.text.trim();
    if (!_isValidEmail(email)) {
      _showError('Ange en giltig e-postadress först.');
      return;
    }
    setState(() => _loading = true);
    try {
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTarget,
        shouldCreateUser: true,
      );
      if (!mounted) return;
      showSnack(context, 'Engångskod skickad till $email');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _oauth(
    SupabaseClient client,
    OAuthProvider provider,
    String redirectTarget,
  ) async {
    try {
      await client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectTarget,
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  bool _isValidEmail(String email) {
    const pattern = r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\$';
    final regex = RegExp(pattern, caseSensitive: false, multiLine: false);
    return regex.hasMatch(email);
  }

  String? _validateEmailField(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ange en e-postadress.';
    }
    if (!_isValidEmail(email)) {
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

  void _showError(String message) {
    if (!mounted) return;
    showSnack(context, 'Fel: $message');
  }
}

class _OauthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _OauthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
