import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:wisdom/core/env/app_config.dart';
import 'package:wisdom/core/env/env_state.dart';

import 'shared/theme/light_theme.dart';
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
  final rawBaseUrl =
      dotenv.maybeGet('API_BASE_URL') ?? const String.fromEnvironment('API_BASE_URL');
  final baseUrl = _resolveApiBaseUrl(rawBaseUrl);
  final publishableKey = dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY') ??
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  final merchantDisplayName =
      dotenv.maybeGet('STRIPE_MERCHANT_DISPLAY_NAME') ??
      const String.fromEnvironment('STRIPE_MERCHANT_DISPLAY_NAME');

  final missingKeys = <String>[];
  if (rawBaseUrl.isEmpty) {
    missingKeys.add('API_BASE_URL');
  }
  if (publishableKey.isEmpty) {
    missingKeys.add('STRIPE_PUBLISHABLE_KEY');
  }
  if (merchantDisplayName.isEmpty) {
    missingKeys.add('STRIPE_MERCHANT_DISPLAY_NAME');
  }

  final stripeSupportedPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
  };
  final canInitStripe =
      publishableKey.isNotEmpty &&
      (kIsWeb || stripeSupportedPlatforms.contains(defaultTargetPlatform));

  if (canInitStripe) {
    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = merchantDisplayName.isNotEmpty
        ? merchantDisplayName
        : 'Wisdom';
    await Stripe.instance.applySettings();
  }
  if (!canInitStripe && publishableKey.isNotEmpty) {
    debugPrint(
      'Stripe initialisering hoppades över – plattform ${defaultTargetPlatform.name} stöds inte.',
    );
  }

  final envInfo = missingKeys.isEmpty
      ? envInfoOk
      : EnvInfo(status: EnvStatus.missing, missingKeys: missingKeys);
  runApp(
    ProviderScope(
      overrides: [
        envInfoProvider.overrideWith((ref) => envInfo),
        appConfigProvider.overrideWithValue(
          AppConfig(
            apiBaseUrl: baseUrl,
            stripePublishableKey: publishableKey,
            stripeMerchantDisplayName:
                merchantDisplayName.isNotEmpty ? merchantDisplayName : 'Wisdom',
          ),
        ),
      ],
      child: const WisdomApp(),
    ),
  );
}

String _resolveApiBaseUrl(String url) {
  if (url.isEmpty) {
    return url;
  }
  final parsed = Uri.tryParse(url);
  if (parsed == null || parsed.host.isEmpty) {
    return url;
  }
  if (kIsWeb) {
    return url;
  }

  const loopbackHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
  if (Platform.isAndroid && loopbackHosts.contains(parsed.host)) {
    return parsed.replace(host: '10.0.2.2').toString();
  }
  if (Platform.isIOS && parsed.host == '0.0.0.0') {
    return parsed.replace(host: '127.0.0.1').toString();
  }
  return url;
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
