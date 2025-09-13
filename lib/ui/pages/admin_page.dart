import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin',
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Admin – moderation & ekonomi.'),
      ),
    );
  }
}
