import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/features/auth/application/user_access_provider.dart';
import 'package:wisdom/domain/models/user_access.dart';

import 'package:wisdom/data/supabase/supabase_client.dart';
import 'package:wisdom/features/auth/presentation/auth_callback_page.dart';
import 'package:wisdom/features/auth/presentation/forgot_password_page.dart';
import 'package:wisdom/features/auth/presentation/login_page.dart';
import 'package:wisdom/features/auth/presentation/new_password_page.dart';
import 'package:wisdom/features/auth/presentation/settings_page.dart';
import 'package:wisdom/features/auth/presentation/signup_page.dart';
import 'package:wisdom/features/community/presentation/admin_page.dart';
import 'package:wisdom/features/community/presentation/community_page.dart';
import 'package:wisdom/features/community/presentation/home_shell.dart';
import 'package:wisdom/features/community/presentation/profile_edit_page.dart';
import 'package:wisdom/features/community/presentation/profile_page.dart'
    as community_profile;
import 'package:wisdom/features/community/presentation/profile_view_page.dart';
import 'package:wisdom/features/community/presentation/service_detail_page.dart';
import 'package:wisdom/features/community/presentation/tarot_page.dart';
import 'package:wisdom/features/community/presentation/teacher_profile_page.dart';
import 'package:wisdom/widgets/base_page.dart';
import 'package:wisdom/features/courses/presentation/course_intro_page.dart';
import 'package:wisdom/features/courses/presentation/course_intro_redirect_page.dart';
import 'package:wisdom/features/courses/presentation/course_page.dart';
import 'package:wisdom/features/courses/presentation/lesson_page.dart';
import 'package:wisdom/features/courses/presentation/quiz_take_page.dart';
import 'package:wisdom/features/landing/presentation/landing_page.dart';
import 'package:wisdom/features/landing/presentation/legal/privacy_page.dart';
import 'package:wisdom/features/landing/presentation/legal/terms_page.dart';
import 'package:wisdom/features/messages/presentation/chat_page.dart';
import 'package:wisdom/features/messages/presentation/messages_page.dart';
import 'package:wisdom/features/payments/presentation/booking_page.dart';
import 'package:wisdom/features/payments/presentation/subscribe_screen.dart';
import 'package:wisdom/features/payments/presentation/claim_purchase_page.dart';
import 'package:wisdom/features/studio/presentation/course_editor_page.dart';
import 'package:wisdom/features/studio/presentation/studio_page.dart';
import 'package:wisdom/features/studio/presentation/teacher_home_page.dart';

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
  '/claim',
};

final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final access = await ref.watch(userAccessProvider.future);
  return access.effectiveProfile;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final access = ref.watch(userAccessProvider).maybeWhen(
        data: (value) => value,
        orElse: () => UserAccessState.unauthenticated,
      );
  final profile = access.effectiveProfile;
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
        builder: (context, state) => LoginPage(
          redirectPath: state.uri.queryParameters['redirect'],
        ),
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
        path: '/claim',
        name: 'claim',
        builder: (context, state) => ClaimPurchasePage(
          token: state.uri.queryParameters['token'],
        ),
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
        redirect: (_, __) {
          if (!access.isTeacher && !access.isAdmin) {
            return '/profile';
          }
          return null;
        },
        builder: (context, state) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: '/teacher/editor',
        name: 'teacher-editor',
        redirect: (_, __) {
          if (!access.isTeacher && !access.isAdmin) {
            return '/profile';
          }
          return null;
        },
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
          if (profile == null) return null;
          if (!profile.isTeacher && !profile.isAdmin) return '/profile';
          return null;
        },
        builder: (context, state) => const StudioPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        redirect: (_, __) {
          if (profile == null) return null;
          if (!profile.isAdmin) return '/profile';
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
      body: BasePage(
        child: Center(
          child: Text('Sidan hittades inte: ${state.error}'),
        ),
      ),
    ),
  );
});
