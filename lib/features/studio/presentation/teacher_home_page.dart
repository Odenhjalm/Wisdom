import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart';
import 'package:wisdom/widgets/base_page.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(myCoursesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
        actions: const [TopNavActionButtons()],
      ),
      body: BasePage(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mina kurser',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => context.go('/teacher/editor'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Skapa kurs'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: coursesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Fel: $e')),
                  data: (courses) {
                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.7)),
                            const SizedBox(height: 12),
                            const Text(
                              'Du har inga kurser ännu.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Skapa din första kurs för att komma igång.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context.go('/teacher/editor'),
                              child: const Text('Skapa första kursen'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final title = (course['title'] ?? 'Kurs') as String;
                        final branch = course['branch'] as String?;
                        final isIntro = course['is_free_intro'] == true;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.grey.shade100,
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (branch != null && branch.isNotEmpty)
                                Text('Gren: $branch'),
                              Text(
                                isIntro
                                    ? 'Status: Gratis introduktion'
                                    : 'Status: Betal-kurs',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final id = course['id'] as String?;
                            if (id == null) return;
                            context.go('/teacher/editor?id=$id');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
