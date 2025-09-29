import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:wisdom/core/env/env_state.dart';

import 'shared/theme/light_theme.dart';
import 'supabase_client.dart';
import 'shared/widgets/background_layer.dart';
import 'core/routing/app_router.dart';
import 'shared/theme/controls.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Filen är valfri; saknas den så förlitar vi oss på --dart-define eller runtime vars.
  }
  final envInfo = await initSupabase();
  runApp(
    ProviderScope(
      overrides: [
        envInfoProvider.overrideWith((ref) => envInfo),
      ],
      child: const WisdomApp(),
    ),
  );
}

class WisdomApp extends ConsumerWidget {
  const WisdomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wisdom',
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
