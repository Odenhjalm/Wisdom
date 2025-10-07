import 'dart:async';

import 'package:wisdom/api/api_client.dart';
import 'package:wisdom/core/errors/app_failure.dart';

class PostsRepository {
  PostsRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<List<CommunityPost>> feed({int limit = 50}) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/community/posts',
        queryParameters: {
          'limit': limit,
        },
      );
      final items = (response['items'] as List? ?? [])
          .map((item) => CommunityPost.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
      return items;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<CommunityPost> create({
    required String content,
    List<String>? mediaPaths,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/community/posts',
        body: {
          'content': content,
          if (mediaPaths != null && mediaPaths.isNotEmpty)
            'media_paths': mediaPaths,
        },
      );
      return CommunityPost.fromJson(response);
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
    final profile = json['profile'];
    return CommunityPost(
      id: json['id'] as String,
      authorId: (json['author_id'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : created is DateTime
              ? created
              : DateTime.fromMillisecondsSinceEpoch(0),
      mediaPaths: (json['media_paths'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      profile: profile is Map<String, dynamic>
          ? CommunityProfile.fromJson(profile)
          : profile is Map
              ? CommunityProfile.fromJson(
                  Map<String, dynamic>.from(profile),
                )
              : null,
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
