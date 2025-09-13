import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Profil, bio, certifieringar, medlemskap.'),
      ),
    );
  }
}
