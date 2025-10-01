import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/core/supabase_ext.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<bool> isTeacher() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final profileMap = await _client
          .schema('app')
          .from('profiles')
          .select('user_id, role, role_v2, is_admin')
          .eq('user_id', user.id)
          .maybeSingle();

      final profile = _mapProfile(profileMap);
      if (profile == null) return false;
      if (profile.isAdmin || profile.isTeacher) return true;

      final approval = await _client.app
          .from('teacher_approvals')
          .select('approved_at')
          .eq('user_id', user.id)
          .maybeSingle();
      if (_hasApproval(approval)) return true;

      final certificate = await _client.app
          .from('certificates')
          .select('status')
          .eq('user_id', user.id)
          .eq('title', Certificate.teacherApplicationTitle)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (_isVerifiedCertificate(certificate)) return true;
    } on PostgrestException {
      // ignore and fall through to false
    }

    return false;
  }

  static Future<bool> isTeacherFor({SupabaseClient? client}) {
    return AuthService(client: client).isTeacher();
  }

  Profile? _mapProfile(Object? profileMap) {
    if (profileMap is Map<String, dynamic>) {
      return Profile.fromJson(profileMap);
    }
    if (profileMap is Map) {
      return Profile.fromJson(Map<String, dynamic>.from(profileMap));
    }
    return null;
  }

  bool _hasApproval(Object? approval) {
    if (approval is Map) {
      return approval['approved_at'] != null;
    }
    return false;
  }

  bool _isVerifiedCertificate(Object? certificate) {
    if (certificate is Map) {
      final status = (certificate['status'] as String?)?.toLowerCase();
      return status == 'verified';
    }
    return false;
  }
}

Future<bool> userIsTeacher({SupabaseClient? client}) {
  return AuthService.isTeacherFor(client: client);
}
