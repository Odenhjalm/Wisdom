import 'package:supabase_flutter/supabase_flutter.dart';

import '../../supabase_client.dart' as core;

class Supa {
  static Future<void> init() => core.initSupabase();

  static SupabaseClient get client => core.supa;
}
