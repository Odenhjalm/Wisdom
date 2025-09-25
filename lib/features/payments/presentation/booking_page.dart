import 'package:flutter/material.dart';

import 'package:visdom/core/supabase_ext.dart';
import 'package:visdom/data/supabase/supabase_client.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _loading = true;
  bool _saving = false;
  bool _isTeacher = false;
  // Teacher slot form
  final DateTime _start = DateTime.now().add(const Duration(days: 1));
  int _durationMin = 60;
  List<Map<String, dynamic>> _mySlots = [];
  List<Map<String, dynamic>> _openSlots = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = Supa.client.auth.currentUser;
    if (u != null) {
      final res = await Supa.client.schema('app').rpc('get_my_profile');
      final map = (res is Map)
          ? res.cast<String, dynamic>()
          : (res is List && res.isNotEmpty
              ? (res.first as Map).cast<String, dynamic>()
              : null);
      final role = map?['role'] as String?;
      _isTeacher = role == 'teacher' || role == 'admin';
      if (_isTeacher) {
        final rows = await Supa.client.app
            .from('teacher_slots')
            .select('id, starts_at, ends_at, is_booked')
            .eq('teacher_id', u.id)
            .order('starts_at');
        _mySlots = (rows as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      final open = await Supa.client.app
          .from('teacher_slots')
          .select('id, starts_at, ends_at, teacher_id')
          .eq('is_booked', false)
          .order('starts_at');
      _openSlots = (open as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _createSlot() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    setState(() => _saving = true);
    try {
      final ends = _start.add(Duration(minutes: _durationMin));
      await Supa.client.app.from('teacher_slots').insert({
        'teacher_id': u.id,
        'starts_at': _start.toIso8601String(),
        'ends_at': ends.toIso8601String(),
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte skapa slot: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _book(String slotId) async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return;
    setState(() => _saving = true);
    try {
      await Supa.client.app.from('bookings').insert({
        'slot_id': slotId,
        'user_id': u.id,
        'status': 'reserved',
      });
      await _load();
      if (!mounted) return;
      showSnack(context, 'Bokning reserverad.');
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte boka: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Bokningar',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return AppScaffold(
      title: 'Bokningar',
      body: ListView(
        children: [
          if (_isTeacher)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Publicera tider (lärare)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: _start.toString()),
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Start (UTC)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Minuter'),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                                text: _durationMin.toString()),
                            onSubmitted: (v) => setState(
                                () => _durationMin = int.tryParse(v) ?? 60),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _saving ? null : _createSlot,
                      child: Text(_saving ? 'Skapar…' : 'Skapa slot'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Mina slots'),
                    const SizedBox(height: 6),
                    ..._mySlots.map((s) => ListTile(
                          leading: Icon(
                            (s['is_booked'] == true)
                                ? Icons.event_available_rounded
                                : Icons.schedule_rounded,
                          ),
                          title: Text('${s['starts_at']} → ${s['ends_at']}'),
                        )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lediga tider'),
                  const SizedBox(height: 6),
                  if (_openSlots.isEmpty)
                    const Text('Inga tider just nu.')
                  else
                    ..._openSlots.map((s) => ListTile(
                          leading: const Icon(Icons.event_rounded),
                          title: Text('${s['starts_at']} → ${s['ends_at']}'),
                          trailing: ElevatedButton(
                            onPressed:
                                _saving ? null : () => _book(s['id'] as String),
                            child: const Text('Boka'),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
