import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart'; // <— BYT TILL PACKAGE-IMPORT

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AppScaffold(
      // <— INTE const
      title: 'Andlig Väg',
      disableBack: true,
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Inställningar',
        ),
        IconButton(
          onPressed: () => context.push('/profile'),
          icon: const Icon(Icons.person_rounded),
          tooltip: 'Profil',
        ),
      ],
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Välkommen hem.',
                      style: t.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Utforska introduktionskurser (5 gratis).',
                      style: t.bodyLarge),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push('/course/intro'),
                        child: const Text('Öppna introduktionskurs'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push('/studio'),
                        child: const Text('Gå till Studio (lärare)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Bli certifierad och lås upp communityt'),
              subtitle:
                  const Text('Publicera ceremonier, sessioner och läsningar.'),
              trailing: ElevatedButton(
                onPressed: () => context.push('/course/intro'),
                child: const Text('Läs mer'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
