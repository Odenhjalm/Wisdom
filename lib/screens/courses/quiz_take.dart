import 'package:flutter/material.dart';

import 'package:andlig_app/core/ui/ui_consts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../supabase_client.dart';
import '../../ui/widgets/go_router_back_button.dart';

class QuizTakePage extends ConsumerStatefulWidget {
  const QuizTakePage({super.key});

  @override
  ConsumerState<QuizTakePage> createState() => _QuizTakePageState();
}

class _QuizTakePageState extends ConsumerState<QuizTakePage> {
  late final String quizId;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, dynamic> _answers = {}; // qid -> int | List<int> | bool
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    // Delay to access GoRouter state context
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final qp = GoRouterState.of(context).uri.queryParameters;
    final id = qp['quizId'] ?? qp['id'] ?? '';
    quizId = id;
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      setState(() {
        _error = 'Supabase ej konfigurerat.';
        _loading = false;
      });
      return;
    }
    try {
      final res = await sb
          .from('quiz_questions')
          .select('id,position,kind,prompt,options')
          .eq('quiz_id', quizId)
          .order('position');
      final list = (res as List).cast<Map<String, dynamic>>();
      setState(() {
        _questions = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _setSingle(String qid, int idx) {
    setState(() => _answers[qid] = idx);
  }

  void _toggleMulti(String qid, int idx, bool set) {
    final cur = (_answers[qid] as List<int>?) ?? <int>[];
    final next = [...cur];
    if (set) {
      if (!next.contains(idx)) next.add(idx);
    } else {
      next.remove(idx);
    }
    next.sort();
    setState(() => _answers[qid] = next);
  }

  void _setBool(String qid, bool v) {
    setState(() => _answers[qid] = v);
  }

  Future<void> _submit() async {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supabase ej konfigurerat.')));
      return;
    }
    if (sb.auth.currentUser == null) {
      final redirect = '/course-quiz?quizId=$quizId';
      if (mounted)
        context.go('/login?redirect=${Uri.encodeComponent(redirect)}');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final res = await sb.rpc('grade_quiz_and_issue_certificate', params: {
        'p_quiz': quizId,
        'p_answers': _answers,
      });
      if (res is Map) {
        setState(() => _result = res.cast<String, dynamic>());
        final passed = res['passed'] == true;
        if (passed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Godkänt! Ditt certifikat är utfärdat.')),
          );
        }
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        title: const Text('Quiz'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Fel: $_error'))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_result != null) ...[
                                  _ResultBanner(result: _result!),
                                  const SizedBox(height: 12),
                                ],
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _questions.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 24),
                                    itemBuilder: (context, i) {
                                      final q = _questions[i];
                                      final qid = q['id'] as String;
                                      final kind =
                                          (q['kind'] ?? 'single') as String;
                                      final prompt =
                                          (q['prompt'] ?? '') as String;
                                      final opts = (q['options'] as List?)
                                          ?.cast<dynamic>()
                                          .map((e) => e.toString())
                                          .toList();
                                      return _QuestionWidget(
                                        index: i + 1,
                                        qid: qid,
                                        prompt: prompt,
                                        kind: kind,
                                        options: opts ?? const [],
                                        value: _answers[qid],
                                        onChangeSingle: (idx) =>
                                            _setSingle(qid, idx),
                                        onChangeMulti: (idx, v) =>
                                            _toggleMulti(qid, idx, v),
                                        onChangeBool: (v) => _setBool(qid, v),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: _submit,
                                    icon: const Icon(Icons.send),
                                    label: const Text('Lämna in'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final passed = result['passed'] == true;
    final score = result['score'] ?? 0;
    final total = result['total'] ?? 0;
    final correct = result['correct'] ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: passed ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(passed ? Icons.check_circle : Icons.info_outline,
              color:
                  passed ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  'Poäng: $score%. Rätt: $correct av $total. ${passed ? 'Godkänt!' : 'Försök igen.'}')),
        ],
      ),
    );
  }
}

class _QuestionWidget extends StatelessWidget {
  final int index;
  final String qid;
  final String prompt;
  final String kind; // single | multi | boolean
  final List<String> options;
  final dynamic value;
  final ValueChanged<int> onChangeSingle;
  final void Function(int, bool) onChangeMulti;
  final ValueChanged<bool> onChangeBool;

  const _QuestionWidget({
    required this.index,
    required this.qid,
    required this.prompt,
    required this.kind,
    required this.options,
    required this.value,
    required this.onChangeSingle,
    required this.onChangeMulti,
    required this.onChangeBool,
  });

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (kind == 'single') {
      final selected = (value is int) ? value as int : -1;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < options.length; i++)
            _OptionTile(
              label: options[i],
              selected: selected == i,
              onTap: () => onChangeSingle(i),
            ),
        ],
      );
    } else if (kind == 'multi') {
      final selected = (value is List<int>) ? (value as List<int>) : <int>[];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < options.length; i++)
            CheckboxListTile(
              value: selected.contains(i),
              onChanged: (v) => onChangeMulti(i, v ?? false),
              title: Text(options[i]),
            ),
        ],
      );
    } else {
      final selected = (value is bool) ? value as bool : false;
      body = Row(
        children: [
          const Text('False'),
          const SizedBox(width: 8),
          Switch(value: selected, onChanged: (v) => onChangeBool(v)),
          const SizedBox(width: 8),
          const Text('True'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fråga $index',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        gap6,
        Text(prompt),
        gap8,
        body,
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected ? scheme.primary.withValues(alpha: 0.08) : Colors.white;
    final border = selected ? scheme.primary : const Color(0xFFE2E8F0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: br12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: br12,
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? scheme.primary : Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
