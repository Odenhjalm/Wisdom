import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/auth/oauth_redirect.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';

import 'package:wisdom/gate.dart';
import 'package:wisdom/shared/utils/context_safe.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: p16,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
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
                            'Skapa konto',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          gap24,
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'E-postadress',
                              hintText: 'namn@example.com',
                            ),
                            validator: _validateEmail,
                          ),
                          gap16,
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                _busy ? null : (_) => _signUp(context),
                            decoration: const InputDecoration(
                              labelText: 'Lösenord',
                              hintText: 'Minst 6 tecken',
                            ),
                            validator: _validatePassword,
                          ),
                          gap24,
                          FilledButton(
                            onPressed: _busy ? null : () => _signUp(context),
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Skapa konto'),
                          ),
                          gap12,
                          TextButton(
                            onPressed:
                                _busy ? null : () => context.go('/login'),
                            child: const Text('Har du konto? Logga in'),
                          ),
                          gap24,
                          Text(
                            'Alternativ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          gap12,
                          OutlinedButton(
                            onPressed:
                                _busy ? null : () => _sendMagicLink(context),
                            child: const Text('Skicka magisk länk'),
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

  Future<void> _signUp(BuildContext context) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _busy = true);
    try {
      final redirectTo = oauthRedirect();
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectTo,
      );
      if (response.session != null) {
        gate.allow();
        context.ifMounted((c) {
          showSnack(c, 'Konto skapat. Inloggad som $email');
          c.go('/');
        });
      } else {
        context.ifMounted(
          (c) => showSnack(
            c,
            'Vi har skickat en bekräftelselänk till din e-post.',
          ),
        );
      }
    } on AuthException catch (e) {
      context.ifMounted((c) => showSnack(c, e.message));
    } catch (e) {
      context.ifMounted(
        (c) => showSnack(c, 'Något gick fel. Försök igen.'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendMagicLink(BuildContext context) async {
    final email = _emailCtrl.text.trim();
    if (!_isValidEmail(email)) {
      showSnack(context, 'Ange en giltig e-postadress först.');
      return;
    }

    setState(() => _busy = true);
    try {
      final redirectTo = oauthRedirect();
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );
      context.ifMounted((c) => showSnack(c, 'Magisk länk skickad.'));
    } on AuthException catch (e) {
      context.ifMounted((c) => showSnack(c, e.message));
    } catch (e) {
      context.ifMounted(
        (c) => showSnack(c, 'Något gick fel. Försök igen.'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateEmail(String? value) {
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

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }
}
