import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:andlig_app/core/supabase_ext.dart';

class FollowsService {
  final _sb = Supabase.instance.client;

  Future<void> follow(String userId) async {
    await _sb.schema('app').rpc('follow', params: {'p_user': userId});
  }

  Future<void> unfollow(String userId) async {
    await _sb.schema('app').rpc('unfollow', params: {'p_user': userId});
  }

  Future<List<String>> followersOf(String userId) async {
    final rows = await _sb.app.from('follows').select('follower_id').eq('followee_id', userId);
    return (rows as List? ?? []).map((e) => (e as Map)['follower_id'] as String).toList();
  }

  Future<List<String>> followingOf(String userId) async {
    final rows = await _sb.app.from('follows').select('followee_id').eq('follower_id', userId);
    return (rows as List? ?? []).map((e) => (e as Map)['followee_id'] as String).toList();
  }
}

