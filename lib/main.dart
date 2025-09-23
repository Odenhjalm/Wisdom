import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'supabase_client.dart';
import 'ui/background_layer.dart';
import 'core/routing/app_router.dart';
import 'core/theme/controls.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ladda .env (innehåller SUPABASE_URL och SUPABASE_ANON_KEY)
  await initSupabase();
  runApp(const ProviderScope(child: VisdomApp()));
}

class VisdomApp extends ConsumerWidget {
  const VisdomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Visdom',
      theme: buildLightTheme(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final themed = Theme(
          data: Theme.of(context).copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style: elevatedPrimaryStyle(context),
            ),
            radioTheme: cleanRadioTheme(context),
          ),
          child: AppBackground(child: child),
        );
        return themed;
      },
    );
  }
}
