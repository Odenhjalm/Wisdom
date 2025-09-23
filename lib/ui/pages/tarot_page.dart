import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class TarotPage extends StatefulWidget {
  const TarotPage({super.key});

  @override
  State<TarotPage> createState() => _TarotPageState();
}

class _TarotPageState extends State<TarotPage> {
  final _q = TextEditingController();
  bool _loading = true;
  bool _sending = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = Supa.client.auth.currentUser;
    if (u != null) {
      final rows = await Supa.client.app
          .from('tarot_requests')
          .select('id, question, status, created_at')
          .eq('requester_id', u.id)
          .order('created_at', ascending: false);
      _items = (rows as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _create() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    final text = _q.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await Supa.client.app.from('tarot_requests').insert({
        'requester_id': u.id,
        'question': text,
      });
      _q.clear();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Förfrågan skickad.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skicka: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tarot',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ny förfrågan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _q,
                          decoration:
                              const InputDecoration(labelText: 'Din fråga'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _sending ? null : _create,
                          child: Text(_sending ? 'Skickar…' : 'Skicka'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = _items[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.auto_awesome_rounded),
                          title: Text(r['question'] as String? ?? ''),
                          subtitle: Text('${r['status']} • ${r['created_at']}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
