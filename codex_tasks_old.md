
STATUS 2025-09-29 — Genomgång och läge

- use_build_context_synchronously: Löses nu genom explicita vakter (`if (!mounted || !context.mounted) return;`) i de berörda vyerna. Alla tidigare `context.ifMounted`-anrop har ersatts, och helpern i `lib/shared/utils/context_safe.dart` är borttagen.
- Const-lints: Flera statiska widgets är redan markerade som `const` i nya vyer (t.ex. `lib/features/landing/presentation/landing_page.dart` och `lib/features/community/presentation/home_shell.dart`). Eventuella kvarvarande const-optimeringar kan tas iterativt men blockerar inte körning.
- OAuth redirect helper: Implementerad i `lib/core/auth/oauth_redirect.dart:1` och använd i `forgot_password_page.dart` och `signup_page.dart`.
- Auth callback-sida: Finns och är kopplad i router: `lib/features/auth/presentation/auth_callback_page.dart:1` och route i `lib/core/routing/app_router.dart:199`.
- Dotenv-laddning: Init före `runApp` i `lib/main.dart:12`, med fallback om `.env` saknas.

Slutsats: De praktiska delarna av denna “old tasks”-lista är implementerade i nuvarande kodbas. Om du vill kan jag köra en riktad städpass för eventuella kvarvarande `prefer_const_constructors`-varningar när du kör `flutter analyze` lokalt.


1. **use\_build\_context\_synchronously** (alla efter `await`).
   → De ska omskrivas till `context.ifMounted((c){…})` med din nya helper.

2. **prefer\_const\_constructors** (Landing/Home).
   → Bara att lägga till `const` framför rena statiska widgetkonstruktorer.

---

### ✅ Codex-prompt för nästa pass

> Du jobbar i ett Flutter/Dart-repo. Gör följande:
>
> ---
>
> ### 1) Omskriv alla kvarvarande “context efter await” (use\_build\_context\_synchronously)
>
> **MÖNSTERFIX** i filerna/raderna (om de flyttat, sök samma kod):
>
> * `lib/features/auth/forgot_password_page.dart`: 116–121
> * `lib/features/auth/login_page.dart`: 133–138
> * `lib/features/auth/signup_page.dart`: 145–154, 174–178
> * `lib/screens/home/home_shell.dart`: 157, 192–193
> * `lib/screens/landing/landing_page.dart`: 50
> * `lib/screens/subscribe/subscribe_screen.dart`: 92, 213
> * `lib/screens/teacher/course_editor.dart`: 181, 183, 185, 220, 288
> * `lib/ui/pages/course_page.dart`: 97, 100, 138, 141
>
> **Regel:**
>
> ```dart
> await doSomething();
> // FÖRE
> Navigator.of(context).push(...);
> // EFTER
> context.ifMounted((c) {
>   Navigator.of(c).push(...);
> });
> ```
>
> * Byt **alla** `context` i blocket mot `c`.
> * Ta bort lokala `if (!mounted)` runt dessa anrop.
>
> ---
>
> ### 2) Const-lints
>
> **MÖNSTERFIX** i:
>
> * `lib/screens/home/home_shell.dart`: rad \~107–110
> * `lib/screens/landing/landing_page.dart`: rader \~200, 234, 237, 344, 359, 434, 449, 506, 521, 586, 588, 591
>
> Lägg till `const` framför widget-konstruktorer som bara har litterala värden och inga runtime-parametrar.
>
> ---
>
> ### 3) Slutkontroll
>
> * Alla `use_build_context_synchronously` ska vara borta.
> * Alla listade `prefer_const_constructors` ska vara fixade.
> * Svara med:
>
>   1. Lista över filer som uppdaterats.
>   2. Ett före → efter-exempel för en representativ fix i varje fil.
>   3. Bekräftelse på att `flutter analyze` inte längre visar de här varningarna.
>
> **SLUT.**

---

## Codex-prompt (fixa alla återstående lintar)

> Du jobbar i ett Flutter/Dart-repo. Gör EXAKT följande. När jag skriver **ERSÄTT HELT**: skriv fullständigt filinnehåll. När jag skriver **MÖNSTERFIX**: gör idempotenta omskrivningar i existerande filer. Allt ska kompilera på Flutter 3.35 / Dart 3.9.
>
> ### 0) Import-sanity
>
> **MÖNSTERFIX**
>
> * I alla filer som använder helpern: säkerställ importen
>   `import 'package:wisdom/core/utils/context_safe.dart';`
>   (Ta bort felaktiga varianter som pekar på `andlig_app/...`.)
> * Ta bort **oanvända** `context_safe.dart`-imports.
>
> ---
>
> ### 1) HomeShell: ta bort felaktig `const`
>
> **MÖNSTERFIX** i `lib/screens/home/home_shell.dart`:
>
> * På rad \~105: ta bort `const` från den **widget** linten klagar på (`const_with_non_const`). Lämna övriga `const` orörda.
>
> ---
>
> ### 2) Byt alla “context efter await” → `context.ifMounted`
>
> **MÖNSTERFIX** i följande filer/rader (om raderna flyttat, sök med likadant kontext och tillämpa samma mönster):
>
> * `lib/features/auth/forgot_password_page.dart` ca 116–121
> * `lib/features/auth/login_page.dart` ca 133–141
> * `lib/features/auth/signup_page.dart` ca 145–154 och 174–178
> * `lib/screens/home/home_shell.dart` ca 157, 192–193
> * `lib/screens/landing/landing_page.dart` ca 52
> * `lib/screens/subscribe/subscribe_screen.dart` ca 92 och 213–215
> * `lib/screens/teacher/course_editor.dart` ca 183–187
> * `lib/ui/pages/course_page.dart` ca 98–101 och 139–142
>
> **Regler för omskrivning:**
>
> 1. Lägg (om saknas) överst:
>    `import 'package:wisdom/core/utils/context_safe.dart';`
> 2. Hitta mönster **efter ett `await`** där du anropar *något* som använder `context`, t.ex.:
>
>    * `context.go(...)`, `context.push(...)`, `context.pop()`
>    * `ScaffoldMessenger.of(context).showSnackBar(...)`
>    * `Navigator.of(context).push(...)` / `pop(...)`
>    * `showDialog(context: context, ...)`, `showModalBottomSheet(context: context, ...)`
>    * egna helpers som `context.goSnack(...)`
> 3. Omskriv till:
>
>    ```dart
>    await <ANY>();
>    context.ifMounted((c) {
>      // byt alla "context" i blocket till "c"
>      // t.ex.:
>      ScaffoldMessenger.of(c).showSnackBar(...);
>      c.go('/route');
>      showDialog(context: c, builder: ...);
>    });
>    ```
> 4. Ta bort lokala `if (!mounted) return;` som endast skyddade dessa anrop.
>
> ---
>
> ### 3) Ta bort oanvända imports
>
> **MÖNSTERFIX**
>
> * I `lib/screens/teacher/course_editor.dart`: ta bort oanvänd import av `../../core/utils/context_safe.dart` om den inte används efter omskrivningen.
> * I `lib/ui/pages/course_page.dart`: ta bort `import 'package:wisdom/core/utils/context_safe.dart';` och ersätt med rätt Wisdom-import **om** helpern används. Om *inte* används, ta bort importen helt.
>
> ---
>
> ### 4) Spara alla filer. Kör lokalt (simulerat) `dart format .`.
>
> ### 5) Svara med
>
> * Lista över ändrade filer.
> * Ett kort “före → efter” kodblock för **en** representativ omskrivning per fil (så jag kan granska mönstret).
> * Bekräftelse på att inga `use_build_context_synchronously` varningar återstår i de listade filerna.
>
> **SLUT.**

---



Grymt—här är en **enkel, komplett Codex-prompt** som fixar allt du listade som “Pending” i ett svep:

* ERSÄTTER `lib/core/utils/context_safe.dart` med nya `ContextMountedX.ifMounted`.
* REFRAKTORERAR alla `use_build_context_synchronously`-ställen till `context.ifMounted((c){…})` (tar bort manuella `if (!mounted)`).
* LADDAR `.env` i `main.dart` innan `runApp`, utan att bryta din övriga init.

Klista in hela prompten till Copilot/Codex i VS Code.

---

## Codex-prompt (klistra in allt nedan)

