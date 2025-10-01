import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisdom/data/supabase/supabase_client.dart';
import 'package:wisdom/features/community/data/messages_repository.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class MessagesPage extends StatefulWidget {
  final String kind; // 'dm' eller 'service'
  final String id;
  const MessagesPage({super.key, required this.kind, required this.id});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _svc = MessagesRepository();
  final _input = TextEditingController();
  bool _loading = true;
  bool _sending = false;
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _chan;

  String get _channel => '${widget.kind}:${widget.id}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _svc.listMessages(_channel);
    if (!mounted) return;
    setState(() {
      _messages = rows;
      _loading = false;
    });
    _subscribe();
  }

  void _subscribe() {
    _chan?.unsubscribe();
    final sb = Supa.client;
    _chan = sb
        .channel('msg-${widget.kind}-${widget.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'app',
          table: 'messages',
          callback: (payload) {
            final row = (payload.newRecord as Map?)?.cast<String, dynamic>();
            if (row == null) return;
            // Manual filter for SDKs lacking typed/string filter APIs
            if (row['channel'] != _channel) return;
            if (!mounted) return;
            setState(() => _messages = [..._messages, row]);
          },
        )
        .subscribe();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _svc.sendMessage(channel: _channel, content: text);
      _input.clear();
      await _load();
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte skicka: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    if (_chan != null) {
      Supa.client.removeChannel(_chan!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supa.client.auth.currentUser?.id;
    return AppScaffold(
      title: 'Meddelanden',
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final mine = m['sender_id'] == uid;
                      return Align(
                        alignment:
                            mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: mine
                                ? Colors.blueAccent.withValues(alpha: .15)
                                : Colors.grey.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m['content'] as String? ?? ''),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                        hintText: 'Skriv ett meddelande...'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Skicka'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
