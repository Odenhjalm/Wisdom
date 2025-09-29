import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/gradient_text.dart';
import 'package:wisdom/shared/utils/context_safe.dart';

import 'package:wisdom/gate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                            'Logga in',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          gap24,
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
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
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                _busy ? null : (_) => _submit(context),
                            decoration: const InputDecoration(
                              labelText: 'Lösenord',
                              hintText: 'Minst 6 tecken',
                            ),
                            validator: _validatePassword,
                          ),
                          gap24,
                          FilledButton(
                            onPressed: _busy ? null : () => _submit(context),
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Logga in'),
                          ),
                          gap12,
                          TextButton(
                            onPressed:
                                _busy ? null : () => context.go('/signup'),
                            child: GradientText(
                              'Skapa konto',
                              style: textTheme.bodyMedium ?? const TextStyle(),
                            ),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => context.go('/forgot-password'),
                            child: GradientText(
                              'Glömt lösenord?',
                              style: textTheme.bodyMedium ?? const TextStyle(),
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
    );
  }

  Future<void> _submit(BuildContext context) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      gate.allow();
      context.ifMounted((c) {
        showSnack(c, 'Inloggad som $email');
        c.go('/');
      });
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
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
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