> Du arbetar i ett Flutter/Dart-repo. Utför EXAKT följande ändringar. Svara genom att skriva fullständigt filinnehåll när jag säger **ERSÄTT HELT**, och gör idempotenta textomskrivningar när jag säger **MÖNSTERFIX**. All kod ska vara Null-safe och kompilera.
>
> ---
>
> ### 1) Context helper
>
> **ERSÄTT HELT**: `lib/core/utils/context_safe.dart`
>
> ```dart
> import 'package:flutter/material.dart';
>
> /// Safe, idempotent context-guard efter async gaps.
> extension ContextMountedX on BuildContext {
>   /// Kör [fn] endast om contextet fortfarande är monterat.
>   T? ifMounted<T>(T Function(BuildContext c) fn) {
>     // Navigator.maybeOf(...) finns nästan alltid i träd; fallback = true (för test).
>     final isMounted = Navigator.maybeOf(this)?.context.mounted ?? true;
>     if (!isMounted) return null;
>     return fn(this);
>   }
> }
> ```
>
> ---
>
> ### 2) Använd helpern överallt (ta bort manuella mounted-checks)
>
> **MÖNSTERFIX** i följande filer/rader (om raderna har flyttat, sök kontext och tillämpa samma mönster):
>
> * `lib/features/auth/forgot_password_page.dart` ca 106-124
> * `lib/features/auth/login_page.dart` ca 122-154
> * `lib/features/auth/signup_page.dart` ca 145-184
> * `lib/screens/teacher/course_editor.dart` ca 433-470
> * `lib/ui/pages/course_page.dart` ca 144
> * `lib/screens/landing/landing_page.dart` ca 51
> * `lib/screens/subscribe/subscribe_screen.dart` ca 215
>
> **Regler för omskrivning:**
>
> 1. Lägg till import överst i filen om saknas:
>
>    ```dart
>    import 'package:wisdom/core/utils/context_safe.dart';
>    ```
> 2. Hitta alla mönster där en **await** följs av ett **context-beroende** anrop (efter await), t.ex.:
>
>    * `context.go(...)`, `context.push(...)`, `context.pop()`
>    * `ScaffoldMessenger.of(context).showSnackBar(...)`
>    * `Navigator.of(context).push(...) / pop(...)`
>    * `showDialog(context: context, ...)`, `showModalBottomSheet(context: context, ...)`
>    * ev. egna helpers som `context.goSnack(...)`
> 3. Omskriv till `context.ifMounted((c){ ... })` och byt **alla** `context` inne i blocket till `c`.
>    Exempel:
>
>    ```dart
>    // FÖRE
>    await future();
>    ScaffoldMessenger.of(context).showSnackBar(snack);
>    context.go('/home');
>
>    // EFTER
>    await future();
>    context.ifMounted((c) {
>      ScaffoldMessenger.of(c).showSnackBar(snack);
>      c.go('/home');
>    });
>    ```
> 4. Ta bort manuella `if (!mounted) return;` som hör till just dessa anrop (behövs inte efter omskrivning).
>
> ---
>
> ### 3) Dotenv init (flutter\_dotenv ^6.0.0)
>
> **MÖNSTERFIX** i `lib/main.dart`:
>
> * Lägg till import (om saknas):
>   `import 'package:flutter_dotenv/flutter_dotenv.dart';`
> * I `main()` innan `runApp(...)`, lägg:
>
>   ```dart
>   WidgetsFlutterBinding.ensureInitialized();
>   await dotenv.load(fileName: ".env");
>   ```
> * Bevara befintliga init-anrop (t.ex. `initSupabase()`, Firebase-init). Ordning: **dotenv.load → initSupabase/Firebase → runApp**.
>
> ---
>
> ### 4) Slutkontroll
>
> * Säkerställ att inga kvarvarande direkta `context.*`/`Navigator`/`ScaffoldMessenger`/`showDialog`-anrop sker **efter await** utan `context.ifMounted`.
> * Ta bort oanvända `if (!mounted)` som blivit över efter omskrivningen.
> * Spara alla filer.
> * (Valfritt: lägg `const` där lints ber om det, men ändra inte logik.)
>
> **Returnera**:
>
> 1. Filen `lib/core/utils/context_safe.dart` i sin helhet.
> 2. För varje ändrad fil: ett kort block som visar *före → efter* för EN representativ omskrivning i den filen, så jag kan verifiera mönstret.
> 3. En lista över filer som uppdaterats.
>
> **SLUT.**

---








## 🧠 Codex-prompt (klistra in allt i ett meddelande till Copilot/Codex)

> Du är en refaktor-bot som **skriver och ersätter filer** i ett Flutter/Dart-projekt. Gör EXAKT följande. Skriv **fullständigt filinnehåll** när jag ber om “ERSÄTT HELT”. När jag ber om ”MÖNSTERFIX”, gör idempotenta regex-baserade omskrivningar i filen. Efter alla ändringar ska projektet analysera utan de listade varningarna.
>
> ### 1) Skapa/ersätt helper för säker `BuildContext`
>
> **ERSÄTT HELT**: `lib/core/utils/context_safe.dart`
>
> ```dart
> import 'package:flutter/material.dart';
>
> extension ContextMountedX on BuildContext {
>   /// Kör [fn] endast om contextet fortfarande är monterat.
>   T? ifMounted<T>(T Function(BuildContext c) fn) {
>     final mounted = Navigator.maybeOf(this)?.context.mounted ?? true;
>     if (!mounted) return null;
>     return fn(this);
>   }
> }
> ```
>
> ### 2) Eliminera `use_build_context_synchronously`
>
> **MÖNSTERFIX** i nedan filer och rader (om raderna flyttat, sök kontext och tillämpa samma mönster):
>
> * `lib/features/auth/forgot_password_page.dart` rader \~116,118,121,124
> * `lib/features/auth/login_page.dart` rader \~133,135,138,141
> * `lib/features/auth/signup_page.dart` rader \~145,147,150,154,157,178,181,184
> * `lib/screens/landing/landing_page.dart` rad \~51
> * `lib/screens/subscribe/subscribe_screen.dart` rad \~215
> * `lib/screens/teacher/course_editor.dart` rader \~182,184,186
> * `lib/ui/pages/course_page.dart` rad \~144
>
> **Regler för mönster**:
>
> * Hitta mönster:
>   `await <ANY>(); <CTX>.<CALL>(...);` där `<CTX>` är `context` eller funktioner som använder `context` (Navigator.of(context), ScaffoldMessenger.of(context), context.go etc) och anropet sker **efter await**.
> * Omskriv det direkta anropet till:
>
>   ```dart
>   await <ANY>();
>   context.ifMounted((c) { <REPLACE context->c i anropet> ; });
>   ```
> * Exempel:
>
>   * `ScaffoldMessenger.of(context).showSnackBar(...)` → `context.ifMounted((c) { ScaffoldMessenger.of(c).showSnackBar(...); });`
>   * `context.go('/route')` → `context.ifMounted((c) => c.go('/route'));`
>
> ### 3) Ta bort felaktig `const`-användning
>
> **MÖNSTERFIX**:
>
> * Fil: `lib/screens/home/home_shell.dart` rad \~104: Ta bort `const` från den widget som linten klagar på (`const_with_non_const`). Endast den konstruktor som inte är `const` ska av-const\:as; lämna övriga const oförändrade.
>
> ### 4) Kräv klamrar där lint vill ha dem
>
> **MÖNSTERFIX** (lägg `{}` runt enradiga if-satser):
>
> * `lib/screens/courses/quiz_take.dart` rad \~102
> * `lib/ui/pages/community_page.dart` rader \~347,349
> * `lib/ui/pages/studio_page.dart` rader \~642,674,1146
>
> Regler:
> `if (<cond>) <stmt>;` → `if (<cond>) { <stmt>; }`
>
> ### 5) Rensa triviala lints
>
> **MÖNSTERFIX**:
>
> * Ta bort oanvänd import: `package:flutter/foundation.dart` där endast `material.dart` krävs (t.ex. `lib/ui/pages/course_page.dart:7`).
> * Ta bort onödiga casts (t.ex. `lib/screens/subscribe/subscribe_screen.dart:155/215`).
> * Byt deprecierat `TextFormField(value: ...)` till `TextFormField(initialValue: ...)` (`lib/screens/teacher/course_editor.dart:453` eller där det förekommer).
> * Sätt `const` på rena, konstanta widgetkonstruktorer där linten ber om det (alla filer i lintlistan).
>
> ### 6) Dotenv 6 init (säker init innan runApp)
>
> **MÖNSTERFIX** i `lib/main.dart` (eller din entrypoint):
>
> * Lägg till topp-import: `import 'package:flutter_dotenv/flutter_dotenv.dart';`
> * I `main()` före `runApp(...)`:
>
>   ```dart
>   WidgetsFlutterBinding.ensureInitialized();
>   await dotenv.load(fileName: ".env");
>   ```
> * Om Firebase används, bevara/placera också `await Firebase.initializeApp(...)` efter dotenv-load.
>
> ### 7) file\_picker 10.x sanity
>
> Sök i projektet efter `FilePicker.platform.pickFiles`.
> Om gamla param-namn används, normalisera anropet till:
>
> ```dart
> final result = await FilePicker.platform.pickFiles(
>   allowMultiple: false,
>   type: FileType.any, // eller FileType.custom + allowedExtensions: [...]
> );
> if (result != null && result.files.isNotEmpty) {
>   final file = result.files.first;
>   // file.path / file.bytes
> }
> ```
>
> ### 8) Säkerställ att OAuth/Reset skickar korrekt redirect (ingen hårdkod)
>
> **MÖNSTERFIX** i `forgot_password_page.dart` och `signup_page.dart`:
>
> * Lägg till `import 'package:wisdom/core/auth/oauth_redirect.dart';` (om saknas).
> * Anropa:
>
>   ```dart
>   await Supabase.instance.client.auth.resetPasswordForEmail(email, redirectTo: oauthRedirect());
>   ```
>
>   samt för OAuth/magic link:
>
>   ```dart
>   await Supabase.instance.client.auth.signInWithOAuth(Provider.google, redirectTo: oauthRedirect());
>   // (samma för facebook/apple)
>   ```
>
> ### 9) Slutkontroll
>
> När alla steg ovan är applicerade: kör lokalt
> `dart format .` → `flutter analyze`
> och bekräfta att de tidigare varningarna/felen är borta.
> **Svara med**: en sammanfattning över ändrade filer och ett utdrag från (simulerad) `flutter analyze` som visar att nämnda lints/fel har försvunnit, eller tydlig lista på de som återstår och varför.
>
> **SLUT PÅ INSTRUKTION.**

