import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:visdom/core/env/env_state.dart';
import 'package:visdom/core/routing/app_router.dart';
import 'package:visdom/features/landing/presentation/landing_page.dart';
import 'package:visdom/main.dart';

void main() {
  testWidgets('VisdomApp shows landing hero', (tester) async {
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
        child: const VisdomApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Börja gratis idag'), findsOneWidget);
  });
}
