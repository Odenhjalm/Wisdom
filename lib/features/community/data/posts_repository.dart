import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/core/errors/app_failure.dart';
import 'package:visdom/core/supabase_ext.dart';

class PostsRepository {
  PostsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<CommunityPost>> feed({int limit = 50}) async {
    try {
      final rows = await _client.app
          .from('posts')
          .select('id, author_id, content, media_paths, created_at')
          .order('created_at', ascending: false)
          .limit(limit);
      final posts = (rows as List? ?? [])
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .toList();

      final authorIds =
          posts.map((post) => post.authorId).whereType<String>().toSet().toList();
      if (authorIds.isEmpty) return posts;

      final inList = '(${authorIds.map((id) => '"$id"').join(',')})';
      final profRows = await _client.app
          .from('profiles')
          .select('user_id, display_name, photo_url')
          .filter('user_id', 'in', inList);
      final profiles = <String, CommunityProfile>{
        for (final row in (profRows as List? ?? []))
          if (row is Map<String, dynamic>)
            row['user_id'] as String: CommunityProfile.fromJson(row),
      };

      return posts
          .map((post) => post.copyWith(profile: profiles[post.authorId]))
          .toList();
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CommunityPost> create({
    required String content,
    List<String>? mediaPaths,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        throw UnauthorizedFailure(message: 'Du måste vara inloggad för att posta.');
      }
      final payload = {
        'author_id': uid,
        'content': content,
        if (mediaPaths != null && mediaPaths.isNotEmpty)
          'media_paths': mediaPaths,
      };
      final res = await _client.app
          .from('posts')
          .insert(payload)
          .select()
          .maybeSingle();
      if (res == null) {
        throw ServerFailure(message: 'Inlägget kunde inte sparas.');
      }
      return CommunityPost.fromJson(res);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<RealtimeChannel> subscribeToFeed({
    required void Function() onChanged,
  }) async {
    try {
      final channel = _client
          .channel('posts-feed')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'app',
            table: 'posts',
            callback: (_) => onChanged(),
          )
          .subscribe();
      return channel;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.mediaPaths = const [],
    this.profile,
  });

  final String id;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final List<String> mediaPaths;
  final CommunityProfile? profile;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    return CommunityPost(
      id: json['id'] as String,
      authorId: (json['author_id'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      mediaPaths: (json['media_paths'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  CommunityPost copyWith({CommunityProfile? profile}) {
    return CommunityPost(
      id: id,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      mediaPaths: mediaPaths,
      profile: profile ?? this.profile,
    );
  }
}

class CommunityProfile {
  const CommunityProfile({
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  final String userId;
  final String? displayName;
  final String? photoUrl;

  factory CommunityProfile.fromJson(Map<String, dynamic> json) {
    return CommunityProfile(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
