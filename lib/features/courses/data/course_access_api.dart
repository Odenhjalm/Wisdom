import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CourseAccessApi {
  Future<bool> hasAccess(String courseId);
  Future<bool> fallbackHasAccess(String courseId);
}

class SupabaseCourseAccessApi implements CourseAccessApi {
  SupabaseCourseAccessApi(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> hasAccess(String courseId) async {
    final res = await _client.rpc('user_has_course_access', params: {
      'p_course': courseId,
    });
    if (res is bool) return res;
    if (res is Map && res.values.whereType<bool>().isNotEmpty) {
      return res.values.whereType<bool>().first;
    }
    return false;
  }

  @override
  Future<bool> fallbackHasAccess(String courseId) async {
    final res = await _client
        .schema('app')
        .rpc('can_access_course', params: {'p_course': courseId});
    if (res is bool) return res;
    if (res is Map && res['can_access_course'] is bool) {
      return res['can_access_course'] as bool;
    }
    return false;
  }
}
