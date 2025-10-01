import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/domain/services/payments/payments_service.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class ServiceDetailPage extends ConsumerStatefulWidget {
  const ServiceDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends ConsumerState<ServiceDetailPage> {
  bool _buying = false;

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceDetailProvider(widget.id));
    return serviceAsync.when(
      loading: () => const AppScaffold(
        title: 'Tjänst',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Tjänst',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (state) {
        final service = state.service;
        if (service == null) {
          return const AppScaffold(
            title: 'Tjänst',
            body: Center(child: Text('Tjänst hittades inte')),
          );
        }
        final provider = state.provider;
        final t = Theme.of(context).textTheme;
        final title = (service['title'] as String?) ?? 'Tjänst';
        final desc = (service['description'] as String?) ?? '';
        final price = ((service['price_cents'] as int?) ?? 0) / 100.0;

        return AppScaffold(
          title: title,
          body: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: Text(provider?['display_name'] as String? ?? 'Lärare'),
                  subtitle: const Text('Leverantör'),
                  onTap: () {
                    final id = provider?['user_id'] as String?;
                    if (id != null) context.push('/profile/$id');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(desc, style: t.bodyMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('${price.toStringAsFixed(2)} kr',
                              style: t.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _buying ? null : () => _buy(service),
                            child: _buying
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Boka/Köp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _buy(Map<String, dynamic> service) async {
    final price = (service['price_cents'] as int?) ?? 0;
    final id = service['id'] as String;
    setState(() => _buying = true);
    try {
      final payments = PaymentsService();
      final order = await payments.startServiceOrder(
        serviceId: id,
        amountCents: price,
      );
      final url = await payments.createCheckoutSession(
        orderId: order['id'] as String,
        amountCents: price,
        successUrl:
            'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
      );
      if (url != null) {
        await launchUrlString(url);
      } else {
        _showSnack('Kunde inte initiera betalning.');
      }
    } catch (error) {
      _showSnack('Kunde inte initiera köp: ${_friendlyError(error)}');
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    showSnack(context, message);
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
