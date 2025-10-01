import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/gate.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/gradient_text.dart';
import 'package:wisdom/widgets/base_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectPath});

  final String? redirectPath;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
    final envInfo = ref.watch(envInfoProvider);
    final envBlocked = envInfo.hasIssues;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BasePage(
        child: SafeArea(
          top: false,
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
                            if (envBlocked)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  '${envInfo.message} Inloggning är avstängd tills nycklarna är på plats.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            Text(
                              'Logga in',
                              style: textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            gap24,
                            TextFormField(
                              controller: _emailCtrl,
                              enabled: !envBlocked,
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
                              enabled: !envBlocked,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: _busy || envBlocked
                                  ? null
                                  : (_) => _submit(context),
                              decoration: const InputDecoration(
                                labelText: 'Lösenord',
                                hintText: 'Minst 6 tecken',
                              ),
                              validator: _validatePassword,
                            ),
                            gap24,
                            FilledButton(
                              onPressed: _busy || envBlocked
                                  ? null
                                  : () => _submit(context),
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
                              onPressed: _busy || envBlocked
                                  ? null
                                  : () => context.go('/signup'),
                              child: GradientText(
                                'Skapa konto',
                                style:
                                    textTheme.bodyMedium ?? const TextStyle(),
                              ),
                            ),
                            TextButton(
                              onPressed: _busy || envBlocked
                                  ? null
                                  : () => context.go('/forgot-password'),
                              child: GradientText(
                                'Glömt lösenord?',
                                style:
                                    textTheme.bodyMedium ?? const TextStyle(),
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

  Future<void> _submit(BuildContext context) async {
    final envInfo = ref.read(envInfoProvider);
    if (envInfo.hasIssues) {
      showSnack(
        context,
        '${envInfo.message} Logga in är avstängt tills konfigurationen är klar.',
      );
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      gate.allow();
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Inloggad som $email');
      final redirect = widget.redirectPath;
      if (redirect != null && redirect.startsWith('/')) {
        context.go(redirect);
      } else {
        context.go('/');
      }
    } on AuthException catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, e.message);
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Något gick fel. Försök igen.');
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
