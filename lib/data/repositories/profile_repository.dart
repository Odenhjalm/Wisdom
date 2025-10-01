import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/data/supabase/supabase_client.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client}) : _client = client ?? Supa.client;

  final SupabaseClient _client;

  Future<Profile?> getMe() async {
    final u = _client.auth.currentUser;
    if (u == null) return null;
    final res = await _client.rpc('app.get_my_profile');
    if (res == null) return null;
    final row = (res is Map)
        ? res
        : ((res is List && res.isNotEmpty) ? res.first : null);
    if (row == null) return null;
    return Profile.fromJson((row as Map).cast<String, dynamic>());
  }
}
