import 'dart:async';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisdom/core/supabase_ext.dart';

class PaymentsService {
  final SupabaseClient _sb;
  PaymentsService({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>> startCourseOrder(
      {required String courseId,
      required int amountCents,
      String currency = 'sek'}) async {
    final res = await _sb.schema('app').rpc('start_order', params: {
      'p_course_id': courseId,
      'p_amount_cents': amountCents,
      'p_currency': currency,
    });
    if (res is Map<String, dynamic>) return res;
    if (res is List && res.isNotEmpty) {
      return Map<String, dynamic>.from(res.first as Map);
    }
    throw Exception('Kunde inte skapa order');
  }

  Future<Map<String, dynamic>> startServiceOrder(
      {required String serviceId,
      required int amountCents,
      String currency = 'sek'}) async {
    final res = await _sb.schema('app').rpc('start_service_order', params: {
      'p_service_id': serviceId,
      'p_amount_cents': amountCents,
      'p_currency': currency,
    });
    if (res is Map<String, dynamic>) return res;
    if (res is List && res.isNotEmpty) {
      return Map<String, dynamic>.from(res.first as Map);
    }
    throw Exception('Kunde inte skapa order');
  }

  Future<String?> createCheckoutSession({
    required String orderId,
    required int amountCents,
    String currency = 'sek',
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
  }) async {
    final res = await _sb.functions.invoke('stripe_checkout', body: {
      'order_id': orderId,
      'amount_cents': amountCents,
      'currency': currency,
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      if (customerEmail != null) 'customer_email': customerEmail,
    });
    final data = res.data;
    if (data is Map && data['url'] is String) return data['url'] as String;
    return null;
  }

  /// Subscribe to order row updates; returns a cancel function.
  Future<VoidCallback> watchOrderStatus(
      {required String orderId,
      required void Function(Map<String, dynamic> row) onUpdate}) async {
    final channel = _sb
        .channel('order-$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'app',
          table: 'orders',
          callback: (payload) {
            final newRow =
                (payload.newRecord as Map?)?.cast<String, dynamic>() ??
                    const {};
            // Manual filter to only emit updates for this order
            if (newRow['id'] != orderId) return;
            onUpdate(newRow);
          },
        )
        .subscribe();

    return () async {
      await _sb.removeChannel(channel);
    };
  }

  Future<Map<String, dynamic>?> fetchOrder(String orderId) async {
    final row = await _sb.app
        .from('orders')
        .select(
            'id, status, amount_cents, stripe_checkout_id, stripe_payment_intent, updated_at, created_at')
        .eq('id', orderId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }
}
