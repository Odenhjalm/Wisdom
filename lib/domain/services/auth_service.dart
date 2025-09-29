import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisdom/data/models/profile.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<bool> isTeacher() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    Future<Map<String, dynamic>?> fetchPermissions() async {
      final attempts = [
        () => _client
            .schema('app')
            .from('teacher_permissions')
            .select('can_edit_courses, can_publish')
            .eq('profile_id', user.id)
            .maybeSingle(),
        () => _client
            .from('teacher_permissions_compat')
            .select('can_edit_courses, can_publish')
            .eq('profile_id', user.id)
            .maybeSingle(),
        () => _client
            .from('teacher_permissions')
            .select('can_edit_courses, can_publish')
            .eq('user_id', user.id)
            .maybeSingle(),
      ];

      for (final attempt in attempts) {
        try {
          final res = await attempt();
          if (res is Map<String, dynamic> && res.isNotEmpty) {
            return res;
          }
          if (res is Map) {
            final map = res as Map;
            if (map.isNotEmpty) {
              return Map<String, dynamic>.from(map);
            }
          }
        } on PostgrestException {
          // try next source
        }
      }
      return null;
    }

    final perms = await fetchPermissions();
    if (perms != null) {
      final canEdit = perms['can_edit_courses'] == true;
      final canPublish = perms['can_publish'] == true;
      if (canEdit || canPublish) return true;
    }

    try {
      final profileMap = await _client
          .schema('app')
          .from('profiles')
          .select('user_id, role, role_v2, is_admin')
          .eq('user_id', user.id)
          .maybeSingle();
      if (profileMap is Map<String, dynamic>) {
        final profile = Profile.fromJson(profileMap);
        if (profile.isAdmin || profile.isTeacher) {
          return true;
        }
      }
    } on PostgrestException {
      // ignore
    }

    return false;
  }

  static Future<bool> isTeacherFor({SupabaseClient? client}) {
    return AuthService(client: client).isTeacher();
  }
}

Future<bool> userIsTeacher({SupabaseClient? client}) {
  return AuthService.isTeacherFor(client: client);
}
