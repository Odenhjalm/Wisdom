import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' show SupabaseQuerySchema;

extension AppSchema on SupabaseClient {
  SupabaseQuerySchema get app => schema('app');
}
