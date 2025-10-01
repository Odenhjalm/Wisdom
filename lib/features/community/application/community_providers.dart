import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/core/supabase_ext.dart';
import 'package:wisdom/features/auth/data/auth_profile_repository.dart';
import 'package:wisdom/features/community/data/community_repository.dart';
import 'package:wisdom/features/community/data/posts_repository.dart';
import 'package:wisdom/features/studio/data/certificates_repository.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/features/community/data/meditations_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final client = ref.watch(supabaseMaybeProvider);
  if (client == null) {
    throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
  }
  return CommunityRepository();
});

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final client = ref.watch(supabaseMaybeProvider);
  if (client == null) {
    throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
  }
  return PostsRepository(client: client);
});

final postsProvider =
    AutoDisposeFutureProvider<List<CommunityPost>>((ref) async {
  final repo = ref.watch(postsRepositoryProvider);
  return repo.feed(limit: 50);
});

class TeacherDirectoryState {
  const TeacherDirectoryState({
    required this.teachers,
    required this.certCount,
  });

  final List<Map<String, dynamic>> teachers;
  final Map<String, int> certCount;
}

final teacherDirectoryProvider =
    AutoDisposeFutureProvider<TeacherDirectoryState>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  try {
    final teachers = await repo.listTeachers();
    final ids = teachers
        .map((t) => t['user_id'] as String?)
        .whereType<String>()
        .toList();
    final certCount = await repo.listVerifiedCertCount(ids);
    final certSpecs = await repo.listVerifiedCertSpecialties(ids);
    for (final t in teachers) {
      final id = t['user_id'] as String?;
      if (id == null) continue;
      final dirSpecs =
          (t['specialties'] as List?)?.cast<String>() ?? const <String>[];
      if (dirSpecs.isEmpty && certSpecs[id] != null) {
        t['specialties'] = certSpecs[id];
      }
    }
    return TeacherDirectoryState(teachers: teachers, certCount: certCount);
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

final authProfileRepositoryProvider = Provider<AuthProfileRepository>((ref) {
  return AuthProfileRepository();
});

final myProfileProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(authProfileRepositoryProvider);
  return repo.getMyProfile();
});

final myCertificatesProvider =
    AutoDisposeFutureProvider<List<Certificate>>((ref) async {
  final certs = await CertificatesRepository().myCertificates();
  return certs
      .where((c) => c.title != Certificate.teacherApplicationTitle)
      .toList(growable: false);
});

class TeacherProfileState {
  const TeacherProfileState({
    required this.teacher,
    required this.services,
    required this.meditations,
    required this.certificates,
  });

  final Map<String, dynamic>? teacher;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> meditations;
  final List<Certificate> certificates;
}

