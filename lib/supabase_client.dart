import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/auth/oauth_redirect.dart';
import 'core/env/env_state.dart';

import 'gate.dart';

bool _initialized = false;
String? _authRedirect;
bool _gateOpen = false;
EnvInfo _envInfo = envInfoOk;

const String kAppRedirect = 'visdom://auth-callback';

const String _supabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String _supabaseAnon =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
const String _supabaseAnonAlt =
    String.fromEnvironment('SUPABASE_ANON', defaultValue: '');
const String _supabaseRedirectDefine =
    String.fromEnvironment('SUPABASE_AUTH_REDIRECT', defaultValue: '');

String? get supabaseRedirectUrl => _authRedirect;

EnvInfo get currentEnvInfo => _envInfo;

Future<EnvInfo> initSupabase() async {
  if (_initialized) return _envInfo;

  var url = _supabaseUrl.trim();
  var anon = _supabaseAnon.trim().isNotEmpty
      ? _supabaseAnon.trim()
      : _supabaseAnonAlt.trim();
  var redirect = _supabaseRedirectDefine.trim();

  if (url.isEmpty || anon.isEmpty || redirect.isEmpty) {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
    } catch (_) {}
    url = (dotenv.env['SUPABASE_URL'] ?? url).trim();
    anon =
        (dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_ANON'] ?? anon)
            .trim();
    redirect = (dotenv.env['SUPABASE_AUTH_REDIRECT'] ?? redirect).trim();
  }

  final missingKeys = <String>[];
  if (url.isEmpty) missingKeys.add('SUPABASE_URL');
  if (anon.isEmpty) missingKeys.add('SUPABASE_ANON_KEY');

  if (missingKeys.isNotEmpty) {
    _envInfo = EnvInfo(status: EnvStatus.missing, missingKeys: missingKeys);
    return _envInfo;
  }

  final resolvedRedirect = _resolveRedirect(redirect);

  await Supabase.initialize(
    url: url,
    anonKey: anon,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
    realtimeClientOptions:
        const RealtimeClientOptions(logLevel: RealtimeLogLevel.warn),
    debug: true,
  );

  _authRedirect = resolvedRedirect;
  _initialized = true;
  _envInfo = envInfoOk;
  final client = Supabase.instance.client;
  final existingSession = client.auth.currentSession;
  final initialUser = existingSession?.user.id ?? 'null';
  debugPrint('[AUTH] initialSession user=$initialUser');
  if (existingSession != null) {
    _openGate('init', userId: existingSession.user.id);
  } else {
    _closeGate('init');
  }
  client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final userId = data.session?.user.id ?? 'null';
    debugPrint('[AUTH] event=${event.name} user=$userId');
    switch (event) {
      case AuthChangeEvent.signedIn:
        _openGate('signedIn', userId: userId);
        break;
      case AuthChangeEvent.signedOut:
        _closeGate(event.name);
        break;
      case AuthChangeEvent.tokenRefreshed:
        debugPrint('[GATE] tokenRefreshed user=$userId');
        _logGateState();
        break;
      default:
        if (event.name == 'userDeleted') {
          _closeGate(event.name);
        } else {
          _logGateState();
        }
        break;
    }
  });
  debugPrint('Supabase init completed');

  return _envInfo;
}

String _resolveRedirect(String redirect) {
  if (redirect.isNotEmpty) {
    return redirect;
  }
  final helper = _maybeOauthRedirect();
  if (helper != null && helper.isNotEmpty) {
    return helper;
  }
  return _fallbackRedirect();
}

String supabaseAuthRedirect({Uri? webUri}) {
  final resolved = _authRedirect;
  if (resolved != null && resolved.isNotEmpty) {
    return resolved;
  }
  final helper = _maybeOauthRedirect();
  if (helper != null && helper.isNotEmpty) {
    return helper;
  }
  return _fallbackRedirect(webUri: webUri);
}

String _fallbackRedirect({Uri? webUri}) {
  if (kIsWeb) {
    final base = (webUri ?? Uri.base);
    final origin = base.origin;
    return '$origin/auth-callback';
  }
  return kAppRedirect;
}

String? _maybeOauthRedirect() {
  try {
    return oauthRedirect();
  } catch (_) {
    return null;
  }
}

final sessionStreamProvider = StreamProvider<Session?>((ref) async* {
  if (!_initialized) {
    yield null;
    return;
  }
  final client = Supabase.instance.client;
  yield client.auth.currentSession;
  yield* client.auth.onAuthStateChange.map((event) => event.session);
});

final supabaseProvider = Provider<SupabaseClient>((ref) {
  ref.watch(sessionStreamProvider);
  if (!_initialized) {
    throw StateError(
        'Supabase är inte initierat. Anropa initSupabase() i main().');
  }
  return Supabase.instance.client;
});

bool get isLoggedIn {
  try {
    return _initialized && Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    return false;
  }
}

bool get isSupabaseReady => _initialized;

final supabaseMaybeProvider = Provider<SupabaseClient?>((ref) {
  ref.watch(sessionStreamProvider);
  return _initialized ? Supabase.instance.client : null;
});

// Simple helper to form a Checkout URL (uses --dart-define then .env fallback; otherwise placeholder)
const String _stripeCheckoutBaseDefine =
    String.fromEnvironment('STRIPE_CHECKOUT_BASE', defaultValue: '');

Future<String> getCheckoutUrl(String planId) async {
  var base = _stripeCheckoutBaseDefine;
  if (base.isEmpty) {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
    } catch (_) {}
    base = dotenv.env['STRIPE_CHECKOUT_BASE'] ?? '';
  }

  final uid = _initialized
      ? (Supabase.instance.client.auth.currentUser?.id ?? 'anon')
      : 'anon';
  if (base.isEmpty) {
    return 'https://example.com/checkout?plan=$planId&user=$uid';
  }
  return '$base?plan=$planId&user=$uid';
}

// Direct client getter (no init here; Supabase.initialize happens in main.dart)
SupabaseClient get supa => Supabase.instance.client;

void _openGate(String reason, {required String userId}) {
  if (_gateOpen) {
    debugPrint('[GATE] allow($reason) skipped (already open)');
    _logGateState();
    return;
  }
  gate.allow();
  _gateOpen = true;
  debugPrint('[GATE] allow($reason) user=$userId');
  _logGateState();
}

void _closeGate(String reason) {
  if (!_gateOpen) {
    debugPrint('[GATE] reset($reason) skipped (already closed)');
    _logGateState();
    return;
  }
  gate.reset();
  _gateOpen = false;
  debugPrint('[GATE] reset($reason)');
  _logGateState();
}

void _logGateState() {
  debugPrint('[GATE] open=$_gateOpen');
}
