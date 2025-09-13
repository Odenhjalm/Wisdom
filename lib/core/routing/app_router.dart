import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'package:andlig_app/ui/pages/landing_page.dart';
import 'package:andlig_app/ui/pages/home_page.dart';
import 'package:andlig_app/ui/pages/course_page.dart';
import 'package:andlig_app/ui/pages/course_intro_redirect_page.dart';
import 'package:andlig_app/ui/pages/studio_page.dart';
import 'package:andlig_app/ui/pages/admin_page.dart';
import 'package:andlig_app/ui/pages/profile_page.dart';
import 'package:andlig_app/ui/pages/profile_view_page.dart';
import 'package:andlig_app/ui/pages/settings_page.dart';
import 'package:andlig_app/ui/pages/lesson_page.dart';
import 'package:andlig_app/ui/pages/tarot_page.dart';
import 'package:andlig_app/ui/pages/booking_page.dart';
import 'package:andlig_app/ui/pages/community_page.dart';
import 'package:andlig_app/ui/pages/teacher_profile_page.dart';
import 'package:andlig_app/ui/pages/messages_page.dart';
import 'package:andlig_app/ui/pages/service_detail_page.dart';
import 'package:andlig_app/ui/pages/legal/privacy_page.dart';
import 'package:andlig_app/ui/pages/legal/terms_page.dart';

// ---- OPTIONAL: lyssna på auth-förändringar om/ när du kopplar in Supabase ----
// Om du inte vill refresha på auth events ännu: kommentera bort refreshListenable helt.
import 'package:andlig_app/data/supabase/supabase_client.dart';

/// Minimal ersättare för `GoRouterRefreshStream` (om din go_router-version saknar den).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// Auth state stream for providers to react to
final authStateChangesProvider = StreamProvider.autoDispose((ref) {
  return Supa.client.auth.onAuthStateChange;
});

// Resolve current user's role; rebuilds on auth changes
final userRoleProvider = FutureProvider<String?>((ref) async {
  // Re-run on auth change
  ref.watch(authStateChangesProvider);
  final u = Supa.client.auth.currentUser;
  if (u == null) return null;
  final res = await Supa.client.schema('app').rpc('get_my_profile');
  if (res is Map && res['role'] is String) return res['role'] as String;
  if (res is List && res.isNotEmpty) {
    final m = (res.first as Map);
    final r = m['role'];
    if (r is String) return r;
  }
  return null;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final role = ref.watch(userRoleProvider).maybeWhen(data: (r) => r, orElse: () => null);
  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: GoRouterRefreshStream(
      Supa.client.auth.onAuthStateChange,
    ),
    redirect: (ctx, state) {
      final signedIn = Supa.client.auth.currentUser != null;
      final goingTo = state.fullPath ?? state.uri.toString();

      // Endast utloggade ska se landing
      if (signedIn && (goingTo == '/' || goingTo == '/landing')) {
        return '/home';
      }
      // Skydda home/studio/admin/service/messages för utloggade
      if (!signedIn && (goingTo == '/home' || goingTo.startsWith('/studio') || goingTo.startsWith('/admin') || goingTo.startsWith('/messages') || goingTo.startsWith('/service'))) {
        return '/landing';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LandingPage()),
      GoRoute(path: '/landing', builder: (_, __) => const LandingPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/community', builder: (_, __) => const CommunityPage()),
      GoRoute(
        path: '/profile/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return ProfileViewPage(userId: id);
        },
      ),

      // Intro-omledning: laddar första fria kursen och hoppar till slug
      GoRoute(
        path: '/course/intro',
        builder: (_, __) => const CourseIntroRedirectPage(),
      ),
      // Kurs efter slug
      GoRoute(
        path: '/course/:slug',
        builder: (ctx, st) {
          final slug = st.pathParameters['slug'];
          if (slug == null || slug.isEmpty) return const LandingPage();
          return CoursePage(slug: slug);
        },
      ),
      // Lektionsvy (markdown)
      GoRoute(
        path: '/lesson/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return LessonPage(lessonId: id);
        },
      ),
      GoRoute(
        path: '/teacher/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return TeacherProfilePage(userId: id);
        },
      ),
      GoRoute(
        path: '/messages/dm/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return MessagesPage(kind: 'dm', id: id);
        },
      ),
      GoRoute(
        path: '/messages/service/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return MessagesPage(kind: 'service', id: id);
        },
      ),
      GoRoute(
        path: '/service/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'];
          if (id == null || id.isEmpty) return const LandingPage();
          return ServiceDetailPage(id: id);
        },
      ),
      GoRoute(path: '/tarot', builder: (_, __) => const TarotPage()),
      GoRoute(path: '/booking', builder: (_, __) => const BookingPage()),

      // Övriga sidor (placeholders tills vidare)
      GoRoute(
        path: '/studio',
        redirect: (_, __) {
          // Vänta tills roll är laddad; blockera endast om vi vet att den inte räcker
          if (role == null) return null;
          if (role != 'teacher' && role != 'admin') return '/profile';
          return null;
        },
        builder: (_, __) => const StudioPage(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (_, __) {
          if (role == null) return null;
          if (role != 'admin') return '/profile';
          return null;
        },
        builder: (_, __) => const AdminPage(),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/legal/privacy', builder: (_, __) => const PrivacyPage()),
      GoRoute(path: '/legal/terms', builder: (_, __) => const TermsPage()),
    ],
  );
});
