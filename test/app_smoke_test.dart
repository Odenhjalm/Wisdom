import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/core/routing/app_router.dart';
import 'package:wisdom/features/landing/presentation/landing_page.dart';
import 'package:wisdom/main.dart';

void main() {
  testWidgets('WisdomApp shows landing hero', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
      ],
    );

    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envInfoProvider.overrideWith((ref) => envInfoOk),
          appRouterProvider.overrideWithValue(router),
        ],
        child: const WisdomApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Börja gratis idag'), findsOneWidget);
  });
}
