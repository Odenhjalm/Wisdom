import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _loading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _certs = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = Supa.client.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }
    final res = await Supa.client.schema('app').rpc('get_my_profile');
    final row = (res is Map)
        ? res.cast<String, dynamic>()
        : (res is List && res.isNotEmpty
            ? (res.first as Map).cast<String, dynamic>()
            : null);
    final admin = row?['role'] == 'admin';
    List<Map<String, dynamic>> reqs = [];
    List<Map<String, dynamic>> certs = [];
    if (admin) {
      final rows = await Supa.client.app
          .from('teacher_requests')
          .select('user_id, message, status, created_at')
          .order('created_at', ascending: false);
      reqs = (rows as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final certRows = await Supa.client.app
          .from('certificates')
          .select('id, user_id, title, issuer, issued_at, verified')
          .order('created_at', ascending: false)
          .limit(200);
      certs = (certRows as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (!mounted) return;
    setState(() {
      _isAdmin = admin;
      _requests = reqs;
      _certs = certs;
      _loading = false;
    });
  }

  Future<void> _approve(String userId) async {
    setState(() => _busy = true);
    try {
      await Supa.client.rpc('app.approve_teacher', params: {'p_user': userId});
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte godkänna: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setCertVerified(String certId, bool verified) async {
    setState(() => _busy = true);
    try {
      await Supa.client.app
          .from('certificates')
          .update({'verified': verified}).eq('id', certId);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Misslyckades: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(String userId) async {
    setState(() => _busy = true);
    try {
      await Supa.client.rpc('app.reject_teacher', params: {'p_user': userId});
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte avslå: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Admin',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isAdmin) {
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
          if (_requests.isEmpty)
            const Card(
                child: ListTile(title: Text('Inga ansökningar just nu.')))
          else
            ..._requests.map((r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_add_alt_1_rounded),
                    title: Text(r['user_id'] as String),
                    subtitle: Text(
                        '${r['status']} • ${r['created_at']}\n${r['message'] ?? ''}'),
                    isThreeLine: true,
                    trailing: Wrap(spacing: 8, children: [
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
                    ]),
                  ),
                )),
          const SizedBox(height: 18),
          Text('Certifikat (granskning)',
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (_certs.isEmpty)
            const Card(child: ListTile(title: Text('Inga certifikat ännu.')))
          else
            ..._certs.map((c) {
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
                    color: c['verified'] == true ? Colors.lightGreen : null,
                  ),
                  title: Text(c['title'] as String? ?? 'Certifikat'),
                  subtitle: Text(details.join(' • ')),
                  trailing: Wrap(spacing: 8, children: [
                    if (c['verified'] != true)
                      ElevatedButton(
                        onPressed: _busy
                            ? null
                            : () => _setCertVerified(c['id'] as String, true),
                        child: const Text('Verifiera'),
                      )
                    else
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _setCertVerified(c['id'] as String, false),
                        child: const Text('Avverifiera'),
                      ),
                  ]),
                ),
              );
            }),
        ],
      ),
    );
  }
}
