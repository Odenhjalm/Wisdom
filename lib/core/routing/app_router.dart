import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/data/supabase/supabase_client.dart';
import 'package:visdom/features/auth/presentation/auth_callback_page.dart';
import 'package:visdom/features/auth/presentation/forgot_password_page.dart';
import 'package:visdom/features/auth/presentation/login_page.dart';
import 'package:visdom/features/auth/presentation/new_password_page.dart';
import 'package:visdom/features/auth/presentation/settings_page.dart';
import 'package:visdom/features/auth/presentation/signup_page.dart';
import 'package:visdom/features/community/presentation/admin_page.dart';
import 'package:visdom/features/community/presentation/community_page.dart';
import 'package:visdom/features/community/presentation/home_shell.dart';
import 'package:visdom/features/community/presentation/profile_edit_page.dart';
import 'package:visdom/features/community/presentation/profile_page.dart'
    as community_profile;
import 'package:visdom/features/community/presentation/profile_view_page.dart';
import 'package:visdom/features/community/presentation/service_detail_page.dart';
import 'package:visdom/features/community/presentation/tarot_page.dart';
import 'package:visdom/features/community/presentation/teacher_profile_page.dart';
import 'package:visdom/features/courses/presentation/course_intro_page.dart';
import 'package:visdom/features/courses/presentation/course_intro_redirect_page.dart';
import 'package:visdom/features/courses/presentation/course_page.dart';
import 'package:visdom/features/courses/presentation/lesson_page.dart';
import 'package:visdom/features/courses/presentation/quiz_take_page.dart';
import 'package:visdom/features/landing/presentation/landing_page.dart';
import 'package:visdom/features/landing/presentation/legal/privacy_page.dart';
import 'package:visdom/features/landing/presentation/legal/terms_page.dart';
import 'package:visdom/features/messages/presentation/chat_page.dart';
import 'package:visdom/features/messages/presentation/messages_page.dart';
import 'package:visdom/features/payments/presentation/booking_page.dart';
import 'package:visdom/features/payments/presentation/subscribe_screen.dart';
import 'package:visdom/features/studio/presentation/course_editor_page.dart';
import 'package:visdom/features/studio/presentation/studio_page.dart';
import 'package:visdom/features/studio/presentation/teacher_home_page.dart';

class AuthState {
  const AuthState(this.session);

  final Session? session;

  bool get isAuthenticated => session != null;
}

final _authStateStreamProvider = StreamProvider<AuthState>((ref) async* {
  final client = Supa.client.auth;
  yield AuthState(client.currentSession);
  yield* client.onAuthStateChange.map((event) => AuthState(event.session));
});

