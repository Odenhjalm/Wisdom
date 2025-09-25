import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:visdom/supabase_client.dart';

final plansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  if (sb == null) return const <Map<String, dynamic>>[];
  final res = await sb
      .from('subscription_plans')
      .select('id,name,price_cents,interval,is_active')
      .eq('is_active', true)
      .order('price_cents');
  final list = res as List?;
  if (list == null) return const <Map<String, dynamic>>[];
  return list
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList(growable: false);
});

final activeSubscriptionProvider = FutureProvider<bool>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  final uid = sb?.auth.currentUser?.id;
  if (uid == null || sb == null) return false;
  final res = await sb
      .from('subscriptions')
      .select('id,status,current_period_end')
      .eq('user_id', uid)
      .eq('status', 'active')
      .gte('current_period_end', DateTime.now().toUtc().toIso8601String())
      .limit(1);
  final list = res as List?;
  return list != null && list.isNotEmpty;
});
