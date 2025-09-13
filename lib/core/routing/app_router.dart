import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'package:andlig_app/ui/pages/landing_page.dart';
import 'package:andlig_app/ui/pages/home_page.dart';
import 'package:andlig_app/ui/pages/course_page.dart';
import 'package:andlig_app/ui/pages/studio_page.dart';
import 'package:andlig_app/ui/pages/admin_page.dart';
import 'package:andlig_app/ui/pages/profile_page.dart';
import 'package:andlig_app/ui/pages/settings_page.dart';

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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/', // starta på landningssidan
    refreshListenable: GoRouterRefreshStream(
      Supa.client.auth.onAuthStateChange,
    ),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LandingPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),

      // Exempel/introkurs
      GoRoute(
        path: '/course/intro',
        builder: (_, __) => const CoursePage(courseId: 'intro'),
      ),

      // Övriga sidor (placeholders tills vidare)
      GoRoute(path: '/studio', builder: (_, __) => const StudioPage()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
