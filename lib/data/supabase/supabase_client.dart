import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/supabase_client.dart' as core;

class Supa {
  static Future<EnvInfo> init() => core.initSupabase();

  static bool get isReady => core.isSupabaseReady;

  static EnvInfo get envInfo => core.currentEnvInfo;

  static SupabaseClient get client => core.supa;

  static SupabaseClient? get maybeClient =>
      core.isSupabaseReady ? core.supa : null;
}
