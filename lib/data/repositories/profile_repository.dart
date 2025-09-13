import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/data/models/profile.dart';

class ProfileRepository {
  Future<Profile?> getMe() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return null;
    final res = await Supa.client
        .from('profiles')
        .select()
        .eq('id', u.id)
        .maybeSingle();
    if (res == null) return null;
    return Profile.fromJson(res as Map<String, dynamic>);
  }
}
