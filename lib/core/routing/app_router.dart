import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/domain/models/user_access.dart';
import 'package:wisdom/features/auth/application/user_access_provider.dart';
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
import 'package:wisdom/features/payments/presentation/claim_purchase_page.dart';
import 'package:wisdom/features/payments/presentation/subscribe_screen.dart';
import 'package:wisdom/features/studio/presentation/course_editor_page.dart';
import 'package:wisdom/features/studio/presentation/studio_page.dart';
import 'package:wisdom/features/studio/presentation/teacher_home_page.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    _authSub = ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
    _accessSub = ref.listen<UserAccessState>(userAccessProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
  late final ProviderSubscription<AuthState> _authSub;
  late final ProviderSubscription<UserAccessState> _accessSub;

  bool get isAuthenticated => ref.read(authControllerProvider).isAuthenticated;

  UserAccessState get access => ref.read(userAccessProvider);

  String? handleRedirect(GoRouterState state) {
    final path = state.uri.path;
    final wantsPublic = _publicPaths.contains(path);
    if (!isAuthenticated && !wantsPublic) {
      final redirect = state.matchedLocation;
      if (redirect != '/login') {
        return '/login?redirect=${Uri.encodeComponent(redirect)}';
      }
      return '/login';
    }

    if (isAuthenticated && _publicRedirects.contains(path)) {
      return '/';
    }

    if (_requiresTeacher(path) && !access.isTeacher && !access.isAdmin) {
      return '/';
    }

    return null;
  }

  @override
  void dispose() {
    _authSub.close();
    _accessSub.close();
    super.dispose();
  }
}

bool _requiresTeacher(String path) {
  return path.startsWith('/teacher') || path.startsWith('/studio');
}

const _publicPaths = <String>{
  '/landing',
  '/',
  '/login',
  '/signup',
  '/forgot-password',
  '/new-password',
  '/course-intro',
  '/course-quiz',
  '/privacy',
  '/terms',
  '/claim',
};

const _publicRedirects = <String>{
  '/landing',
  '/login',
  '/signup',
};

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: notifier,
    redirect: (context, state) => notifier.handleRedirect(state),
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
        path: '/new-password',
        name: 'new-password',
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: '/',
        name: 'landing-root',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeShell(),
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
        path: '/course/:slug',
        name: 'course',
        builder: (context, state) => CoursePage(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/lesson/:id',
        name: 'lesson',
        builder: (context, state) => LessonPage(
          lessonId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/course-intro-redirect',
        name: 'course-intro-redirect',
        builder: (context, state) => const CourseIntroRedirectPage(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => MessagesPage(
          kind: state.uri.queryParameters['kind'] ?? 'dm',
          id: state.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/messages/:uid',
        name: 'dm',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const community_profile.ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/view/:id',
        name: 'profile-view',
        builder: (context, state) =>
            ProfileViewPage(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/profile/:id',
        name: 'teacher-profile',
        builder: (context, state) =>
            TeacherProfilePage(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/service/:id',
        name: 'service-detail',
        builder: (context, state) =>
            ServiceDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tarot',
        name: 'tarot',
        builder: (context, state) => const TarotPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/studio',
        name: 'studio',
        builder: (context, state) => const StudioPage(),
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
        path: '/subscribe',
        name: 'subscribe',
        builder: (context, state) => const SubscribeScreen(),
      ),
      GoRoute(
        path: '/booking/:id',
        name: 'booking',
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: '/claim',
        name: 'claim',
        builder: (context, state) => ClaimPurchasePage(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityPage(),
      ),
    ],
  );
});