---

Vill du att jag även tar fram en **separat Codex-prompt** för **Apple/Facebook provider-setup i README + .env.example** (maskat, redo att committa), eller kör vi först den här refaktorn och validerar `flutter analyze`?



Du är en refaktor-bot. Arbeta i ett Flutter/Dart-projekt. Gör exakta filändringar enligt “Deliverables”. Skriv fullständiga, körbara filinnehåll. Om filen redan finns: ersätt hela filen med det du skriver. Skapa mappar som saknas. Använd idiomatisk Dart (null-safety). Ingen pseudokod.

Mål

En delad helper som väljer korrekt redirectTo per plattform (web/desktop vs. mobil).

En sida /auth-callback som:

Fångar Supabase OAuth/Recovery-deeplinks (hash eller query),

Uppdaterar session med access_token om det finns,

Detekterar type=recovery och skickar användaren till /reset-password,

Annars skickar till “hem”// efter lyckad inloggning.

Forgot Password + Signup ska använda helpern (ingen hårdkodad URL).

GoRouter ska ha route för /auth-callback och inte blockas av public/private guards.

Antaganden

Vi använder supabase_flutter, go_router, flutter_riverpod (eller Provider – spelar ingen roll för denna sida).

Appens router heter appRouter (kan vara en global), men om okänt, exportera en GoRouter från core/routing/app_router.dart.

Deliverables (skriv fullständig kod)

1) lib/core/auth/oauth_redirect.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns the correct redirect URL for Supabase OAuth / password-recovery.
/// .env keys expected:
///  - AUTH_REDIRECT_WEB
///  - AUTH_REDIRECT_DESKTOP
///  - AUTH_REDIRECT_APP
String oauthRedirect() {
  final web = dotenv.env['AUTH_REDIRECT_WEB'];
  final desktop = dotenv.env['AUTH_REDIRECT_DESKTOP'];
  final app = dotenv.env['AUTH_REDIRECT_APP'];
  assert(web != null && desktop != null && app != null,
      'Missing redirect envs: AUTH_REDIRECT_WEB/DESKTOP/APP');

  if (kIsWeb) return web!;
  if (Platform.isAndroid || Platform.isIOS) return app!;
  return desktop!;
}

2) lib/features/auth/auth_callback_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Parses both hash (#) and query (?) fragments into a map.
Map<String, String> _parseParams(Uri uri) {
  String fragment = uri.fragment; // after '#'
  String query = uri.query;       // after '?'

  String raw = '';
  if (fragment.isNotEmpty) raw = fragment;
  if (raw.isEmpty && query.isNotEmpty) raw = query;

  if (raw.isEmpty) return const {};
  return Map<String, String>.fromEntries(
    raw.split('&').where((p) => p.contains('=')).map((p) {
      final i = p.indexOf('=');
      final k = Uri.decodeComponent(p.substring(0, i));
      final v = Uri.decodeComponent(p.substring(i + 1));
      return MapEntry(k, v);
    }),
  );
}

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_handle());
  }

  Future<void> _handle() async {
    try {
      final uri = Uri.base;
      final params = _parseParams(uri);

      // If we have a session (access_token), update Supabase auth state.
      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];
      if (accessToken != null) {
        await Supabase.instance.client.auth.setSession(
          RefreshTokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      }

      final type = params['type'];
      if (type == 'recovery') {
        if (mounted) context.go('/reset-password');
        return;
      }

      // Default bounce after OAuth sign-in or generic callback.
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline),
                  const SizedBox(height: 12),
                  Text('Auth callback failed'),
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go home'),
                  ),
                ],
              ),
      ),
    );
  }
}

3) lib/core/routing/app_router.dart — lägg till route för /auth-callback. Om filen saknas: skapa en minimal GoRouter med hem (/), reset (/reset-password) och auth-callback (/auth-callback). Se till att callback-route inte blockas av auth-guards.


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdom/features/auth/auth_callback_page.dart';

// Dummy pages to keep router compilable; replace with your real pages.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Reset Password')));
}

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordPage()),
    // Public route that must always be accessible:
    GoRoute(path: '/auth-callback', builder: (_, __) => const AuthCallbackPage()),
  ],
);

4) Uppdatera Forgot Password till helpern
Fil: lib/features/auth/forgot_password_page.dart
Byt ut eventuella hårdkodade redirectTo:. Använd:

import 'package:wisdom/core/auth/oauth_redirect.dart';
...
await Supabase.instance.client.auth.resetPasswordForEmail(
  email,
  redirectTo: oauthRedirect(),
);

5) Uppdatera Signup till helpern (om e-postbekräftelse eller magic link används)
Fil: lib/features/auth/signup_page.dart

import 'package:wisdom/core/auth/oauth_redirect.dart';
...
// Exempel om du skickar magic link eller email confirm manuellt:
await Supabase.instance.client.auth.signInWithOtp(
  email: email,
  emailRedirectTo: oauthRedirect(),
);
// eller för OAuth-knappar:
await Supabase.instance.client.auth.signInWithOAuth(
  Provider.google,
  redirectTo: oauthRedirect(),
);


6) .env.example i projektroten (om den saknas eller uppdatera)

SUPABASE_URL=https://xljbwvmkoutclqgklyhkt.supabase.co
SUPABASE_ANON_KEY=***MASKED***

AUTH_REDIRECT_WEB=http://localhost:5500/auth-callback
AUTH_REDIRECT_DESKTOP=http://localhost:5500/auth-callback
AUTH_REDIRECT_APP=wisdom://auth-callback




7) Android/iOS deeplinks (om saknas)

    android/app/src/main/AndroidManifest.xml — inuti <activity ...>:

    <intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="wisdom" android:host="auth-callback"/>
</intent-filter>


ios/Runner/Info.plist:

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>wisdom</string>
    </array>
  </dict>
</array>

Acceptance tests

Web/Desktop: Öppna http://localhost:5500/auth-callback#type=recovery → router skickar till /reset-password.

OAuth: signInWithOAuth(provider, redirectTo: oauthRedirect()) → efter login landar på /auth-callback → vidare till /.

Forgot password: Mail-länk leder till /auth-callback#...type=recovery... → vidare till /reset-password.

Ingen hårdkodad redirect-URL finns kvar i forgot password eller signup.

Svara endast med de skapade/ersatta filerna i ordning: fil-path överst och därefter full filtext.

SLUT PÅ INSTRUKTION.

Du är min kodagent i repo apps/Visdom (Flutter).

Mål: Fixa password reset-flödet så att länkar från Supabase funkar i dev (web + mobil).
Gör exakt detta:

1) Supabase-anrop:
   - I glömt-lösenord-funktionen, skicka redirectTo:
     kIsWeb ? 'http://localhost:5500/auth-callback' : 'wisdom://auth-callback'
   - Parametrera port via en central konfig (env/dotenv eller const).

2) Auth listener:
   - Lägg till en global lyssnare på `Supabase.instance.client.auth.onAuthStateChange`.
   - När event == `AuthChangeEvent.passwordRecovery` → navigera till `/reset-password`.

3) Router:
   - Skapa route `/auth-callback` som direkt redirectar till `/reset-password`.
   - Lägg route `/reset-password` och implementera sida för att sätta nytt lösenord via `auth.updateUser(UserAttributes(password: ...))`.

4) Web:
   - Säkerställ att webbuilden hanterar path `/auth-callback` (go_router).

5) Android/iOS:
   - AndroidManifest: intent-filter med scheme `wisdom`, host `auth-callback`.
   - iOS Info.plist: CFBundleURLSchemes med `wisdom`.

6) Rapportera:
   - Lista filer ändrade.
   - Visa koddiff för sendReset, auth listener, routes, ResetPasswordPage.
   - Kör `flutter run -d chrome` och bekräfta att länk från mail öppnar webappens `/auth-callback` och leder till `/reset-password`.









Plan För Lint Kill Pack

Förarbete & verktyg

Säkerställ att flutter analyze kan köras (se till att Flutter-cache inte är skrivskyddad).
Ta en snapshot (git status) så vi vet nuvarande ändringar innan stor refaktor.
Skapa hjälputrustning

