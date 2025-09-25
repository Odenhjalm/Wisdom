import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> exportData() async {
      final sb = Supabase.instance.client;
      try {
        final res = await sb.rpc('app.export_user_data');
        final json = (res == null) ? '{}' : res.toString();
        await Clipboard.setData(ClipboardData(text: json));
        showSnack(context, 'Data exporterad till urklipp');
      } catch (e) {
        showSnack(context, 'Kunde inte exportera: $e');
      }
    }

    Future<void> deleteAccount() async {
      final sb = Supabase.instance.client;
      final u = sb.auth.currentUser;
      if (u == null) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Radera konto?'),
          content: const Text(
              'Detta raderar din appdata permanent (ej auth-konto). Är du säker?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Avbryt')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Radera')),
          ],
        ),
      );
      if (ok != true) return;
      try {
        await sb.rpc('app.delete_user_data', params: {'p_user': u.id});
        showSnack(context, 'Data raderad.');
      } catch (e) {
        showSnack(context, 'Kunde inte radera: $e');
      }
    }

    return AppScaffold(
      title: 'Inställningar',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tema, språk (sv först), AI-läge (via Remote Config).'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: exportData,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Exportera min data'),
                ),
                OutlinedButton.icon(
                  onPressed: deleteAccount,
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Radera mitt konto (data)'),
                ),
                OutlinedButton.icon(
                  onPressed: () => GoRouter.of(context).push('/legal/privacy'),
                  icon: const Icon(Icons.policy_rounded),
                  label: const Text('Integritetspolicy'),
                ),
                OutlinedButton.icon(
                  onPressed: () => GoRouter.of(context).push('/legal/terms'),
                  icon: const Icon(Icons.description_rounded),
                  label: const Text('Villkor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
