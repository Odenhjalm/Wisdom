import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String _defaultAppRedirect = 'wisdom://auth-callback';

String? _cleanValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Returns the best-effort redirect URL for Supabase OAuth / password recovery.
/// Falls back to sensible defaults if env keys are missing so the app keeps running.
String oauthRedirect() {
  final web = _cleanValue(dotenv.env['AUTH_REDIRECT_WEB']);
  final desktop = _cleanValue(dotenv.env['AUTH_REDIRECT_DESKTOP']);
  final app = _cleanValue(dotenv.env['AUTH_REDIRECT_APP']);

  if (kIsWeb) {
    return web ?? '${Uri.base.origin}/auth-callback';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return app ?? _defaultAppRedirect;
    default:
      return desktop ?? _defaultAppRedirect;
  }
}
