import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:visdom/supabase_client.dart';
import 'package:visdom/shared/widgets/go_router_back_button.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _text = TextEditingController();
  bool _loading = true;
  late final String peerId;
  late final String channel;
  late final String title;

  @override
  void initState() {
    super.initState();
    // Read route params in build; init fetch in post frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final state = GoRouterState.of(context);
    peerId = state.pathParameters['uid'] ?? '';
    title = state.uri.queryParameters['name'] ?? 'Direktmeddelande';
    final me = ref.read(supabaseMaybeProvider)?.auth.currentUser?.id;
    if (me == null || peerId.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final pair = [me, peerId]..sort();
    channel = 'dm:${pair[0]}:${pair[1]}';
    await _loadMessages();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadMessages() async {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) return;
    final res = await sb
        .from('app.messages')
        .select('id,sender_id,content,created_at')
        .eq('channel', channel)
        .order('created_at');
    setState(() {
      _messages
        ..clear()
        ..addAll((res as List).cast<Map<String, dynamic>>());
    });
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) return;
    final me = sb.auth.currentUser?.id;
    if (me == null) return;
    _text.clear();
    await sb.from('app.messages').insert({
      'channel': channel,
      'sender_id': me,
      'content': text,
    });
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const GoRouterBackButton(),
        title: Text(title),
      ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        final isMe = m['sender_id'] ==
                            ref
                                .read(supabaseMaybeProvider)
                                ?.auth
                                .currentUser
                                ?.id;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              m['content'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            decoration: const InputDecoration(
                              hintText: 'Skriv ett meddelande…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _send,
                          icon: const Icon(Icons.send),
                          label: const Text('Skicka'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
