import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase/supabase_client.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/new_password_page.dart';
import '../../features/auth/signup_page.dart';
import '../../screens/courses/course_intro.dart';
import '../../screens/courses/quiz_take.dart';
import '../../screens/home/home_shell.dart';
import '../../screens/landing/landing_page.dart';
import '../../screens/messages/chat_page.dart';
import '../../screens/profile/profile_edit.dart';
import '../../screens/subscribe/subscribe_screen.dart';
import '../../screens/teacher/course_editor.dart';
import '../../screens/teacher/teacher_home.dart';
import '../../ui/pages/admin_page.dart';
import '../../ui/pages/booking_page.dart';
import '../../ui/pages/community_page.dart';
import '../../ui/pages/course_intro_redirect_page.dart';
import '../../ui/pages/course_page.dart';
import '../../ui/pages/lesson_page.dart';
import '../../ui/pages/messages_page.dart';
import '../../ui/pages/profile_page.dart' as ui;
import '../../ui/pages/profile_view_page.dart';
import '../../ui/pages/service_detail_page.dart';
import '../../ui/pages/settings_page.dart';
import '../../ui/pages/studio_page.dart';
import '../../ui/pages/tarot_page.dart';
import '../../ui/pages/teacher_profile_page.dart';
import '../../ui/pages/legal/privacy_page.dart';
import '../../ui/pages/legal/terms_page.dart';

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

final authStateChangesProvider = StreamProvider.autoDispose(
  (ref) => Supa.client.auth.onAuthStateChange,
);

final userRoleProvider = FutureProvider<String?>((ref) async {
  ref.watch(authStateChangesProvider);
  final user = Supa.client.auth.currentUser;
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
  final refreshListenable = GoRouterRefreshStream(
    Supa.client.auth.onAuthStateChange.map((event) => event.event),
  );
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final session = Supa.client.auth.currentSession;
      final loggedIn = session != null;
      final path = state.uri.path;
      const publicPaths = {
        '/login',
        '/signup',
        '/forgot-password',
        '/new-password',
        '/landing',
      };

      if (!loggedIn && !publicPaths.contains(path)) {
        return '/login';
      }

      if (loggedIn && (path == '/login' || path == '/signup')) {
        return '/';
      }

      return null;
    },
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
        builder: (context, state) => const ui.ProfilePage(),
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

  final sub = Supa.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      router.go('/new-password');
    }
  });

  ref.onDispose(sub.cancel);

  // ---------------------------------------------------------------------------
  // Deeplink/URL-scheme (BYT VID BEHOV)
  // TODO: Säkerställ att redirectURL matchar din Supabase-konfiguration.
  // Supabase Dashboard → Auth → URL Configuration:
  //   Lägg till andligapp://auth-callback som tillåten redirect.
  // Android (android/app/src/main/AndroidManifest.xml):
  //   <intent-filter>
  //     <action android:name="android.intent.action.VIEW" />
  //     <category android:name="android.intent.category.DEFAULT" />
  //     <category android:name="android.intent.category.BROWSABLE" />
  //     <data android:scheme="andligapp" android:host="auth-callback" />
  //   </intent-filter>
  // iOS (ios/Runner/Info.plist):
  //   <key>CFBundleURLTypes</key>
  //   <array>
  //     <dict>
  //       <key>CFBundleURLSchemes</key>
  //       <array>
  //         <string>andligapp</string>
  //       </array>
  //       <key>CFBundleURLName</key>
  //       <string>auth-callback</string>
  //     </dict>
  //   </array>
  // Notera: På webben används SITE_URL (https), men i mobil används app-schemat.
  // Counterpart: resetPasswordForEmail(..., redirectTo: 'andligapp://auth-callback')
  //   måste matcha samma värde.
  // ---------------------------------------------------------------------------

  return router;
});
