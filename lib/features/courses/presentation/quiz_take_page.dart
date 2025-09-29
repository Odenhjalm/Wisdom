import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/courses/application/course_providers.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/context_safe.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/shared/widgets/go_router_back_button.dart';

class QuizTakePage extends ConsumerStatefulWidget {
  const QuizTakePage({super.key});

  @override
  ConsumerState<QuizTakePage> createState() => _QuizTakePageState();
}

class _QuizTakePageState extends ConsumerState<QuizTakePage> {
  String _quizId = '';
  bool _initialized = false;
  Map<String, dynamic> _answers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final qp = GoRouterState.of(context).uri.queryParameters;
    _quizId = qp['quizId'] ?? qp['id'] ?? '';
    _initialized = true;
    ref.listen<AsyncValue<Map<String, dynamic>?>>(
      quizSubmissionProvider(_quizId),
      (previous, next) {
        next.when(
          data: (result) {
            if (result == null) return;
            final passed = result['passed'] == true;
            final message = passed
                ? 'Godkänt! Ditt certifikat är utfärdat.'
                : 'Resultat sparat. Fortsätt öva!';
            context.ifMounted((c) => showSnack(c, message));
          },
          error: (error, _) {
            context.ifMounted(
              (c) => showSnack(
                c,
                'Kunde inte lämna in: ${_friendlyError(error)}',
              ),
            );
          },
          loading: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _quizId.isEmpty
        ? const AsyncValue<List<QuizQuestion>>.data([])
        : ref.watch(quizQuestionsProvider(_quizId));
    final submissionState = _quizId.isEmpty
        ? const AsyncValue<Map<String, dynamic>?>.data(null)
        : ref.watch(quizSubmissionProvider(_quizId));

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
        child: questions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(_friendlyError(error))),
          data: (items) => _QuizContent(
            quizId: _quizId,
            questions: items,
            answers: _answers,
            onSetSingle: _setSingle,
            onToggleMulti: _toggleMulti,
            onSetBool: _setBool,
            onSubmit: _submit,
            submissionState: submissionState,
          ),
        ),
      ),
    );
  }

  void _setSingle(String qid, int idx) {
    setState(() => _answers = {..._answers, qid: idx});
  }

  void _toggleMulti(String qid, int idx, bool set) {
    final current = (_answers[qid] as List<int>?) ?? <int>[];
    final next = [...current];
    if (set) {
      if (!next.contains(idx)) next.add(idx);
    } else {
      next.remove(idx);
    }
    next.sort();
    setState(() => _answers = {..._answers, qid: next});
  }

  void _setBool(String qid, bool value) {
    setState(() => _answers = {..._answers, qid: value});
  }

  Future<void> _submit() async {
    if (_quizId.isEmpty) {
      showSnack(context, 'Quiz saknas.');
      return;
    }
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      showSnack(context, 'Supabase ej konfigurerat.');
      return;
    }
    if (sb.auth.currentUser == null) {
      final redirect = '/course-quiz?quizId=$_quizId';
      context.ifMounted(
        (c) => c.go('/login?redirect=${Uri.encodeComponent(redirect)}'),
      );
      return;
    }
    await ref.read(quizSubmissionProvider(_quizId).notifier).submit(_answers);
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent({
    required this.quizId,
    required this.questions,
    required this.answers,
    required this.onSetSingle,
    required this.onToggleMulti,
    required this.onSetBool,
    required this.onSubmit,
    required this.submissionState,
  });

  final String quizId;
  final List<QuizQuestion> questions;
  final Map<String, dynamic> answers;
  final void Function(String qid, int idx) onSetSingle;
  final void Function(String qid, int idx, bool set) onToggleMulti;
  final void Function(String qid, bool value) onSetBool;
  final Future<void> Function() onSubmit;
  final AsyncValue<Map<String, dynamic>?> submissionState;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final result = submissionState.whenOrNull(data: (value) => value);

    return Padding(
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
                  if (result != null) ...[
                    _ResultBanner(result: result),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final qid = question.id;
                        final kind = question.kind;
                        final prompt = question.prompt;
                        final options = question.options;
                        return _QuestionWidget(
                          index: index + 1,
                          qid: qid,
                          prompt: prompt,
                          kind: kind,
                          options: options,
                          value: answers[qid],
                          onChangeSingle: (idx) => onSetSingle(qid, idx),
                          onChangeMulti: (idx, value) => onToggleMulti(qid, idx, value),
                          onChangeBool: (value) => onSetBool(qid, value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: submissionState.isLoading ? null : onSubmit,
                        icon: submissionState.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Lämna in'),
                      ),
                    ],
                  ),
                  if (submissionState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _friendlyError(submissionState.error!),
                        style: t.bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}

class _QuestionWidget extends StatelessWidget {
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

  final int index;
  final String qid;
  final String prompt;
  final String kind;
  final List<String> options;
  final dynamic value;
  final void Function(int index) onChangeSingle;
  final void Function(int index, bool value) onChangeMulti;
  final void Function(bool value) onChangeBool;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (kind) {
      case 'multi':
        final selected = (value as List<int>?) ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index. $prompt', style: t.titleMedium),
            gap8,
            ...List.generate(options.length, (i) {
              return CheckboxListTile(
                value: selected.contains(i),
                onChanged: (v) => onChangeMulti(i, v ?? false),
                title: Text(options[i]),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        );
      case 'bool':
        final boolValue = value == true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index. $prompt', style: t.titleMedium),
            gap8,
            SwitchListTile(
              value: boolValue,
              onChanged: onChangeBool,
              title: const Text('Sant'),
            ),
          ],
        );
      case 'single':
      default:
        final intValue = value is int ? value as int : -1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index. $prompt', style: t.titleMedium),
            gap8,
            ...List.generate(options.length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: intValue,
                onChanged: (v) {
                  if (v != null) onChangeSingle(v);
                },
                title: Text(options[i]),
              );
            }),
          ],
        );
    }
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final passed = result['passed'] == true;
    final score = result['score'] ?? '';
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.verified_rounded : Icons.info_outline,
                color: passed ? const Color(0xFF059669) : const Color(0xFFB91C1C),
              ),
              const SizedBox(width: 8),
              Text(
                passed ? 'Grattis!' : 'Resultat',
                style:
                    t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (score != '') ...[
            const SizedBox(height: 6),
            Text('Poäng: $score'),
          ],
        ],
      ),
    );
  }
}