Lägg till nya filer enligt brief:
a. lib/core/utils/context_safe.dart med ContextSafeNav-extension.
b. lib/core/ui/ui_consts.dart med gap/padding/radius-konstanter.
c. lib/core/theme/controls.dart med button- och radiohelpers.
Se till att alla nödvändiga exports/imports adderas där de används.
Uppdatera globalt tema

I centrala tema-/MaterialApp-konfigurationen: sätt useMaterial3: true, koppla in cleanRadioTheme/elevatedPrimaryStyle samt exportera ui_consts.
Komplettera eventuell extra logik (t.ex. kommentaren om Flutter-kanaler) enligt instruktionen.
Refaktor av huvudfiler (leveransordning)

Skriv om fullständiga filer med nya helpers, const-optimeringar, blockifiering osv:
4.1 lib/ui/pages/landing_page.dart
4.2 lib/features/teacher/course_editor.dart
4.3 lib/features/subscribe/subscribe_screen.dart
4.4 lib/features/home/home_shell.dart
4.5 lib/core/widgets/course_video.dart
4.6 lib/features/auth/login_page.dart
4.7 lib/features/auth/signup_page.dart
4.8 lib/features/auth/forgot_password_page.dart (redan i prompt)
Använd ui_consts för paddings/gaps, ContextSafeNav efter async, och nya temahelpers för knappar/Radio.
Ta bort deprecierade API:er, onödiga imports, och gör alla possible widgets const.
Verifiering & dokumentation

Kör flutter analyze (vänta på noll eller minimala varningar).
Uppdatera codex_tasks.md med notering om slutförd “Lint Kill Pack” och sammanfatta eventuella kvarvarande kända varningar (om några).
Avslut

Granska diffar, säkerställ att funktionaliteten är oförändrad.
Ge slutleveransen som kompletta filer i begärd ordning + kommenterad själv-check på slutet (alla acceptanskriterier).



MASTER PROMPT — “Lint Kill Pack” (Flutter • Dart • Supabase)

Projektmål: Rensa kvarvarande lintvarningar (~40):

prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, prefer_final_fields, avoid_unnecessary_containers, use_build_context_synchronously

Ta bort deprecated API-anrop för knappar/Radio (ersätt styleFrom och gamla MaterialStateProperty*-mönster med stabila hjälpare).

Noll förändring av funktionalitet.

Viktiga regler (följ ordagrant):

Skriv hela filer (ingen diff, inga “…”).

Behåll alla imports som behövs och ta bort överflödiga.

Alla statiska widgets/konstanter ska vara const.

Alla if/else i widget-listor ska ha block {}.

Ersätt riskabla BuildContext-anrop efter await med säkra hjälpare.

Inga stiländringar som bryter Material 3; tema-styrda knappar/radio via hjälpfunktioner.

Lämna korta kommentarer där du gör större mönsterbyten.

0) Skapa/uppdatera hjälpfiler (lägg in fullständiga filer)
A) lib/core/utils/context_safe.dart

Skapa ContextSafeNav extension med:

Future<T?> pushSafe<T>(Route<T> route)

void popSafe<T>([T? result])

Future<void> goSnack(String message)

Alla metoder använder if (!mounted) return ... för att undvika use_build_context_synchronously.

B) lib/core/ui/ui_consts.dart

Exportera konstanta gaps/paddings/radii:

gap4/8/12/16/20/24 (SizedBox)

p8/p12/p16/px16/py12 (EdgeInsets)

r12/br12 (Radius/BorderRadius)

C) lib/core/theme/controls.dart

Skapa helpers för moderna icke-deprecierade stilar:

ButtonStyle elevatedPrimaryStyle(BuildContext context)

RadioThemeData cleanRadioTheme(BuildContext context)

Använd ButtonStyle + MaterialStatePropertyAll/resolveWith och Material 3-färger från ThemeData.colorScheme.

Obs: Lägg en kompakt kommentar överst ifall någon Flutter-kanal fortfarande flaggar MaterialStateProperty* som deprecated; här är avsiktligt brett kompatibla helpers.

1) Uppdatera Theme att använda helpers (en enda plats)

I appens centrala tema (t.ex. lib/core/theme/theme.dart eller där MaterialApp skapas):

Sätt useMaterial3: true.

Lägg: 
if (...) {
  return const Widget();
}


Byt paddings/spacers till ui_consts:

SizedBox(height: 16) → gap16

EdgeInsets.symmetric(horizontal:16) → px16

EdgeInsets.all(16) → p16

Byt deprecated knappar/Radio:

Ersätt ElevatedButton.styleFrom(...) i widgets med ingen lokal style; lita på temat. Om lokal behövs: använd ButtonStyle + MaterialStatePropertyAll.

Alla Radio<T> ska vara generiska och använda cleanRadioTheme via tema (ingen deprecated fillColor).

Fix use_build_context_synchronously:

Efter await → ersätt snackbars/navigering med await context.goSnack('...'), context.pushSafe(...), context.popSafe() från context_safe.dart.

Använd if (!context.mounted) return; när du absolut måste hantera manuellt.

Prefer final/varningar:

Markera kontroller (TextEditingController etc.) som final.

Inlinera onödiga lokala variabler eller gör dem final.

Städa imports:

Ta bort oanvända; sortera alfabetiskt.

3) Globala ersättningsmönster (tillämpa där säkert – visa i koden där du gör dem)

Text('…') → const Text('…') när strängen är literal.

SizedBox(height: N) → const SizedBox(height: N) → eller ersätt med gapN från ui_consts.dart där N ∈ {4,8,12,16,20,24}.

EdgeInsets.all(N) → const EdgeInsets.all(N) → eller pN.

Lägg {} runt enradiga if/else.

4) Leveransformat

Skriv ut fullständiga filer i denna ordning (med rubrikrad som kommentar över varje):

lib/core/utils/context_safe.dart

lib/core/ui/ui_consts.dart

lib/core/theme/controls.dart

lib/ui/pages/landing_page.dart

lib/features/teacher/teacher_course_editor.dart (eller lib/features/teacher/course_editor.dart – använd den som existerar)

lib/features/subscribe/subscribe_screen.dart

lib/features/home/home_shell.dart

lib/core/widgets/course_video.dart

lib/features/auth/login_page.dart

lib/features/auth/signup_page.dart

Inga “diffs” eller förkortningar; all kod komplett och direkt kompilerbar.

5) Acceptanskriterier (självtest i slutet – skriv ut som kommentar)

flutter analyze ska minska varningar väsentligt (helst till 0 eller några enstaka projektunika).

Inga use_build_context_synchronously kvar i de listade filerna.

Inga deprecated knappar/Radio i de listade filerna.

UI beter sig identiskt (förutom konstanta optimeringar & städning).







PROMPT TILL CODEX — KLIStra IN EXAKT

Uppdrag: Refaktorera mitt Flutter-authflöde (Supabase) så att det blir rent och komplett.

Mål

Login: Minimal vy med e-post + lösenord + primärknappen “Logga in” + länk “Skapa konto” + länk “Glömt lösenord?”.

Signup: Separat sida för konto-skapande. Här får även “Skicka magisk länk” bo.

Återställ lösenord:

Sidan “Glömt lösenord?” som skickar återställningslänk via auth.resetPasswordForEmail.

När användaren öppnar länken (deep link), ska appen automatiskt navigera till “Sätt nytt lösenord” där auth.updateUser(UserAttributes(password: ...)) körs.

Router (go_router): Lägg till rutter + redirect-logik + lyssna på AuthChangeEvent.passwordRecovery.

Deeplink/URL-scheme: Lägg in exempel-konfig för Android/iOS (kommentera med TODO om paketnamn/scheme).

Krav

Använd supabase_flutter.

Material 3, responsivt, centrerade kort (maxWidth ≈ 420), inga overflow-varningar.

Svenska texter.

Formvalidering: e-postformat, lösenord min 6 tecken.

Fel ska visas med SnackBar.

Navigering: go_router. Efter lyckad login/signup → context.go('/').

På login får det inte stå “med lösenord” – bara “Logga in”.

Kod ska vara självbärande (ingen diff), med korrekta imports.

Filstruktur & leveranser (skriv ut exakt dessa fyra filer, kompletta):

lib/features/auth/login_page.dart

lib/features/auth/signup_page.dart

lib/features/auth/forgot_password_page.dart

lib/features/auth/new_password_page.dart

…samt uppdatering av en routerfil (skriv ut hela filen):
5. lib/core/routing/app_router.dart

Implementation – EXAKT BETEENDE
1) login_page.dart

Form med TextFormField (e-post), TextFormField (lösenord), FilledButton('Logga in'), TextButton('Skapa konto'), TextButton('Glömt lösenord?').

signInWithPassword(email, password).

Vid lyckad login: context.go('/').

_busy‐state med CircularProgressIndicator i knappen.

Semantics/Autofill hints.

2) signup_page.dart

Form e-post + lösenord, FilledButton('Skapa konto') → auth.signUp(email, password).

