import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart'; // <— package-import

class CoursePage extends StatelessWidget {
  final String courseId;
  const CoursePage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // <— INTE const
      title: 'Kurs',
      body: Center(child: Text('Visar kurs: $courseId')),
    );
  }
}
