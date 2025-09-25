import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:visdom/features/courses/data/courses_repository.dart';

class CoursesGrid extends StatelessWidget {
  final List<CourseSummary> courses;
  final Map<String, double>? progress; // course_id -> 0..1
  const CoursesGrid({super.key, required this.courses, this.progress});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: courses.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (_, i) {
          final c = courses[i];
          final cover = c.coverUrl ?? '';
          final title = c.title;
          final id = c.id;
          final pct = (progress?[id] ?? 0.0).clamp(0.0, 1.0);
          final slug = c.slug ?? '';
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover.isNotEmpty)
                  Image.network(cover, fit: BoxFit.cover)
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: .24),
                          Colors.white.withValues(alpha: .08),
                        ],
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .06),
                        Colors.black.withValues(alpha: .28),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (pct > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor:
                                Colors.white.withValues(alpha: .24),
                            color: Colors.white,
                            minHeight: 6,
                          ),
                        ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: slug.isEmpty
                              ? null
                              : () => context.push('/course/$slug'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Öppna',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