final sessionProvider = Provider<AuthState>((ref) {
  return ref.watch(_authStateStreamProvider).maybeWhen(
        data: (auth) => auth,
        orElse: () => const AuthState(null),
      );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AuthGuard {
  const AuthGuard(this.publicPaths);

  final Set<String> publicPaths;

  String? redirect(AuthState authState, String path) {
    if (!authState.isAuthenticated && !publicPaths.contains(path)) {
      return '/login';
    }

    if (authState.isAuthenticated &&
        (path == '/login' || path == '/signup' || path == '/landing')) {
      return '/';
    }

    return null;
  }
}

const _publicPaths = <String>{
  '/login',
  '/signup',
  '/forgot-password',
  '/new-password',
  '/auth-callback',
  '/landing',
};

final userRoleProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(sessionProvider);
  final user = authState.session?.user;
  if (user == null) return null;

  final res = await Supa.client.schema('app').rpc('get_my_profile');
  String? role;
  if (res is Map && res['role'] is String) {
    role = res['role'] as String;
  } else if (res is List && res.isNotEmpty) {
    final m = (res.first as Map);
    final r = m['role'];
    if (r is String) role = r;
  }

  if (role == 'teacher' || role == 'admin') {
    return role;
  }

  Future<Map<String, dynamic>?> fetchPermissions() async {
    final attempts = [
      () => Supa.client
          .schema('app')
          .from('teacher_permissions')
          .select('can_edit_courses, can_publish')
          .eq('profile_id', user.id)
          .maybeSingle(),
      () => Supa.client
          .from('teacher_permissions_compat')
          .select('can_edit_courses, can_publish')
          .eq('profile_id', user.id)
          .maybeSingle(),
      () => Supa.client
          .from('teacher_permissions')
          .select('can_edit_courses, can_publish')
          .eq('user_id', user.id)
          .maybeSingle(),
    ];

    for (final attempt in attempts) {
      try {
        final res = await attempt();
        if (res case Map<String, dynamic> map when map.isNotEmpty) {
          return map;
        }
        if (res case Map<dynamic, dynamic> map when map.isNotEmpty) {
          return Map<String, dynamic>.from(map);
        }
      } on PostgrestException {
        // next source
      }
    }
    return null;
  }

  final perms = await fetchPermissions();
  if (perms != null) {
    final canEdit = perms['can_edit_courses'] == true;
    final canPublish = perms['can_publish'] == true;
    if (canEdit || canPublish) {
      return 'teacher';
    }
  }

  return role;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final role =
      ref.watch(userRoleProvider).maybeWhen(data: (r) => r, orElse: () => null);
  final authState = ref.watch(sessionProvider);
  const guard = AuthGuard(_publicPaths);
  final refreshListenable = GoRouterRefreshStream(
    Supa.client.auth.onAuthStateChange.map((event) => event.event),
  );

  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: refreshListenable,
    redirect: (context, state) => guard.redirect(authState, state.uri.path),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth-callback',
        name: 'auth-callback',
        builder: (context, state) => AuthCallbackPage(state: state),
      ),
      GoRoute(
        path: '/new-password',
        name: 'new-password',
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/home',
        name: 'home-legacy',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/course-intro',
        name: 'course-intro',
        builder: (context, state) => const CourseIntroPage(),
      ),
      GoRoute(
        path: '/course-quiz',
        name: 'course-quiz',
        builder: (context, state) => const QuizTakePage(),
      ),
      GoRoute(
        path: '/subscribe',
        name: 'subscribe',
        builder: (context, state) => const SubscribeScreen(),
      ),
      GoRoute(
        path: '/teacher',
        name: 'teacher-home',
        builder: (context, state) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: '/teacher/editor',
        name: 'teacher-editor',
        builder: (context, state) => CourseEditorScreen(
          courseId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/messages/:uid',
        name: 'dm',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityPage(),
      ),
      GoRoute(
        path: '/profile/:id',
        name: 'profile-view',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return ProfileViewPage(userId: id);
        },
      ),
      GoRoute(
        path: '/course/intro',
        name: 'course-intro-redirect',
        builder: (context, state) => const CourseIntroRedirectPage(),
      ),
      GoRoute(
        path: '/course/:slug',
        name: 'course-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'];
          if (slug == null || slug.isEmpty) return const LandingPage();
          return CoursePage(slug: slug);
        },
      ),
      GoRoute(
        path: '/lesson/:id',
        name: 'lesson',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return LessonPage(lessonId: id);
        },
      ),
      GoRoute(
        path: '/teacher/:id',
        name: 'teacher-profile',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return TeacherProfilePage(userId: id);
        },
      ),
      GoRoute(
        path: '/messages/dm/:id',
        name: 'messages-dm',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return MessagesPage(kind: 'dm', id: id);
        },
      ),
      GoRoute(
        path: '/messages/service/:id',
        name: 'messages-service',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return MessagesPage(kind: 'service', id: id);
        },
      ),
      GoRoute(
        path: '/service/:id',
        name: 'service-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return ServiceDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/tarot',
        name: 'tarot',
        builder: (context, state) => const TarotPage(),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: '/studio',
        name: 'studio',
        redirect: (_, __) {
          if (role == null) return null;
          if (role != 'teacher' && role != 'admin') return '/profile';
          return null;
        },
        builder: (context, state) => const StudioPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        redirect: (_, __) {
          if (role == null) return null;
          if (role != 'admin') return '/profile';
          return null;
        },
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const community_profile.ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/legal/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/legal/terms',
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Fel')),
      body: Center(child: Text('Sidan hittades inte: ${state.error}')),
    ),
  );
});
