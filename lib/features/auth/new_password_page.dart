import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                            'Sätt nytt lösenord',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Välj ett nytt lösenord för ditt konto. Det måste vara minst 6 tecken långt.',
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: const InputDecoration(
                              labelText: 'Nytt lösenord',
                              hintText: 'Minst 6 tecken',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: const InputDecoration(
                              labelText: 'Upprepa lösenord',
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                _busy ? null : (_) => _updatePassword(context),
                            validator: _validateConfirm,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                _busy ? null : () => _updatePassword(context),
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Spara nytt lösenord'),
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

  Future<void> _updatePassword(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final password = _passwordCtrl.text;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      // Tips: vid behov kan du förnya sessionen
      // await Supabase.instance.client.auth.refreshSession();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Lösenord uppdaterat.')),
      );
      router.go('/');
      // context.go('/login'); // Använd denna rad om du vill skicka tillbaka till login.
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(messenger, e.message);
    } catch (e) {
      if (!mounted) return;
      _showError(messenger, 'Något gick fel. Försök igen.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Lösenordet måste vara minst 6 tecken.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bekräfta ditt nya lösenord.';
    }
    if (value != _passwordCtrl.text) {
      return 'Lösenorden matchar inte.';
    }
    return null;
  }
}
