import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/gate.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/shared/utils/context_safe.dart';

const _wisdomBrandGradient = LinearGradient(
  colors: [
    Color(0xFF63C7D6),
    Color(0xFF9B87EB),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _CoursesTab(),
      const _ServicesTab(),
      const _ProfileTab(),
      const _TeachersTab(),
    ];

    final sectionTitle = ['Kurser', 'Tjänster', 'Min profil', 'Lärare'][_index];
    final mediaQuery = MediaQuery.of(context);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    const logoHeight = 128.0;
    final logoCacheWidth = (logoHeight * devicePixelRatio).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 108,
        leadingWidth: logoHeight + 60,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/loggo_clea.png',
            height: logoHeight,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            cacheWidth: logoCacheWidth,
          ),
        ),
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  _wisdomBrandGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Wisdom',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 18,
              color: Colors.white.withOpacity(0.25),
            ),
            const SizedBox(width: 12),
            Text(
              sectionTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: const [TopNavActionButtons()],
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Kurser',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Tjänster',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Min profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Lärare',
          ),
        ],
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  final String title;
  const _TabPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sb = ref.read(supabaseMaybeProvider);
    if (sb == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Card(
            child: Padding(
              padding: p20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Supabase ej konfigurerat.'),
                  SizedBox(height: 8),
                  Text(
                    'Starta appen med --dart-define=SUPABASE_URL och SUPABASE_ANON_KEY.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final user = sb.auth.currentUser;
    if (user == null) {
      final emailCtrl = TextEditingController();
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: p20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Logga in',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  gap12,
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-post'),
                  ),
                  gap12,
                  FilledButton(
                    onPressed: () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) return;
                      await sb.auth.signInWithOtp(email: email);
                      context.ifMounted(
                        (c) => showSnack(
                          c,
                          'Magisk länk skickad (kontrollera din e-post).',
                        ),
                      );
                    },
                    child: const Text('Skicka magisk länk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          child: Padding(
            padding: p20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inloggad som',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gap6,
                Text(user.email ?? user.id),
                gap12,
                FilledButton.icon(
                  onPressed: () async {
                    await sb.auth.signOut();
                    gate.reset();
                    context.ifMounted((c) {
                      showSnack(c, 'Utloggad');
                      c.go('/landing');
                    });
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logga ut'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context) {
    return const _TabPlaceholder(title: 'Kurser');
  }
}

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          child: Padding(
            padding: p20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tjänster',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                gap8,
                const Text(
                    'Exempel: skapa en order (99 SEK) som stub för betalning.'),
                gap12,
                FilledButton(
                  onPressed: () => context.go('/subscribe'),
                  child: const Text('Gå till abonnemang'),
                ),
                if (user == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Logga in för att köpa.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeachersTab extends StatelessWidget {
  const _TeachersTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lärare',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          gap12,
          FilledButton.icon(
            onPressed: () => context.go('/teacher/editor'),
            icon: const Icon(Icons.edit),
            label: const Text('Öppna kurs-editor'),
          ),
        ],
      ),
    );
  }
}
