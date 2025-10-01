import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/auth/oauth_redirect.dart';
import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/gradient_text.dart';
import 'package:wisdom/widgets/base_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
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
                                  '${envInfo.message} Återställning av lösenord är avstängd tills konfigurationen är klar.',
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
                              'Glömt lösenord?',
                              style: textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            gap16,
                            const Text(
                              'Ange din e-postadress så skickar vi en länk för att återställa ditt lösenord.',
                            ),
                            gap24,
                            TextFormField(
                              controller: _emailCtrl,
                              enabled: !envBlocked,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: _busy || envBlocked
                                  ? null
                                  : (_) => _sendLink(context),
                              decoration: const InputDecoration(
                                labelText: 'E-postadress',
                                hintText: 'namn@example.com',
                              ),
                              validator: _validateEmail,
                            ),
                            gap24,
                            FilledButton(
                              onPressed: _busy || envBlocked
                                  ? null
                                  : () => _sendLink(context),
                              child: _busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Skicka återställningslänk'),
                            ),
                            gap12,
                            TextButton(
                              onPressed: _busy || envBlocked
                                  ? null
                                  : () => context.go('/login'),
                              child: GradientText(
                                'Tillbaka till logga in',
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

  Future<void> _sendLink(BuildContext context) async {
    final envInfo = ref.read(envInfoProvider);
    if (envInfo.hasIssues) {
      showSnack(
        context,
        '${envInfo.message} Återställning av lösenord är avstängd tills konfigurationen är klar.',
      );
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _emailCtrl.text.trim();

    setState(() => _busy = true);
    try {
      final redirectTo = oauthRedirect();
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Om adressen finns skickas en länk nu.');
      context.go('/login');
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
}
