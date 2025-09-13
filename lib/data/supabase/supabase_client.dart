import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Supa {
  static Future<void> init() async {
    // Stötta både SUPABASE_ANON och SUPABASE_ANON_KEY + trimma ev. felskrivna tecken
    String _v(String key) => (dotenv.maybeGet(key) ?? '').trim();
    final rawUrl = _v('SUPABASE_URL');
    // Ta bort ev. backslash som hamnat i .env vid radbrytning
    final url = rawUrl.replaceAll('\\\n', '').replaceAll('\\', '').trim();
    final anon = _v('SUPABASE_ANON').isNotEmpty
        ? _v('SUPABASE_ANON')
        : _v('SUPABASE_ANON_KEY');

    await Supabase.initialize(
      url: url,
      anonKey: anon,
      // PKCE auth flow
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
