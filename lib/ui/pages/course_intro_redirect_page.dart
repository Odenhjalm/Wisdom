import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:andlig_app/data/course_service.dart';

/// Laddar första fria introduktionskursen och navigerar vidare till dess slug.
class CourseIntroRedirectPage extends StatefulWidget {
  const CourseIntroRedirectPage({super.key});

  @override
  State<CourseIntroRedirectPage> createState() => _CourseIntroRedirectPageState();
}

class _CourseIntroRedirectPageState extends State<CourseIntroRedirectPage> {
  final _service = CourseService();
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kick();
  }

  Future<void> _kick() async {
    if (_navigated) return;
    _navigated = true;
    try {
      final c = await _service.firstFreeIntroCourse();
      if (!mounted) return;
      final slug = c?['slug'] as String?;
      if (slug != null && slug.isNotEmpty) {
        context.go('/course/$slug');
      } else {
        context.go('/');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
