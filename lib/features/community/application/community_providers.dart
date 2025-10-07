import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/features/community/data/community_repository.dart';
import 'package:wisdom/features/community/data/posts_repository.dart';
import 'package:wisdom/features/community/data/admin_repository.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/features/community/data/meditations_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return CommunityRepository(client);
});

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PostsRepository(client: client);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminRepository(client);
});

final meditationsRepositoryProvider = Provider<MeditationsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return MeditationsRepository(client);
});

final postsProvider = AutoDisposeFutureProvider<List<CommunityPost>>((
  ref,
) async {
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
    final certCount = <String, int>{};
    for (final teacher in teachers) {
      final id = teacher['user_id'] as String?;
      if (id == null) continue;
      final count = teacher['verified_certificates'];
      certCount[id] = count is num ? count.toInt() : 0;
    }
    return TeacherDirectoryState(teachers: teachers, certCount: certCount);
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

final myCertificatesProvider = AutoDisposeFutureProvider<List<Certificate>>((
  ref,
) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.profile == null) {
    return const <Certificate>[];
  }
  final repo = ref.watch(certificatesRepositoryProvider);
  try {
    final certs = await repo.myCertificates();
    return certs
        .where((c) => c.title != Certificate.teacherApplicationTitle)
        .toList(growable: false);
  } catch (error, stackTrace) {
    final failure = AppFailure.from(error, stackTrace);
    if (failure.kind == AppFailureKind.unauthorized) {
      return const <Certificate>[];
    }
    throw failure;
  }
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
    AutoDisposeFutureProvider.family<TeacherProfileState, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(communityRepositoryProvider);
  final certRepo = ref.watch(certificatesRepositoryProvider);
  try {
    final teacher = await repo.getTeacher(userId);
    final services = await repo.listServices(userId);
    final meditations = await repo.listMeditations(userId);
    final certsRaw = await certRepo.certificatesOf(userId);
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
});

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

final adminDashboardProvider = AutoDisposeFutureProvider<AdminDashboardState>((
  ref,
) async {
  try {
    final repo = ref.watch(adminRepositoryProvider);
    final data = await repo.fetchDashboard();
    final isAdmin = data['is_admin'] == true;
    if (!isAdmin) {
      return const AdminDashboardState(
        isAdmin: false,
        requests: [],
        certificates: [],
      );
    }
    final requests = (data['requests'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    final certs = (data['certificates'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
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
    AutoDisposeFutureProvider.family<ProfileViewState, String>((
  ref,
  userId,
) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    final detail = await repo.profileDetail(userId);
    final profile = detail['profile'] as Map<String, dynamic>?;
    final services = (detail['services'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    final meditations = (detail['meditations'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    final isFollowing = detail['is_following'] == true;
    return ProfileViewState(
      profile: profile,
      isFollowing: isFollowing,
      services: services,
      meditations: meditations,
    );
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

class ServiceDetailState {
  const ServiceDetailState({required this.service, required this.provider});

  final Map<String, dynamic>? service;
  final Map<String, dynamic>? provider;
}

final serviceDetailProvider =
    AutoDisposeFutureProvider.family<ServiceDetailState, String>((
  ref,
  serviceId,
) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    final detail = await repo.serviceDetail(serviceId);
    final service = detail['service'] as Map<String, dynamic>?;
    final provider = detail['provider'] as Map<String, dynamic>?;
    return ServiceDetailState(service: service, provider: provider);
  } catch (error, stackTrace) {
    throw AppFailure.from(error, stackTrace);
  }
});

final tarotRequestsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    return await repo.tarotRequests();
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