Avsnitt “Alternativ” med OutlinedButton('Skicka magisk länk') → auth.signInWithOtp(email: ..., emailRedirectTo: <REDIRECT_URL>).

Länk Har du konto? Logga in → /login.

3) forgot_password_page.dart

Enkel form för e-post.

auth.resetPasswordForEmail(email, redirectTo: '<REDIRECT_URL>').

Visa snackbar “Om adressen finns skickas en länk nu.” och navigera till /login.

4) new_password_page.dart

Två lösenordsfält (nytt + upprepa), validera match & längd.

auth.updateUser(UserAttributes(password: ...)).

Snackbar “Lösenord uppdaterat.” → context.go('/') (eller /login, kommentera varianten).

5) app_router.dart

Importera alla fyra sidor.

initialLocation: '/login'.

refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange.map((e)=>e.event)).

redirect: om ingen session och rutt inte är /login eller /signup eller /forgot-password eller /new-password → '/login'. Om session finns och rutt är /login eller /signup → '/'.

Viktigt: lägg en lyssnare i konstruktorn som fångar AuthChangeEvent.passwordRecovery och gör router.go('/new-password').

Deeplink/URL-scheme (skriv ut som kommenterade snuttar med TODO)

Använd exempel-scheme: andligapp://auth-callback (kommentera “BYT VID BEHOV”).

Visa hur man lägger till:

Supabase Dashboard → Auth → URL Configuration: Redirect URLs innehåller andligapp://auth-callback.

Android (android/app/src/main/AndroidManifest.xml) <intent-filter> för scheme/host.

iOS (ios/Runner/Info.plist) CFBundleURLTypes.

Kommentar: På web kan SITE_URL + Redirect vara http(s), men i mobil används app-scheme. resetPasswordForEmail(..., redirectTo: 'andligapp://auth-callback') måste matcha.

Extra (kommentera i koden)

Lägg await Supabase.instance.client.auth.refreshSession() som tips vid behov efter återställning.

Alla fel fångas med AuthException och generisk fallback.

Outputformat (VIKTIGT)

Skriv ut hela filinnehållet för var och en av dessa i ordning:

lib/features/auth/login_page.dart

lib/features/auth/signup_page.dart

lib/features/auth/forgot_password_page.dart

lib/features/auth/new_password_page.dart

lib/core/routing/app_router.dart

Ingen extra text mellan filerna förutom en kort rubrik // <path>.

Platshållare att använda i koden (kommentera tydligt):

  / TODO: Byt till ditt riktiga redirect:
// Ex: const _redirectUrl = 'andligapp://auth-callback';
När du är klar ska jag kunna, köra flutter run, och ha ett komplett lösenordsflöde: Login → “Glömt lösenord?” → e-postlänk → “Sätt nytt lösenord” → klart.

GLÖMM INTE ATT NOTERA I DEN HÄR FILEN VAD DU GJORT NÄR DU ÄR KLAR 

Se också till att bakrgrunds bilen som används i landingpage används heltäckande som bakrugrunds bild på varje screen i hela appen







Mål:
Gör anvandar upplevelsen Klockren
Du behöver därför se till att det finns en strukturerad plan med tydliga steg för att kunna komma fram till en home page där det finns olika screens. fokus på den med en editor som gör det möjligt att lägga upp kontent och sedan lägga ut på landing page


Mål
Eliminera blockerare och genomför 5 snabbvinster för att göra flödet “Login → Home → Teacher → Editor → Landing/Intro” friktionsfritt.

Ändra

Login-routing & CTA (Sev: Blocker)

Filer: lib/screens/auth/login.dart, ev. lib/gate.dart, lib/core/routing/app_router.dart

Gör: Efter lyckad auth (SignedIn) → gate.allow() och omdirigera till /home. Visa Snackbar “Inloggad som {email}” + gör Profile- och Teacher Home-knappar direkt tillgängliga.

Acceptans: Efter login landar man alltid i HomeShell; CTA:er syns omedelbart.

Landing: fel → skeleton & friendly copy (Sev: Blocker)

Filer: lib/data/providers.dart (landing-providers), lib/screens/landing/landing_page.dart

Gör: Fånga Postgrest/timeout/null och returnera UI-vänliga states: skeleton-kort + “Konfigurera Supabase i .env om data saknas” (endast i dev).

Acceptans: Inga råa felsträngar i UI; skeletons visas vid laddning/fel.

Persistent topp-appbar (inloggad) (Sev: Hög)

Filer: lib/screens/home/home_shell.dart (eller din primära shell), lib/core/routing/app_router.dart

Gör: Visa konsekvent top-appbar med Home, Teacher Home, Profil när currentUser != null — även på Landing.

Acceptans: Ikoner finns överallt inloggat; navigation funkar från varje vy.

Editor: tydlig Save-feedback (Sev: Hög)

Filer: lib/screens/teacher/course_editor.dart

Gör: Disable “Spara” under request; visa loader “Sparar…” och vid svar “Sparat”.

Acceptans: Ingen dubbelsubmit; visuell feedback under hela sparandet.

Teacher Home: tomvy med CTA (Sev: Medel)

Filer: lib/screens/teacher/teacher_home.dart

Gör: Om myCoursesProvider tom → visa EmptyState med knapp “Skapa första kursen” → editor.

Acceptans: Tydlig väg framåt från tom lista.

Sign-out reset (Sev: Hög)

Filer: lib/screens/auth/login.dart (eller där signOut finns), lib/gate.dart

Gör: På signOut → gate.reset() och context.go('/landing'); Snackbar “Utloggad”.

Acceptans: Man lämnar skyddade rutter; landar på Landing.

Landing: teacher cards fallback (Sev: Hög)

Filer: lib/screens/landing/landing_page.dart (lärarsektion)

Gör: Om photo_url saknas → placeholder-avatar. Om bio tom → “Bio saknas” + CTA “Uppdatera profil”.

Acceptans: Inga “tomma kort”; lärare presenteras snyggt även utan data.

Course Intro: video skeleton + play/pause UI (Sev: Hög→Medel)

Filer: lib/core/widgets/course_video.dart, lib/screens/courses/course_intro.dart

Gör: Visa 16:9 skeleton tills videon initierats; overlay med play/pause; vid fel: kort vänligt fel.

Acceptans: Ingen “död” videoyta; användaren förstår vad som händer.

URL-validering (video/cover) (Sev: Hög)

Filer: lib/screens/teacher/course_editor.dart

Gör: Enkel URL-validering; feltext under fält; disable Save om ogiltigt.

Acceptans: Ogiltig länk kan inte sparas tyst.

Landing hero CTA (Sev: Låg)

Filer: lib/screens/landing/landing_page.dart

Gör: Byt primär CTA → “Starta gratiskurs” och koppla till befintlig intro-öppning.

Acceptans: En klick tar mig till introduktionsflödet.


Klart när

Alla 10 punkter ovan fungerar i körande app utan råa fel; flödet från login till Home/Teacher/Editor/Intro är sömlöst; skeletons/fallbacks syns vid fel.











































--x-x-x-x-x-x--x-x-x-x-x--x-x-x--x-x-x-x-x-x-x--x-x-x-x-x-x--x-x-x-x-x-x-x-x-x--x-x-x-x-x-x-x--x-x-x-x-x-x--x-x-x-x--x-x-x-x-x--x-x-x--x-x-x-x-x-x-x-x-x--x-x-x-x-x-x--x-x-x-x-x-x--x-x-x-x---x-x-x-x-x--x-x
Kontext
Appen är live. Primärt syfte: en lärare loggar in, sätter sin profil, skapar kurser (inkl. video/bilder), markerar gratis introduktioner och ser dessa på landing. Backend: Supabase (app-schema, RLS/policies), Storage (avatars/media), Stripe/Gemini kan vara stubbar.

Mål

Genomför en end-to-end användarsession som teacher och bedöm användarupplevelsen.

Leverera en prioriterad lista med förbättringar (UX/flow/kopia/prestanda/accessibility), formulerade som konkreta uppgifter.

Roll / Persona

Du är en lärare som:

vill snabbt komma igång (låg tröskel)

vill ladda upp omslagsbild + video

vill publicera gratis intro-kurser som syns på landing

ogillar friktion, döda länkar, dolda fel och oklara ordval

Miljö / Antaganden

Kör på mobil (Android/iOS) och desktop (minst en av dem).

Inloggat konto har teacher/admin-rättigheter.

Storage bucket avatars/media är publikt läsbar; video kan vara extern URL.

Inga kodändringar i denna uppgift — observera, dokumentera, föreslå.

Uppgift – Gör så här (som en riktig användare)

Onboarding & Auth

Öppna appen utloggad → hur tydlig är vägen till “Logga in”?

Testa både lösenord och OTP-kod.

Notera laddtider, felmeddelanden, texter, knappers placering, state (busy/disabled).

Profile

Öppna Profil → sätt photo_url via upload/URL och skriv bio.

Spara; gå tillbaka till landing → syns fotot och kort bio i lärarsektionen?

