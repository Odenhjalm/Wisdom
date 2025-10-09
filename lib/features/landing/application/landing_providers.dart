import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart'
    as studio;

class LandingSectionState {
  const LandingSectionState({
    required this.items,
    this.errorMessage,
    this.devHint,
  });

  final List<Map<String, dynamic>> items;
  final String? errorMessage;
  final String? devHint;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty;
}

List<Map<String, dynamic>> _castList(dynamic value) {
  final list = value as List?;
  if (list == null) return const <Map<String, dynamic>>[];
  return list
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList(growable: false);
}

LandingSectionState _landingSuccessState(List<Map<String, dynamic>> items) {
  return LandingSectionState(
    items: items,
    devHint: items.isEmpty ? _devHintMessage : null,
  );
}

LandingSectionState _landingErrorState(
    {String message = 'Kunde inte hämta innehållet just nu.'}) {
  return LandingSectionState(
    items: const <Map<String, dynamic>>[],
    errorMessage: message,
    devHint: _devHintMessage,
  );
}

String? get _devHintMessage =>
    kDebugMode ? 'Kontrollera att API_BASE_URL är konfigurerad.' : null;

Future<LandingSectionState> _fetchLandingSection(
  Ref ref,
  String path,
  String errorLabel,
) async {
  final api = ref.read(apiClientProvider);
  try {
    final response = await api.get<Map<String, dynamic>>(path);
    final items = _castList(response['items']);
    return _landingSuccessState(items);
  } on TimeoutException {
    return _landingErrorState(
        message: 'Tidsgränsen gick ut när vi hämtade $errorLabel.');
  } catch (_) {
    return _landingErrorState(message: 'Kunde inte hämta $errorLabel just nu.');
  }
}

final introCoursesProvider = FutureProvider<LandingSectionState>((ref) {
  return _fetchLandingSection(ref, '/landing/intro-courses', 'gratiskurser');
});

final popularCoursesProvider = FutureProvider<LandingSectionState>((ref) {
  return _fetchLandingSection(ref, '/landing/popular-courses', 'kurslistan');
});

final teachersProvider = FutureProvider<LandingSectionState>((ref) {
  return _fetchLandingSection(ref, '/landing/teachers', 'lärarlistan');
});

final recentServicesProvider = FutureProvider<LandingSectionState>((ref) {
  return _fetchLandingSection(ref, '/landing/services', 'tjänsterna');
});

final myStudioCoursesProvider =
    FutureProvider<LandingSectionState>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final profile = auth.profile;
  final isTeacher = profile?.isTeacher == true || profile?.isAdmin == true;
  if (!isTeacher) {
    return const LandingSectionState(items: []);
  }
  try {
    final repo = ref.read(studio.studioRepositoryProvider);
    final courses = await repo.myCourses();
    return _landingSuccessState(
      courses.length > 3 ? courses.sublist(0, 3) : courses,
    );
  } catch (_) {
    return _landingErrorState(
      message: 'Kunde inte hämta dina studio-kurser.',
    );
  }
});
