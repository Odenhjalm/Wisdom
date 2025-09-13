import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Supa {
  static Future<void> init() async {
    final url = dotenv.get('SUPABASE_URL', fallback: '');
    final anon = dotenv.get('SUPABASE_ANON', fallback: '');
    await Supabase.initialize(
      url: url,
      anonKey: anon,
      // authFlowType: AuthFlowType.pkce,  // <-- ta bort i din version
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