Bedöm: fältnamn, validering, felhantering, feedback (SnackBar/loader), copy.

Skapa kurs(er)

I Teacher Home → Editor → skapa 1 betal-kurs och 1 gratis intro.

Sätt title, branch, cover_url, video_url, is_free_intro.

Spara; verifera att created_by sätts och att kursen syns korrekt i Mina kurser.

Landing & konsumtion

Gå till Landing utloggad → syns gratis-kursen med bild + “Gratis intro”?

Klicka → Course Intro: spelas videon utan krasch? Är text/CTA tydlig?

Navigera tillbaka/fram: känns flödet logiskt?

Navigation & Hitta tillbaka

Från olika djup (intro, editor, mina kurser): finns en konsekvent Home/Back?

Tar Home-knapp och Teacher Home dig dit du förväntar dig?

Fel & tomt tillstånd

Prova fel: rensa URL, skriv ogiltig länk, dra ur nätet kort.

Ser du begripliga feltexter, kvarvarande loaders, eller tyst “ingen data”?

Tom lista → visas Empty State med tydlig nästa handling?

Prestanda & polish

Kallstart, första laddning av landing, bildcache, videostart.

UI-konsistens (Material 3), spacing, typografi, ikonlogik.

Accessibility: kontrast, touch-targets, fokusordning, talkback/VoiceOver hints.

Heuristik (bedömning)

Tydlighet: kan en ny teacher förstå vad som händer nu/nästa?

Feedback: om en åtgärd tar tid/failar — ser jag det tydligt?

Friktion: hur många klick/inputs för att nå målet? Finns genvägar?

Konsekvens: samma mönster för knappar, rubriker, back/home?

Resiliens: UI klarar tomma listor, saknade bilder, långsamt nät, 403/401.

Tillgänglighet: läsbarhet, storlek, färgkontrast, etiketter.

Prestanda: upplevd snabbhet, inga onödiga omladdningar.

Leverabler (format på ditt svar)

UX-rapport (kort tabell/lista, max 1–2 meningar per rad)

Sev: Blocker / Hög / Medel / Låg

Problem (som användaren upplever)

Föreslagen lösning (konkret: vilken skärm/komponent/ordval)

Yta: Auth / Profile / Editor / Landing / Nav / Video / Performance / A11y

Effort: XS/S/M/L (snabb est.)

Top 10 Quick Wins (snabba, lågrisk, stor effekt)
Ex: “Visa ‘Sparar…’ på Editor Save-knapp + disable till svar” (Editor, Sev:Medel, Effort:S)

Blockers (måste lösas innan release/full QA)
Ex: “Gratis intro syns ej utloggad → kontrollera RLS-policy för app.courses”

Föreslagen ordningsföljd (3 sprintar)

Sprint 1: Blockers + 5 Quick Wins

Sprint 2: Navigationspolish + A11y-fixar

Sprint 3: Prestanda (bildcache, skeletons) + copy-genomgång

Skärmdumpar/anteckningar

Lista vilka steg som togs, var du var, och vad du såg (filnamn/platser).

Viktigt

Svara utan att skriva kod. Föreslå exakt vilken fil/komponent/rubrik/CTA som bör ändras, men inga diffar.

Om något verkar backendrelaterat (RLS/Storage), notera det tydligt och föreslå vilket SQL-skript/policy som sannolikt behöver ses över (namn räcker).

Fokusera på att göra flödet så friktionsfritt som möjligt för en ny teacher.

Acceptans

En prioriterad lista med 15–30 punkter (UX-rapport + Quick Wins + Blockers).

Tydlig koppling till skärmar/komponenter.

Inga kodändringar – enbart rekommendationer redo att tas in i nästa sprint.



Prompt till Codex — Profilknapp (bild + beskrivning) kopplad till “Lärare” på landing

Mål

Lägga till en Profil-knapp i appen (synlig när användaren är inloggad).

Ny skärm ProfileEditScreen där användaren kan:

ange/ändra profilbild (photo_url)

ange/ändra beskrivning (bio)

Spara till app.profiles (user_id, photo_url, bio).

Landing page: lärar-widgeten visar lärare med bild + namn + kort bio, hämtat från app.profiles.

Förutsättningar

Flutter 3, Riverpod, go_router.

Supabase init klar.

app.profiles har fälten user_id (uuid), display_name, photo_url (text), bio (text), role.

app.teacher_permissions finns (kan användas för urval av lärare).

Storage-bucket (t.ex. media eller avatars) tillgänglig.

0) SQL (idempotent): säkra fält + storage-policy

Skapa fil: supabase/profiles_avatar_bio_setup.sql

Den ska:

alter table app.profiles add column if not exists photo_url text;

alter table app.profiles add column if not exists bio text;

(Policy) om ni använder avatars-bucket: skapa idempotent SELECT-policy för publik läsning:

create policy if not exists "public read avatars" on storage.objects for select to anon, authenticated using (bucket_id='avatars');

(Valfritt) om ni vill låta inloggad användare ladda upp/uppdatera sin bild:

skriv idempotenta INSERT/UPDATE-policier för storage.objects där auth.uid() = owner (om ni använder owner-metadata).

_Notis 2024-11-23: ✅ `profiles_avatar_bio_setup.sql` tillagd med kolumner och avatars-policy._

1) Profil-knapp i topp-UI

Fil: lib/screens/home/home_shell.dart (eller motsv. top-bar)

Lägg en Profile-ikon (t.ex. Icons.person) synlig när currentUser != null.

onPressed: context.goNamed('profileEdit').

_Notis 2024-11-23: ✅ Profilknapp tillagd i HomeShell._

2) Routing

Fil: lib/core/routing/app_router.dart

Lägg route:

path: '/profile', name: profileEdit, builder → ProfileEditScreen.

_Notis 2024-11-23: ✅ Route `/profile/edit` → `ProfileEditScreen`._

3) ProfileEditScreen

Fil: lib/screens/profile/profile_edit.dart

Funktionalitet:

Visa nuvarande display_name, photo_url, bio från app.profiles för currentUser.user_id.

Fält: “Bild-URL” (textfält) eller enkel “Välj bild” om ni redan har en upload-dialog.
(För detta steg räcker Bild-URL.)

Fält: “Beskrivning” (textarea).

Spara-knapp som gör update i app.profiles för raden där user_id = currentUser.id.

_Notis 2024-11-23: ✅ `ProfileEditScreen` implementerad med foto/bio och sparknapp._

Krav:

Validera att URL är tom eller giltig (men inga hårda krav).

Efter spara: SnackBar “Profil uppdaterad”.

4) Provider för lärarlista till landing

Fil: lib/data/providers.dart

Lägg provider teachersProvider som returnerar lärare med bild + kort bio:

Strategi A (enkel): select user_id, display_name, photo_url, bio from app.profiles where role in ('teacher','admin') order by display_name asc

_Notis 2024-11-23: ✅ `teachersProvider` uppdaterad att hämta från app.profiles._

Strategi B (permissions): join mot app.teacher_permissions där can_edit_courses = true.

Välj EN strategi och dokumentera i källan.

5) Landing: koppla lärar-widget

Fil: lib/screens/landing/landing_page.dart

Använd teachersProvider för att rendera kort/grid:

Bild från photo_url (fallback till ikon om tom).

Namn från display_name.

Kort bio (trim till 120 tecken).

(Valfritt) klick på kort → future “Teacher profile” (ej krav i denna uppgift).

_Notis 2024-11-23: ✅ Landing-sidan visar foto, namn och bio för lärare._


6) Editor/övrigt (valfritt men rekommenderat)

Om Teacher Editor visar “författare”, låt editor visa profilbild + namn (läst från app.profiles) för tydlighet.

Acceptans

Profil-knapp syns när användaren är inloggad; tar dig till ProfileEditScreen.

På ProfileEditScreen går det att ange photo_url och bio och spara utan fel; värden lagras i app.profiles.

Landingens lärar-widget visar lärare (enligt vald strategi) med foto + namn + kort bio.

Bygget passerar utan Postgrest-fel (inga okända kolumner).

SQL-filen (profiles_avatar_bio_setup.sql) kan köras flera gånger utan fel (idempotent).

Om avatars-bucket används: bilder renderas publikt (tack vare SELECT-policy).


Prompt till Codex — ProfileEdit: bild-upload via Supabase Storage

Mål

I ProfileEditScreen ska användaren kunna välj bild → ladda upp → spara.

Bilden lagras i Supabase Storage (bucket avatars/), och app.profiles.photo_url uppdateras med fungerande URL.

Fungerar på Android, iOS och desktop.

0) Storage & policy (SQL – idempotent)

Skapa fil supabase/storage_avatars_setup.sql och kör den.

Den ska:

Skapa bucket avatars om den saknas (privat eller publik; välj publik för enkelhet i denna sprint).

Skapa SELECT-policy för anon+authenticated på avatars.

(Valfritt) Skapa INSERT/UPDATE/DELETE-policies för authenticated så att inloggad användare får skriva till avatars.

Bestäm URL-strategi:

