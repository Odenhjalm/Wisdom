import 'package:supabase_flutter/supabase_flutter.dart';

extension AppSchema on SupabaseClient {
  SupabaseQuerySchema get app => schema('app');
}
