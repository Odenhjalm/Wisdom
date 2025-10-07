import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/env/app_config.dart';
import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/features/payments/application/payments_providers.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/go_router_back_button.dart';
import 'package:wisdom/widgets/base_page.dart';

class SubscribeScreen extends ConsumerStatefulWidget {
  const SubscribeScreen({super.key});

  @override
  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {
  Map<String, dynamic>? _selectedPlan;
  bool _loading = false;
  String? _statusMessage;
  String? _errorMessage;
  String? _activeSubscriptionId;
  String? _latestStatus;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    final envInfo = ref.watch(envInfoProvider);
    final authState = ref.watch(authControllerProvider);
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);
    final activeSubscription = subscriptionAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    final effectiveSubscriptionId = _activeSubscriptionId ??
        activeSubscription?['subscription_id'] as String?;
    final effectiveStatus =
        _latestStatus ?? activeSubscription?['status'] as String? ?? 'okänd';

    final envBlocked = envInfo.hasIssues;
    void cancelSubscription() {
      final id = effectiveSubscriptionId;
      if (envBlocked || _loading || id == null || authState.profile == null) {
        return;
      }
      _cancelSubscription(id);
    }

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
      body: BasePage(
        child: SafeArea(
          top: false,
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
                        if (envBlocked)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${envInfo.message} Abonnemang är avstängt tills konfigurationen är klar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        if (authState.profile == null)
                          _LoginPrompt(onRequestLogin: _redirectToLogin)
                        else
                          _SubscriptionStatusBadge(
                            status: effectiveStatus,
                            subscriptionId: effectiveSubscriptionId,
                            loading: subscriptionAsync.isLoading,
                          ),
                        gap16,
                        Text(
                          'Välj plan',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        gap12,
                        plans.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Fel: $e'),
                          data: (items) {
                            if (items.isEmpty) {
                              return const Text('Inga planer tillgängliga.');
                            }
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final plan in items)
                                  _PlanCard(
                                    plan: plan,
                                    selected: plan == _selectedPlan,
                                    onSelect: () => setState(() {
                                      _selectedPlan = plan;
                                      _errorMessage = null;
                                      _statusMessage = null;
                                    }),
                                  ),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 32),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_statusMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _statusMessage!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: envBlocked || _loading
                                    ? null
                                    : () =>
                                        _startSubscription(authState.profile),
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Starta prenumeration'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: envBlocked ||
                                        _loading ||
                                        effectiveSubscriptionId == null ||
                                        authState.profile == null
                                    ? null
                                    : cancelSubscription,
                                child: const Text('Avbryt prenumeration'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startSubscription(Profile? profile) async {
    if (profile == null) {
      _redirectToLogin();
      return;
    }
    final plan = _selectedPlan;
    if (plan == null) {
      showSnack(context, 'Välj en plan först.');
      return;
    }

    final config = ref.read(appConfigProvider);
    if (config.stripePublishableKey.isEmpty) {
      setState(() {
        _errorMessage =
            'Stripe publishable key saknas. Lägg till STRIPE_PUBLISHABLE_KEY i .env eller via --dart-define.';
      });
      return;
    }

    final priceId = _extractPriceId(plan);
    if (priceId == null) {
      setState(() {
        _errorMessage = 'Planen saknar kopplad Stripe price.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final result = await repo.createSubscription(
        userId: profile.id,
        priceId: priceId,
      );

      _activeSubscriptionId = result.subscriptionId;
      _latestStatus = result.status ?? 'incomplete';

      final clientSecret = result.clientSecret;
      if (clientSecret != null && clientSecret.isNotEmpty) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: config.stripeMerchantDisplayName,
          ),
        );
        await Stripe.instance.presentPaymentSheet();
        _statusMessage =
            'Betalning slutförd. Det kan ta en liten stund innan Stripe bekräftar prenumerationen.';
      } else {
        _statusMessage =
            'Prenumerationen skapades. Om betalning krävs kommer Stripe att skicka vidare instruktioner.';
      }

      ref.invalidate(activeSubscriptionProvider);
    } on StripeException catch (error) {
      setState(() {
        _errorMessage = error.error.message ?? 'Betalningen avbröts.';
        _statusMessage = null;
      });
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (failure.kind == AppFailureKind.unauthorized) {
        _redirectToLogin();
        return;
      }
      setState(() {
        _errorMessage = failure.message;
        _statusMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(paymentsRepositoryProvider);
      await repo.cancelSubscription(subscriptionId);
      _statusMessage =
          'Prenumerationen avbröts. Du har fortsatt tillgång tills perioden löper ut.';
      _latestStatus = 'canceled';
      ref.invalidate(activeSubscriptionProvider);
    } on AppFailure catch (failure) {
      setState(() {
        _errorMessage = failure.message;
      });
    } catch (error, stackTrace) {
      setState(() {
        _errorMessage = AppFailure.from(error, stackTrace).message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    final redirect = Uri(path: '/subscribe').toString();
    context.push('/login?redirect=${Uri.encodeComponent(redirect)}');
  }

  String? _extractPriceId(Map<String, dynamic> plan) {
    final stripePrice = plan['stripe_price_id'];
    if (stripePrice is String && stripePrice.trim().isNotEmpty) {
      return stripePrice;
    }
    final priceId = plan['price_id'];
    if (priceId is String && priceId.trim().isNotEmpty) {
      return priceId;
    }
    final id = plan['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }
    return null;
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onSelect,
  });

  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor =
        selected ? scheme.primary.withValues(alpha: 0.08) : Colors.white;
    final borderColor = selected ? scheme.primary : const Color(0xFFE2E8F0);
    final priceCents = (plan['price_cents'] as num?)?.toInt() ?? 0;
    final interval = plan['interval'] ?? '';

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
                    '${plan['name']}',
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
              '${(priceCents / 100).toStringAsFixed(0)} kr / $interval',
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

class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({
    required this.status,
    required this.subscriptionId,
    required this.loading,
  });

  final String status;
  final String? subscriptionId;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final label = subscriptionId == null
        ? 'Ingen aktiv prenumeration'
        : 'Status: ${status.toUpperCase()} (ID: $subscriptionId)';
    final color = subscriptionId == null
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;
    return Card(
      color: color.withValues(alpha: 0.08),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              subscriptionId == null ? Icons.info_outline : Icons.verified_user,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            if (loading)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onRequestLogin});

  final VoidCallback onRequestLogin;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logga in för att fortsätta',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            gap8,
            const Text(
              'Du behöver ett konto för att starta eller hantera din prenumeration.',
            ),
            gap12,
            FilledButton(
              onPressed: onRequestLogin,
              child: const Text('Logga in'),
            ),
          ],
        ),
      ),
    );
  }
}
