4) UI-polish & “infinite width” guardrails
Mål

Alla knappar i Row använder Expanded/Flexible (inte width: double.infinity).

Lägg const där möjligt.

Gemensam spacing/typografi ur shared/theme + shared/constants.

Acceptans

Inga “BoxConstraints … Infinity” crasher.

flutter analyze grönt.

Codex-prompt

Sweep all Row button layouts: if a child button or wrapper uses double.infinity width, replace with Expanded(child: Button(...)). Keep spacing with SizedBox(width: 12).
Add const constructors where applicable.
Remove unused imports.
Ensure all snackbars go through showSnack, post-await navigation through context.ifMounted.
Confirm zero use_build_context_synchronously.
Return changed files.

5) Säkerhet & miljö (prod-redo)
Mål

.env endast public client values. Service Role aldrig i app.

oauth_redirect.dart kraschar inte i prod: fallback med tydligt fel + snack.

RLS-policies: checklista för alla tabeller som UI skriver mot.

(Valfritt) .env.prod handling, ex via --dart-define-from-file.

Acceptans

Appen startar även om env saknas → visar snackbar & block UI för auth-actions.

Inga hemligheter i repo. .gitignore täcker .env, key.properties.

Codex-prompt

Harden env handling:

In main.dart, load .env and if missing keys, set a global EnvStatus.missing and show a banner/snackbar on the landing page with instructions.

In oauth_redirect.dart, don’t assert-crash on missing env; show snack and keep the app usable (but block auth actions).

Ensure .gitignore contains .env, android/key.properties.
Return changed files.

6) Tester (minst sanity + router + en dataflow)
Mål

3 testkategorier:

Widget smoke: app start, landing render.

Router: guardar bort privat route när utloggad; släpper igenom när inloggad.

Data: repo/provider returns list, UI visar rader (mockad Supabase).

Acceptans

flutter test passerar.

Minst 3 tester som ovan.

Codex-prompt

Add tests:

test/app_smoke_test.dart: pump VisdomApp, expect landing hero present.

test/router_guard_test.dart: mock sessionProvider unauthenticated→expect /login; authenticated→expect /home.

test/courses_list_test.dart: mock coursesProvider returns 2 items→UI renders 2 cards.
Use flutter_test, mocktail.
Return new test files.

7) CI/CD (GitHub Actions)
Mål

PR-grön: format + analyze + test.

Manual workflow för flutter build appbundle --release.

Acceptans

.github/workflows/flutter.yml körs grönt på PR.

Release-workflow kan triggas manuellt.

Codex-prompt

Create .github/workflows/flutter.yml that runs on push/pull_request:

flutter pub get, dart format --output=none --set-exit-if-changed ., flutter analyze, flutter test.
Create .github/workflows/release-android.yml with a manual dispatch that builds appbundle --release and uploads as artifact.
Return both YAMLs.

8) Android build (prod)
Mål

Keystore, key.properties, release-signing.

compileSdk 34, targetSdk 34, minSdk 23/24.

Deep link visdom://auth-callback i manifest.

Acceptans

flutter build appbundle --release OK.

Intern test i Play Console fungerar.

Codex-prompt

In android/:

Set compileSdkVersion 34, targetSdkVersion 34, minSdkVersion 23.

Add digital asset links and manifest <intent-filter> for scheme visdom host auth-callback.

Ensure signingConfigs.release reads from key.properties.
Return changed gradle & manifest files.