final teacherProfileProvider =
    AutoDisposeFutureProvider.family<TeacherProfileState, String>(
  (ref, userId) async {
    final repo = ref.watch(communityRepositoryProvider);
    try {
      final teacher = await repo.getTeacher(userId);
      final services = await repo.listServices(userId);
      final meditations = await repo.listMeditations(userId);
      final certsRaw = await CertificatesRepository().certificatesOf(userId);
      final certs = certsRaw
          .where((c) => c.title != Certificate.teacherApplicationTitle)
          .toList(growable: false);
      return TeacherProfileState(
        teacher: teacher,
        services: services,
        meditations: meditations,
        certificates: certs,
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  },
);

class AdminDashboardState {
  const AdminDashboardState({
    required this.isAdmin,
    required this.requests,
    required this.certificates,
  });

  final bool isAdmin;
  final List<Map<String, dynamic>> requests;
  final List<Map<String, dynamic>> certificates;
}

final adminDashboardProvider =
    AutoDisposeFutureProvider<AdminDashboardState>((ref) async {
  final client = ref.watch(supabaseMaybeProvider);
  if (client == null) {
    throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
  }
  final user = client.auth.currentUser;
  if (user == null) {
    return const AdminDashboardState(
      isAdmin: false,
      requests: [],
      certificates: [],
    );
  }
  try {
    final profileRes = await client.schema('app').rpc('get_my_profile');
    Map<String, dynamic>? profile;
    if (profileRes is Map) {
      profile = profileRes.cast<String, dynamic>();
    } else if (profileRes is List && profileRes.isNotEmpty) {
      profile = (profileRes.first as Map).cast<String, dynamic>();
    }
    final isAdmin = profile?['is_admin'] == true || profile?['role'] == 'admin';
    if (!isAdmin) {
      return const AdminDashboardState(
        isAdmin: false,
        requests: [],
        certificates: [],
      );
    }
    final requestsRes = await client.app
        .from('certificates')
        .select('user_id, title, status, notes, created_at, updated_at')
        .eq('title', 'Läraransökan')
        .order('created_at', ascending: false);
    final approvalsRes = await client.app
        .from('teacher_approvals')
        .select('user_id, approved_by, approved_at');
    final certRes = await client.app
        .from('certificates')
        .select('id, user_id, title, status, notes, created_at, updated_at')
        .order('created_at', ascending: false)
        .limit(200);

    final approvalsByUser = <String, Map<String, dynamic>>{};
    for (final row in (approvalsRes as List? ?? [])) {
      final map = Map<String, dynamic>.from(row as Map);
      final userId = map['user_id'] as String?;
      if (userId != null) {
        approvalsByUser[userId] = map;
      }
    }

    final requests = (requestsRes as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((req) {
      final userId = req['user_id'] as String?;
      final approval = userId != null ? approvalsByUser[userId] : null;
      return {
        ...req,
        if (approval != null) 'approval': approval,
      };
    }).toList();

    final certs = (certRes as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return AdminDashboardState(
      isAdmin: true,
      requests: requests,
      certificates: certs,
    );
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

class ProfileViewState {
  const ProfileViewState({
    required this.profile,
    required this.isFollowing,
    required this.services,
    required this.meditations,
  });

  final Map<String, dynamic>? profile;
  final bool isFollowing;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> meditations;
}

final profileViewProvider =
    AutoDisposeFutureProvider.family<ProfileViewState, String>(
  (ref, userId) async {
    final client = ref.watch(supabaseMaybeProvider);
    if (client == null) {
      throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
    }
    try {
      final profRes = await client
          .schema('app')
          .from('profiles')
          .select(
              'user_id, display_name, photo_url, bio, role, role_v2, is_admin')
          .eq('user_id', userId)
          .maybeSingle();
      final profile = (profRes as Map?)?.cast<String, dynamic>();
      final me = client.auth.currentUser?.id;
      bool following = false;
      if (me != null) {
        final followRes = await client
            .schema('app')
            .from('follows')
            .select('follower_id')
            .eq('follower_id', me)
            .eq('followee_id', userId)
            .maybeSingle();
        following = followRes != null;
      }
      final services =
          await ref.watch(communityRepositoryProvider).listServices(userId);
      final meditations = await MeditationsRepository().byTeacher(userId);
      return ProfileViewState(
        profile: profile,
        isFollowing: following,
        services: services,
        meditations: meditations,
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  },
);

class ServiceDetailState {
  const ServiceDetailState({
    required this.service,
    required this.provider,
  });

  final Map<String, dynamic>? service;
  final Map<String, dynamic>? provider;
}

final serviceDetailProvider =
    AutoDisposeFutureProvider.family<ServiceDetailState, String>(
  (ref, serviceId) async {
    final client = ref.watch(supabaseMaybeProvider);
    if (client == null) {
      throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
    }
    try {
      final res = await client.app
          .from('services')
          .select('id, provider_id, title, description, price_cents, active')
          .eq('id', serviceId)
          .maybeSingle();
      Map<String, dynamic>? service;
      Map<String, dynamic>? provider;
      if (res != null) {
        service = Map<String, dynamic>.from(res as Map);
        final profRes = await client.app
            .from('profiles')
            .select('user_id, display_name, photo_url')
            .eq('user_id', service['provider_id'])
            .maybeSingle();
        if (profRes != null) {
          provider = Map<String, dynamic>.from(profRes as Map);
        }
      }
      return ServiceDetailState(service: service, provider: provider);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  },
);

final tarotRequestsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseMaybeProvider);
  if (client == null) {
    throw ConfigurationFailure(message: 'Supabase ej konfigurerat.');
  }
  final user = client.auth.currentUser;
  if (user == null) return const [];
  try {
    final rows = await client.app
        .from('tarot_requests')
        .select('id, question, status, created_at')
        .eq('requester_id', user.id)
        .order('created_at', ascending: false);
    return (rows as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

class PostPublisherController extends AutoDisposeAsyncNotifier<CommunityPost?> {
  @override
  FutureOr<CommunityPost?> build() => null;

  Future<void> publish({
    required String content,
    List<String>? mediaPaths,
  }) async {
    final repo = ref.read(postsRepositoryProvider);
    state = const AsyncLoading();
    try {
      final post = await repo.create(content: content, mediaPaths: mediaPaths);
      state = AsyncData(post);
    } catch (error, stackTrace) {
      state = AsyncError(AppFailure.from(error, stackTrace), stackTrace);
    }
  }
}

final postPublisherProvider =
    AutoDisposeAsyncNotifierProvider<PostPublisherController, CommunityPost?>(
  PostPublisherController.new,
);
