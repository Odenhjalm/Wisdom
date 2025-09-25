import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/core/supabase_ext.dart';

final _sb = Supabase.instance.client;

class AuthProfileRepository {
  /// Logga in om kontot finns, annars skapa det. Skapar/updaterar profil i båda fallen.
  Future<User?> signInOrSignUp({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await _sb.auth.signInWithPassword(email: email, password: password);
      await _ensureProfile(res.user!);
      return res.user;
    } on AuthException {
      final res = await _sb.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await _ensureProfile(res.user!); // <— den här saknades hos dig
      }
      return res.user;
    }
  }

  Future<void> _ensureProfile(User user) async {
    final displayName = user.email?.split('@').first ?? 'Användare';
    final payload = {
      'user_id': user.id,
      'email': user.email,
      'display_name': displayName,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await _sb.app
          .from('profiles')
          .upsert(payload, onConflict: 'user_id', ignoreDuplicates: false);
    } on PostgrestException {
      // Fallback till RPC om tabellåtkomst saknas i miljön
      await _sb.schema('app').rpc('ensure_profile', params: {
        'p_email': user.email,
        'p_display_name': displayName,
      });
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;
    final res = await _sb.schema('app').rpc('get_my_profile');
    if (res == null) return null;
    if (res is Map) return res.cast<String, dynamic>();
    if (res is List && res.isNotEmpty) {
      return Map<String, dynamic>.from(res.first as Map);
    }
    return null;
  }

  Future<void> signOut() => _sb.auth.signOut();
}
