import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/data/repositories/profile_repository.dart';
import 'package:wisdom/domain/models/user_access.dart';
import 'package:wisdom/features/studio/data/certificates_repository.dart';
import 'package:wisdom/supabase_client.dart';

import '../../../core/supabase_ext.dart';

Future<TeacherApprovalInfo> _loadTeacherApproval(
  SupabaseClient client,
  String userId,
) async {
  try {
    final res = await client.app
        .from('teacher_approvals')
        .select('approved_by, approved_at')
        .eq('user_id', userId)
        .maybeSingle();
    if (res == null) return TeacherApprovalInfo.empty;
    return TeacherApprovalInfo.fromJson(
      Map<String, dynamic>.from(res as Map),
    );
  } catch (_) {
    // ignore and fall through to empty state
  }
  return TeacherApprovalInfo.empty;
}

TeacherApplication? _toTeacherApplication(Certificate? certificate) {
  if (certificate == null) return null;
  return TeacherApplication(certificate: certificate);
}

UserRole _resolveEffectiveRole(
  Profile profile,
  TeacherApprovalInfo approval,
  TeacherApplication? application,
) {
  if (profile.isAdmin) return UserRole.teacher;
  if (profile.isTeacher) return UserRole.teacher;
  if (approval.isApproved) return UserRole.teacher;
  if (application?.isApproved == true) return UserRole.teacher;
  return profile.userRole;
}

final userAccessProvider = FutureProvider<UserAccessState>((ref) async {
  final client = ref.watch(supabaseMaybeProvider);
  if (client == null) {
    return UserAccessState.unauthenticated;
  }

  final user = client.auth.currentUser;
  if (user == null) {
    return UserAccessState.unauthenticated;
  }

  final profileRepo = ProfileRepository(client: client);
  final profile = await profileRepo.getMe();
  if (profile == null) {
    return UserAccessState.unauthenticated;
  }

  final certificatesRepo = CertificatesRepository(client: client);
  final applicationCert =
      await certificatesRepo.teacherApplicationOf(profile.id);
  final application = _toTeacherApplication(applicationCert);
  final approval = await _loadTeacherApproval(client, profile.id);

  final effectiveRole = _resolveEffectiveRole(profile, approval, application);
  final effectiveProfile = profile.copyWith(userRole: effectiveRole);

  return UserAccessState(
    profile: profile,
    effectiveProfile: effectiveProfile,
    approval: approval,
    application: application,
  );
});
