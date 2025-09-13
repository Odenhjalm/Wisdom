import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inställningar',
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tema, språk (sv först), AI-läge (via Remote Config).'),
      ),
    );
  }
}
