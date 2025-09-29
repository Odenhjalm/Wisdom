import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wisdom/supabase_client.dart';

import '../data/certificates_repository.dart';
import '../data/studio_repository.dart';
import '../data/teacher_repository.dart';

final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  return StudioRepository();
});

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository();
});

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  return CertificatesRepository();
});

final myCoursesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final sb = ref.read(supabaseMaybeProvider);
  final uid = sb?.auth.currentUser?.id;
  if (sb == null || uid == null) return const <Map<String, dynamic>>[];
  final res = await sb
      .schema('app')
      .from('courses')
      .select(
          'id, title, cover_url, video_url, is_free_intro, branch, created_by, created_at')
      .eq('created_by', uid)
      .order('created_at', ascending: false);
  final list = res as List?;
  if (list == null) return const <Map<String, dynamic>>[];
  return list
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList(growable: false);
});
