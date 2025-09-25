import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/core/errors/app_failure.dart';
import 'package:visdom/core/supabase_ext.dart';
import 'package:visdom/features/community/application/community_providers.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(adminDashboardProvider);
    return dashboard.when(
      loading: () => const AppScaffold(
        title: 'Admin',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Admin',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (state) {
        if (!state.isAdmin) {
          return const AppScaffold(
            title: 'Admin',
            body: Center(child: Text('Endast admins.')),
          );
        }
        final t = Theme.of(context).textTheme;
        return AppScaffold(
          title: 'Admin',
          body: ListView(
            children: [
              Text('Läraransökningar',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (state.requests.isEmpty)
                const Card(
                  child: ListTile(title: Text('Inga ansökningar just nu.')),
                )
              else
                ...state.requests.map(
                  (r) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_add_alt_1_rounded),
                      title: Text(r['user_id'] as String? ?? ''),
                      subtitle: Text(
                        '${r['status']} • ${r['created_at']}\n${r['message'] ?? ''}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: _busy
                                ? null
                                : () => _approve(r['user_id'] as String),
                            child: const Text('Godkänn'),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => _reject(r['user_id'] as String),
                            child: const Text('Avslå'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Text('Certifikat (granskning)',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (state.certificates.isEmpty)
                const Card(
                  child: ListTile(title: Text('Inga certifikat ännu.')),
                )
              else
                ...state.certificates.map((c) {
                  final details = <String>[
                    c['user_id'] as String? ?? '',
                    if ((c['issuer'] as String?)?.isNotEmpty == true)
                      c['issuer'] as String,
                    if ((c['issued_at'] as String?)?.isNotEmpty == true)
                      'Utfärdat: ${c['issued_at']}',
                  ]..removeWhere((e) => e.isEmpty);
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        c['verified'] == true
                            ? Icons.verified_rounded
                            : Icons.verified_outlined,
                        color: c['verified'] == true
                            ? Colors.lightGreen
                            : null,
                      ),
                      title: Text(c['title'] as String? ?? 'Certifikat'),
                      subtitle: Text(details.join(' • ')),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          if (c['verified'] != true)
                            ElevatedButton(
                              onPressed: _busy
                                  ? null
                                  : () =>
                                      _setCertVerified(c['id'] as String, true),
                              child: const Text('Verifiera'),
                            ),
                          if (c['verified'] == true)
                            OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => _setCertVerified(
                                        c['id'] as String,
                                        false,
                                      ),
                              child: const Text('Återkalla'),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _approve(String userId) async {
    setState(() => _busy = true);
    try {
      final client = Supabase.instance.client;
      await client.rpc('app.approve_teacher', params: {'p_user': userId});
      ref.invalidate(adminDashboardProvider);
    } catch (error) {
      _showError('Kunde inte godkänna: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(String userId) async {
    setState(() => _busy = true);
    try {
      final client = Supabase.instance.client;
      await client.rpc('app.reject_teacher', params: {'p_user': userId});
      ref.invalidate(adminDashboardProvider);
    } catch (error) {
      _showError('Kunde inte avslå: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setCertVerified(String certId, bool verified) async {
    setState(() => _busy = true);
    try {
      final client = Supabase.instance.client;
      await client.app
          .from('certificates')
          .update({'verified': verified}).eq('id', certId);
      ref.invalidate(adminDashboardProvider);
    } catch (error) {
      _showError('Misslyckades: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showSnack(context, message);
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
