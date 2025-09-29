import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/context_safe.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/features/payments/application/payments_providers.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/shared/widgets/go_router_back_button.dart';

class SubscribeScreen extends ConsumerStatefulWidget {
  const SubscribeScreen({super.key});

  @override
  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  String? _selectedPlan;
  bool _loading = false;
  int? _previewAmount;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sb = ref.read(supabaseMaybeProvider);
      if (sb == null) {
        setState(() => _error = 'Supabase ej konfigurerat.');
        return;
      }
      final res = await sb.rpc('preview_coupon', params: {
        'p_plan': _selectedPlan,
        'p_code': _codeCtrl.text.trim(),
      });
      if (!mounted) return;
      if (res is Map) {
        setState(
            () => _previewAmount = (res['pay_amount_cents'] as num?)?.toInt());
      } else {
        setState(() => _previewAmount = null);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _activateFree() async {
    final plan = _selectedPlan;
    if (plan == null) {
      showSnack(context, 'Välj en plan först.');
      return;
    }
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      setState(() => _error = 'Supabase ej konfigurerat.');
      return;
    }
    final user = sb.auth.currentUser;
    if (user == null) {
      final redirect = Uri.encodeComponent(
          '/subscribe?plan=$plan&code=${_codeCtrl.text.trim()}');
      context.ifMounted((c) => c.push('/login?redirect=$redirect'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await sb.rpc('redeem_coupon_and_provision', params: {
        'p_plan': plan,
        'p_code': _codeCtrl.text.trim(),
      });
      if (res is Map && (res['ok'] == true)) {
        context.ifMounted((c) => c.go('/home'));
      } else {
        setState(() => _error = 'Kunde inte aktivera.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const GoRouterBackButton(),
        title: const Text('Abonnemang'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: p16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Välj plan',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      gap12,
                      plans.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Text('Fel: $e'),
                        data: (items) {
                          if (items.isEmpty) {
                            return const Text('Inga planer.');
                          }
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final Map<String, dynamic> plan in items)
                                _PlanCard(
                                  plan: plan,
                                  selected: _selectedPlan == plan['id'],
                                  onSelect: () {
                                    final id = plan['id'];
                                    if (id is String) {
                                      setState(() => _selectedPlan = id);
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                      const Divider(height: 24),
                      TextField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kupong / invite-kod (valfritt)',
                          hintText: 'Ange kod…',
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                        onChanged: (_) => setState(() => _previewAmount = null),
                      ),
                      gap12,
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: (_selectedPlan == null || _loading)
                                ? null
                                : _preview,
                            icon: const Icon(Icons.visibility),
                            label: const Text('Förhandsgranska pris'),
                          ),
                          const SizedBox(width: 12),
                          if (_previewAmount != null)
                            Chip(
                              label: Text(
                                'Att betala: ${(_previewAmount! / 100).toStringAsFixed(0)} kr',
                              ),
                            ),
                        ],
                      ),
                      if (_error != null) ...[
                        gap8,
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      gap16,
                      Row(
                        children: [
                          FilledButton(
                            onPressed: (_selectedPlan != null &&
                                    (_previewAmount ?? 999999) > 0 &&
                                    !_loading)
                                ? () async {
                                    final url =
                                        await getCheckoutUrl(_selectedPlan!);
                                    showSnack(
                                      context,
                                      'Öppna betalning i webbläsare: $url',
                                    );
                                  }
                                : null,
                            child: const Text('Fortsätt till betalning'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: (_selectedPlan != null &&
                                    (_previewAmount ?? 1) == 0 &&
                                    !_loading)
                                ? _activateFree
                                : null,
                            child: const Text('Aktivera 0 kr'),
                          ),
                        ],
                      ),
                      gap8,
                      const Text(
                        'Tips: Sätt STRIPE_CHECKOUT_BASE via --dart-define för riktig Checkout-länk.',
                      ),
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

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onSelect;

  const _PlanCard(
      {required this.plan, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor =
        selected ? scheme.primary.withValues(alpha: 0.08) : Colors.white;
    final borderColor = selected ? scheme.primary : const Color(0xFFE2E8F0);
    final title = '${plan['name']}';
    final price = (plan['price_cents'] as int) ~/ 100;
    final interval = plan['interval'];
    return InkWell(
      onTap: onSelect,
      borderRadius: br12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 260,
        padding: p16,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: br12,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? scheme.primary : Colors.black26,
                  size: 22,
                ),
              ],
            ),
            gap8,
            Text(
              '$price kr / $interval',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: selected ? scheme.primary : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
