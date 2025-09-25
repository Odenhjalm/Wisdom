import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCallbackPage extends ConsumerStatefulWidget {
  const AuthCallbackPage({super.key, required this.state});

  final GoRouterState state;

  @override
  ConsumerState<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<AuthCallbackPage> {
  bool _processing = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_handleLink);
  }

  Future<void> _handleLink() async {
    Uri? link;

    if (kIsWeb) {
      link = Uri.base;
    } else {
      link = widget.state.uri;
      if (link.scheme.isEmpty &&
          link.queryParameters.isEmpty &&
          link.fragment.isEmpty) {
        link = Uri.base;
      }
    }

    final params = _mergedParams(link);
    final type = params['type'] ?? '';
    final hasSessionParams = params.containsKey('access_token') ||
        params.containsKey('refresh_token') ||
        params.containsKey('code');

    try {
      final client = Supabase.instance.client;

      if (hasSessionParams) {
        await client.auth.getSessionFromUrl(link);
      }

      if (!mounted) return;

      if (type == 'recovery') {
        context.go('/new-password');
        return;
      }

      if (type == 'magiclink' || type == 'signup' || type == 'email_change') {
        context.go('/');
        return;
      }

      if (!mounted) return;

      setState(() {
        _processing = false;
        _message = type.isEmpty
            ? 'Ingen autentiseringsinformation hittades.'
            : 'Ohanterad auth-åtgärd: $type';
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _message = 'Kunde inte bearbeta autentiseringslänken.';
      });
    }
  }

  Map<String, String> _mergedParams(Uri uri) {
    final combined = <String, String>{};
    combined.addAll(uri.queryParameters);
    if (uri.fragment.isNotEmpty) {
      try {
        combined.addAll(Uri.splitQueryString(uri.fragment));
      } catch (_) {
        // ignore malformed fragment data
      }
    }
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_processing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Autentisering')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Autentisering',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(_message ?? 'Klar.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Till inloggningen'),
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
