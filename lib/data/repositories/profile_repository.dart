import 'package:andlig_app/data/supabase/supabase_client.dart';
import 'package:andlig_app/data/models/profile.dart';

class ProfileRepository {
  Future<Profile?> getMe() async {
    final u = Supa.client.auth.currentUser;
    if (u == null) return null;
    final res = await Supa.client.rpc('app.get_my_profile');
    if (res == null) return null;
    final row = (res is Map)
        ? res
        : ((res is List && res.isNotEmpty) ? res.first : null);
    if (row == null) return null;
    return Profile.fromJson((row as Map).cast<String, dynamic>());
  }
}
