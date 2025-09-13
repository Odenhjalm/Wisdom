import 'package:supabase_flutter/supabase_flutter.dart';

final _sb = Supabase.instance.client;

class AuthProfileService {
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
    // Använd RPC för att undvika schema-header-problem vid login
    await _sb.schema('app').rpc('ensure_profile', params: {
      'p_email': user.email,
      'p_display_name': user.email?.split('@').first ?? 'Användare',
    });
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;
    final res = await _sb.schema('app').rpc('get_my_profile');
    if (res == null) return null;
    if (res is Map) return res.cast<String, dynamic>();
    if (res is List && res.isNotEmpty) return Map<String, dynamic>.from(res.first as Map);
    return null;
  }

  Future<void> signOut() => _sb.auth.signOut();
}
