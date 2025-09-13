import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'domain/services/remote_config_service.dart';
import 'domain/services/analytics_service.dart';
import 'domain/services/notifications_service.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Firebase core (placeholder options until FlutterFire is configured)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Crashlytics: capture Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Remote Config defaults + fetch
    unawaited(RemoteConfigService.instance.init(
      minimumFetchInterval: const Duration(minutes: 15),
    ));

    // Basic analytics event
    unawaited(AnalyticsService.instance.logEvent('app_open'));

    // FCM permission + token retrieval (no-op on web)
    unawaited(NotificationsService.instance.initAndGetToken());
  } catch (_) {
    // Soft-fail if Firebase isn't configured yet
  }

  await Supa.init();

  runZonedGuarded(() {
    runApp(const ProviderScope(child: AndligVagApp()));
  }, (error, stack) {
    // Report to Crashlytics if available
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {}
  });
}

class AndligVagApp extends ConsumerWidget {
  const AndligVagApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Andlig Väg',
      theme: theme.light,
      darkTheme: theme.dark,
      // Håll appen ljus och mjuk oavsett systemtema
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('sv'), Locale('en')],
      locale: const Locale('sv'),
      routerConfig: router,
    );
  }
}