Publik bucket: spara public URL i app.profiles.photo_url.

Privat bucket: spara signed URL (eller generera den vid render).

1) Beroenden & plattformsstöd

Lägg till filväljare (t.ex. file_picker) och eventuellt image_picker (för kamera/galleri).

Lägg till runtime-tillstånd för upload (busy/error/success).

Android: uppdatera manifest-rättigheter för filåtkomst om nödvändigt.

iOS: lägg NSPhotoLibraryUsageDescription i Info.plist om image_picker används.

Desktop: säkerställ att filväljaren fungerar (image/källfil).

2) ProfileEditScreen – UX & flöde

I lib/screens/profile/profile_edit.dart lägg till:

Knapp “Välj bild” → öppna filväljare (jpg/png).

Förhandsvisning av vald bild (lokal path/bytes).

Knapp “Ladda upp” → laddar upp till avatars/{userId}/{timestamp}_{slug}.jpg.

Efter lyckad upload: hämta public URL (publik bucket) eller generera signed URL om privat.

Sätt formulärfältet/bindningen för photo_url till denna URL.

“Spara” uppdaterar raden i app.profiles (photo_url, och befintlig bio).

Teknikkrav

Filstorlek: vägra > 5MB (visa fel).

Tillåt endast image/jpeg och image/png.

Hantera fel: nätverk, avbruten upload, 403 policies. Visa SnackBar.

3) Providers / Services

Om ni har en storage-service, lägg till metod:

uploadAvatar({required String userId, required Uint8List bytes, required String filename}) → String finalUrl

Om ni inte har service: placera upload-logik nära ProfileEdit för nu; dokumentera TODO att bryta ut.

4) Länka till Landing (lärar-widget)

Landingens lärar-provider/rendering ska redan läsa photo_url.

Bekräfta att nyuppladdad bild syns i lärar-listan (cache-bypass: lägg ?t=<epoch> på URL efter save eller använd Image.network med gaplessPlayback/cache-busting).

5) Telemetri & QA

Lägg enkla loggar: print('[PROFILE][UPLOAD] start/ok/fail').

Dokumentera i docs/qa_profile_avatar.md:

Android/iOS/desktop flödena, max-size, felmeddelanden, och att landing visar uppdaterad bild.

Acceptans
storage_avatars_setup.sql kan köras flera gånger utan fel (bucket + policies på plats).
I ProfileEdit kan användaren välja, ladda upp och spara ny bild.
app.profiles.photo_url uppdateras med fungerande URL (public eller signed beroende på strategi).
Landingens lärar-widget visar uppdaterad bild kort efter save.
Felhantering: >5MB, fel filtyp, nätverksfel → tydlig SnackBar.
Bygger och fungerar på Android, iOS och desktop.



Prompt till Codex — Teacher Home + Home-knapp

Mål

Lägg till en Home-knapp som, när användaren är teacher, öppnar en ny skärm TeacherHomeScreen.

TeacherHomeScreen visar: Mina kurser (filtrerat på created_by = currentUser.id) och en genväg till Kurseditor.

Sätt created_by vid skapande/uppdatering av kurs.

Förutsättningar

Flutter 3, Riverpod, go_router.

Supabase init klar. Datamodell ligger i app-schemat.

app.teacher_permissions(profile_id, can_edit_courses) finns.

0) SQL (idempotent)

Skapa fil: supabase/add_created_by_to_courses.sql

Vad den ska göra:

alter table app.courses add column if not exists created_by uuid;

(Valfritt) FK → app.profiles(user_id) (on delete set null).

När editor sparar kurs: skriv created_by = currentUser.id.

_Notis 2024-11-23: ✅ `supabase/add_created_by_to_courses.sql` tillagt._

### Uppgift: Lägg till videostöd i kursflödet

- `app.courses` har nu kolumnen `video_url` (via `supabase/add_course_video_url.sql`).
- Dart-koden använder `video_url` i stället för `intro_video_url`; videon renderas via `CourseVideo` och Teacher Editor hanterar fältet.

_Notis 2024-11-23: ✅ Videostöd infört, widgeten `CourseVideo` använder `video_player` och Teacher Editor kan spara URL._

1) Behörighets-hjälpare

Fil: lib/domain/services/auth_service.dart

Lägg en funktion Future<bool> userIsTeacher() som:

Kollar app.teacher_permissions på profile_id = currentUser.id (can_edit_courses == true).

Fallback: app.profiles.role in ('teacher','admin').

_Notis 2024-11-23: ✅ `AuthService.userIsTeacher` implementerad._

2) Provider för “Mina kurser”

Fil: lib/data/providers.dart

Lägg en FutureProvider myCoursesProvider som hämtar från app.courses fälten:
id, title, cover_url, is_free_intro, branch, created_by, created_at
filtrerat på created_by = currentUser.id sorterat nyast först.

_Notis 2024-11-23: ✅ `myCoursesProvider` hämtar egna kurser._

3) Ny skärm: TeacherHomeScreen

Fil: lib/screens/teacher/teacher_home.dart

Innehåll:

AppBar: “Teacher Home”

Två primära actions: Mina kurser (rendera listan under) och Öppna editor (navigera till befintlig editor).

Under actions: lista kurser från myCoursesProvider. På klick: öppna editor för vald kurs (skicka courseId).

_Notis 2024-11-23: ✅ `TeacherHomeScreen` byggd med kurslista och editor-genväg._

4) Routing + Home-knapp

Fil: lib/core/routing/app_router.dart

Lägg route: path: '/teacher', name: teacherHome, builder → TeacherHomeScreen.

Fil: lib/screens/home/home_shell.dart (eller motsv. topp-UI):

Lägg en Home-ikon i AppBar/BottomNav.

onPressed:

if (!await userIsTeacher()) → visa SnackBar “Endast för lärare” (ingen navigation).

annars context.goNamed('teacherHome').

_Notis 2024-11-23: ✅ Route och Home-knapp aktiverade; knappen kräver lärarbehörighet._

5) Editor: skriv created_by

Fil: lib/screens/teacher/teacher_editor.dart

När kurs skapas/uppdateras (upsert): inkludera created_by: currentUser.id.

_Notis 2024-11-23: ✅ Editor sätter `created_by` och accepterar kurs-id via query._

6) (Valfritt) RLS-policies för ägaren

Skapa fil supabase/policies_courses_owner.sql (idempotent):

Läs/uppdatera egna kurser: created_by = auth.uid().

Behåll befintlig free-intro SELECT för publik läsning.

_Notis 2024-11-23: ✅ Ägarpolicys script `supabase/policies_courses_owner.sql` skapad._

Acceptans

Utloggad eller utan teacher-rätt → Home-knappen visar SnackBar “Endast för lärare”, ingen navigation.

Inloggad teacher → Home-knapp öppnar TeacherHomeScreen.

“Mina kurser” listar endast kurser där created_by = currentUser.id.

“Öppna editor” navigerar till editorn; klick på kurs i listan öppnar editorn för den kursen.

Vid “spara kurs” sätts created_by om det saknas.

Alla filer skapade/ändrade enligt ovan; bygger utan fel.




### Uppgift: Seed & QA för delmålet "Teacher-login + gratis introduktionskurser"

**Mål**
Verifiera att lärar-login fungerar end-to-end och att gratis introduktionskurser kan skapas, sparas och visas på landing page.

**Steg**
1. **Miljövariabler**
   - Säkerställ att `.env` innehåller:
     SUPABASE_URL=<projektets URL>
     SUPABASE_ANON_KEY=<anon key från Supabase>
   - Bekräfta att dessa laddas i `lib/supabase_client.dart`.

2. **Teacher-login**
   - Logga in med användaren `odenhjalm@outlook.com`.
   - Verifiera att kontot finns i `app.profiles` med `role='teacher'` eller rad i `app.teacher_permissions`.
   - Kontrollera i loggen att `[AUTH] SignedIn` triggas.

3. **Skapa testkurser**
   - Använd Teacher Editor (`lib/screens/teacher/teacher_editor.dart`) för att skapa minst 5 kurser med:
     - `is_free_intro = true`
     - `cover_url` satt till valfri bild i bucket `media`
     - `branch` ifylld
   - Kontrollera att poster skapas i `app.courses`.

4. **Verifiera data**
   - SQL: `select id, title, is_free_intro, cover_url from app.courses where is_free_intro = true;`
   - Bekräfta att kurserna finns med rätt flaggor och fält.

5. **QA på landing page**
   - Kör `flutter run`.
   - Logga ut (anon).
   - Öppna landing page och kontrollera att:
     - Kurserna visas med `cover_url` som hero-bild.
     - Badge/text “Gratis intro” syns.
     - Klick på kurskort leder till `/course-intro/:id`.

6. **Dokumentation**
   - Dokumentera körningen i en QA-logg (t.ex. `docs/qa_seed_intro.md`) med:
     - Screenshots på login, kurseditor och landing.
     - Noteringar om buggar eller hinder.
   - Uppdatera `codex_update.md` med datum och notis: "Seed & QA: Teacher-login + gratis intro courses verifierat".

