import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/supabase_client.dart';

class LandingSectionState {
  const LandingSectionState({
    required this.items,
    this.errorMessage,
    this.devHint,
  });

  final List<Map<String, dynamic>> items;
  final String? errorMessage;
  final String? devHint;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty;
}

List<Map<String, dynamic>> _castList(dynamic value) {
  final list = value as List?;
  if (list == null) return const <Map<String, dynamic>>[];
  return list
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList(growable: false);
}

LandingSectionState _landingSuccessState(List<Map<String, dynamic>> items) {
  return LandingSectionState(
    items: items,
    devHint: items.isEmpty ? _devHintMessage : null,
  );
}

LandingSectionState _landingErrorState(
    {String message = 'Kunde inte hämta innehållet just nu.'}) {
  return LandingSectionState(
    items: const <Map<String, dynamic>>[],
    errorMessage: message,
    devHint: _devHintMessage,
  );
}

String? get _devHintMessage =>
    kDebugMode ? 'Konfigurera Supabase i .env om data saknas.' : null;

final introCoursesProvider = FutureProvider<LandingSectionState>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  if (sb == null) {
    return _landingErrorState();
  }
  try {
    final query = sb
        .schema('app')
        .from('courses')
        .select(
          'id, title, description, cover_url, video_url, is_free_intro, branch, price_cents, created_at',
        )
        .eq('is_free_intro', true)
        .order('created_at', ascending: false)
        .limit(5);
    final res = await query.timeout(const Duration(seconds: 12));
    final items = _castList(res);
    return _landingSuccessState(items);
  } on TimeoutException catch (_) {
    return _landingErrorState(
      message: 'Tidsgränsen gick ut när vi hämtade gratiskurser.',
    );
  } on PostgrestException catch (_) {
    return _landingErrorState(
      message: 'Kunde inte hämta gratiskurser just nu.',
    );
  } catch (_) {
    return _landingErrorState(
      message: 'Något gick fel när vi hämtade gratiskurser.',
    );
  }
});

final popularCoursesProvider = FutureProvider<LandingSectionState>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  if (sb == null) {
    return _landingErrorState();
  }
  try {
    final query = sb
        .schema('app')
        .from('courses')
        .select(
          'id, title, description, cover_url, video_url, is_free_intro, branch, price_cents, created_at',
        )
        .order('is_free_intro', ascending: false)
        .order('created_at', ascending: false)
        .limit(6);
    final res = await query.timeout(const Duration(seconds: 12));
    final items = _castList(res);
    return _landingSuccessState(items);
  } on TimeoutException catch (_) {
    return _landingErrorState(
      message: 'Tidsgränsen gick ut när vi hämtade kurser.',
    );
  } on PostgrestException catch (_) {
    return _landingErrorState(
      message: 'Kunde inte hämta kurslistan just nu.',
    );
  } catch (_) {
    return _landingErrorState(
      message: 'Något gick fel när vi hämtade kurslistan.',
    );
  }
});

final teachersProvider = FutureProvider<LandingSectionState>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  if (sb == null) {
    return _landingErrorState();
  }
  try {
    final query = sb
        .schema('app')
        .from('profiles')
        .select('user_id, display_name, photo_url, bio')
        .inFilter('role', ['teacher', 'admin'])
        .order('display_name', ascending: true)
        .limit(20);
    final res = await query.timeout(const Duration(seconds: 12));
    final items = _castList(res);
    return _landingSuccessState(items);
  } on TimeoutException catch (_) {
    return _landingErrorState(
      message: 'Tidsgränsen gick ut när vi hämtade lärarna.',
    );
  } on PostgrestException catch (_) {
    return _landingErrorState(
      message: 'Kunde inte hämta lärarlistan just nu.',
    );
  } catch (_) {
    return _landingErrorState(
      message: 'Något gick fel när vi hämtade lärarlistan.',
    );
  }
});

final recentServicesProvider = FutureProvider<LandingSectionState>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  if (sb == null) {
    return _landingErrorState();
  }
  try {
    final query = sb
        .schema('app')
        .from('services')
        .select(
          'id, title, description, price_cents, duration_min, requires_cert, certified_area, created_at',
        )
        .eq('active', true)
        .order('created_at', ascending: false)
        .limit(6);
    final res = await query.timeout(const Duration(seconds: 12));
    final items = _castList(res);
    return _landingSuccessState(items);
  } on TimeoutException catch (_) {
    return _landingErrorState(
      message: 'Tidsgränsen gick ut när vi hämtade tjänsterna.',
    );
  } on PostgrestException catch (_) {
    return _landingErrorState(
      message: 'Kunde inte hämta tjänsterna just nu.',
    );
  } catch (_) {
    return _landingErrorState(
      message: 'Något gick fel när vi hämtade tjänsterna.',
    );
  }
});
