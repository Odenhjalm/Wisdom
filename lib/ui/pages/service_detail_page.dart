import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';
import 'package:andlig_app/domain/services/payments/payments_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:go_router/go_router.dart';

class ServiceDetailPage extends StatefulWidget {
  final String id;
  const ServiceDetailPage({super.key, required this.id});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  Map<String, dynamic>? _service;
  Map<String, dynamic>? _provider;
  bool _loading = true;
  bool _buying = false;
  final _payments = PaymentsService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sb = Supabase.instance.client;
    final s = await sb.app
        .from('services')
        .select('id, provider_id, title, description, price_cents, active')
        .eq('id', widget.id)
        .maybeSingle();
    Map<String, dynamic>? prof;
    if (s != null) {
      prof = await sb.app
          .from('profiles')
          .select('user_id, display_name, photo_url')
          .eq('user_id', (s as Map)['provider_id'])
          .maybeSingle();
    }
    if (!mounted) return;
    setState(() {
      _service = (s as Map?)?.cast<String, dynamic>();
      _provider = (prof as Map?)?.cast<String, dynamic>();
      _loading = false;
    });
  }

  Future<void> _buy() async {
    final s = _service;
    if (s == null) return;
    final price = (s['price_cents'] as int?) ?? 0;
    final id = s['id'] as String;
    setState(() => _buying = true);
    try {
      final order =
          await _payments.startServiceOrder(serviceId: id, amountCents: price);
      final url = await _payments.createCheckoutSession(
        orderId: order['id'] as String,
        amountCents: price,
        successUrl:
            'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
      );
      if (url != null) await launchUrlString(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kunde inte initiera köp: $e')));
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_loading) {
      return const AppScaffold(
          title: 'Tjänst', body: Center(child: CircularProgressIndicator()));
    }
    final s = _service;
    if (s == null) {
      return const AppScaffold(
          title: 'Tjänst', body: Center(child: Text('Tjänst hittades inte')));
    }
    final title = (s['title'] as String?) ?? 'Tjänst';
    final desc = (s['description'] as String?) ?? '';
    final price = ((s['price_cents'] as int?) ?? 0) / 100.0;
    final prov = _provider;

    return AppScaffold(
      title: title,
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: Text(prov?['display_name'] as String? ?? 'Lärare'),
              subtitle: const Text('Leverantör'),
              onTap: () {
                final id = prov?['user_id'] as String?;
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
                  Text(title,
                      style:
                          t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
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
                        onPressed: _buying ? null : _buy,
                        child: _buying
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
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
  }
}