**Acceptans**
- Teacher-login fungerar med kontot `odenhjalm@outlook.com`.
- Minst 5 kurser med `is_free_intro=true` finns i `app.courses`.
- Landing page visar kurserna publikt, utan login.
- QA-logg finns dokumenterad.








Delmål: Teacher-login + gratis introduktionskurser

Supabase/Auth: Säkerställ .env med URL/anon key, initiera Supabase.initialize med PKCE (FlutterAuthClientOptions), konfigurera deep link för magic link. Verifiera att användaren odenhjalm@outlook.com har rollen teacher (via app.profiles.role eller public.teacher_permissions), och att user_is_teacher() returnerar true.
Datamodell & migrering: Bestäm att frontenden använder app-schemat. Flytta/uppdatera kursdata så fälten matchar prompten (is_free_intro, price_cents, branch, cover_url). Skriv migrations som synkar public.courses → app.courses och rensa duplicerade tabeller i kodbasen (TeacherRepo, StudioService).
Kurseditor: Uppdatera editor-vyerna så de arbetar mot app.courses/modules/lessons, stöder obligatoriska fält, hanterar free_intro-flaggan och uppladdningar till storage.media. Lägg in tydlig statusindikering och felhantering.
Seed & QA: Logga in som odenhjalm@outlook.com, skapa minst fem is_free_intro=true-kurser via editorn, och kontrollera att Supabase-tabellerna uppdateras.
Landing page: Koppla introCoursesProvider till app.courses, visa gratiskurserna med hero-bild, branch och “Gratis intro”-badge. Testa att klick leder till /course-intro och att gate.allow() låser upp /home.


Verification: Kör end-to-end-test manuellt: start > login teacher > skapa intro-kurs > se kurs på landing. Dokumentera miljövariabler och kommandon (för PR-beskrivning).
Nästa sprint: Medlemskap & betalflöden

Stripe PaymentSheet + Supabase Edge webhook (start/complete order mot app.orders).
Medlemskap/planer: få SubscribeScreen att skapa riktiga ordrar och uppdatera memberships.
Basfunktioner i home-flikar: lista kurser (med åtkomstkontroll), tjänster, profiluppdatering.
Grundläggande messaging (dm-kanaler) och notiser.
Milestones mot App Store / Google Play

M1 – Feature Complete (Beta): Teacher studio, kurskonsumtion, medlemmar, tarot/bokning MVP, admin dashboards, legal/GDPR-sidor. Firebase (Analytics, RC, Crashlytics, FCM) initieras, Gemini-kommandopalett kopplas in.
M2 – Hardening & Compliance: UI-polish (Material 3), omfattande QA på fysiska enheter, automatiska tester, säkerhetsgranskning av RLS/RPC. Förbered privacy policy/ToS, dataskyddsprocesser, loggning.
M3 – Release Prep: CI/CD-byggen (Android App Bundle, iOS .ipa via fastlane), beta via TestFlight/Play Console, samla feedback. Hantera butikslistningar (screenshots, texter, rating).
M4 – Go Live + Support: App Store/Play publicering, monitorering (Crashlytics, Analytics), incidentrutiner, supportprocess, backlog för V1.1.















Uppgift: Gör auth-UI robust (lösenord + OTP) och visa fel direkt.

Ändra:
- lib/screens/auth/login.dart

Krav:
- Lägg till global auth-logg: supabase.auth.onAuthStateChange → print [AUTH] event + user.id.
- Skapa helper tryCall(ctx, op) som visar SnackBar "OK" vid success och "Fel: {e}" vid exception, och loggar stacktrace.
- Knapparna "Logga in (lösenord)", "Skicka OTP-kod", "Verifiera OTP-kod" ska:
  - setState(isBusy=true) före await, setState(false) efter.
  - anropa signInWithPassword / signInWithOtp / verifyOTP inuti tryCall.
- Lägg till textfält för OTP-kod om saknas.
- Ingen desktop-web-redirect: verifyOTP körs i appen.

Acceptans:
- Tryck på valfri knapp → SnackBar visas alltid (OK eller Fel).
- Terminalen skriver [AUTH] SignedIn efter lyckad inloggning.

_Notis 2024-11-23: ✅ `login.dart` använder `tryCall`, visar SnackBars för alla knappar och loggar auth-händelser._

Uppgift: Säkerställ init och redirect-scheman.

Ändra:
- lib/supabase_client.dart

Krav:
- Supabase.initialize(...) med:
  - authFlowType: AuthFlowType.pkce
  - debug: true (tillfälligt)
  - FlutterAuthClientOptions korrekt
- Exportera konstant: kAppRedirect = 'andligapp://login-callback'
- Använd kAppRedirect vid signInWithOtp(emailRedirectTo: kAppRedirect)

Acceptans:
- Vid appstart skrivs "Supabase init completed" och auth-events loggas.
- signInWithOtp sätter emailRedirectTo = kAppRedirect.

_Notis 2024-11-23: ✅ `supabase_client.dart` exporterar `kAppRedirect`, initierar med PKCE + debug och kopplar auth-logg._

Uppgift: Byt alla referenser från hero_image_url till cover_url.

Ändra:
- Sök i hela projektet efter "hero_image_url".
- Primärt i: lib/data/**, lib/screens/**, modeller/repositories.

Krav:
- Modeller/JSON-mappningar använder cover_url.
- UI som renderar kurskort använder cover_url.
- Ta inte in hero_image_url igen i kod.

Acceptans:
- Projekt kompilerar.
- Inget förekomst av hero_image_url i Dart-koden.

_Notis 2024-11-23: ✅ Alla kursproviders/landing-komponenter använder `cover_url`; `rg hero_image_url` i `lib/` ger inga träffar._

Uppgift: Lägg till policies så anon/auth kan läsa free intro-innehåll.

Ändra (SQL – skapa fil supabase/policies_free_intro.sql):
- courses: SELECT där is_free_intro = true
- modules: SELECT där module.course_id hör till course.is_free_intro = true
- lessons: SELECT där lesson.module_id → course.is_free_intro = true

Krav (SQL, idempotent):
- enable RLS på app.courses, app.modules, app.lessons
- create or replace policy ... to anon,authenticated ... using(...)

Acceptans:
- Kör filen i SQL Editor utan fel.
- Anrop från appen för “Starta introduktionskurs” returnerar data (ej 403).

_Notis 2024-11-23: ✅ `supabase/policies_free_intro.sql` lägger till RLS-policies för kurser/moduler/lektioner med is_free_intro._

Uppgift: Säkra publik läsning av bucket 'media'.

Ändra (SQL – supabase/policies_storage_media.sql):
- create policy "public read media" on storage.objects for select to anon,authenticated using (bucket_id='media');

Acceptans:
- Bilder renderas på landing/course-kort utan signerade URL:er.

_Notis 2024-11-23: ✅ `supabase/policies_storage_media.sql` inför offentlig SELECT-policy för bucket 'media'._

Uppgift: Byt alla SQL-joins som använder public.teacher_permissions.* till app.teacher_permissions (eller public.teacher_permissions_compat).

Ändra:
- Sök i repo (SQL/Edge Functions/RPC/vyer).
- Byt: join ... on tp.profile_id = p.user_id AND tp.can_edit_courses = true

Krav:
- Inga joins kvar mot public.teacher_permissions.user_id.
- Om vy används: public.teacher_permissions_compat har profile_id.

Acceptans:
- Queries kör utan kolumnnamnsfel (42703).

_Notis 2024-11-23: ✅ SQL-filer använder nu `public.teacher_permissions_compat`/`app.teacher_permissions`; migreringar uppdaterade._

Uppgift: Säkerställ att migreringsfil skapar app.teacher_permissions med korrekt FK.

Ändra (SQL – supabase/introduce_app_teacher_permissions.sql):
- create table if not exists app.teacher_permissions (
    profile_id uuid primary key references app.profiles(user_id) on delete cascade,
    can_edit_courses bool not null default false,
    can_publish bool not null default false,
    granted_by uuid null,
    granted_at timestamptz null
  );
- Backfill från public.teacher_permissions.user_id.
- Backfill från app.profiles där role='teacher'.
- Skapa view public.teacher_permissions_compat.

Acceptans:
- Filen kan köras flera gånger (idempotent).
- Data finns i app.teacher_permissions.

_Notis 2024-11-23: ✅ `introduce_app_teacher_permissions.sql` skapar tabell, backfill och vy; kupongflöden skriver till app.teacher_permissions._
Uppgift: Förhindra att trasiga backup-filer stör analyze/format.

Ändra:
- Skapa tool/format.sh som kör: dart format lib test bin tool
- analysis_options.yaml → exclude: backup/**
- Byt extension på backup/*.dart → *.bak eller flytta ut mappen.

Acceptans:
- dart analyze/format körs utan att plocka upp backup.

_Notis 2024-11-23: ✅ backup-filer ligger nu under backup/*.bak, `analysis_options.yaml` exkluderar katalogen och `tool/format.sh` kör `dart format`._
