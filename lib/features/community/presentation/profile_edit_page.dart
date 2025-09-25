import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:visdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:visdom/supabase_client.dart';
import 'package:visdom/shared/widgets/go_router_back_button.dart';
import 'package:visdom/shared/utils/snack.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _photoCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _loading = false;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    if (sb == null || user == null) return;
    try {
      final res = await sb
          .schema('app')
          .from('profiles')
          .select('display_name, photo_url, bio')
          .eq('user_id', user.id)
          .maybeSingle();
      if (!mounted) return;
      final data = (res as Map?)?.cast<String, dynamic>();
      if (data != null) {
        _displayName = data['display_name'] as String?;
        _photoCtrl.text = (data['photo_url'] ?? '') as String;
        _bioCtrl.text = (data['bio'] ?? '') as String;
        setState(() {});
      }
    } on PostgrestException catch (e) {
      debugPrint('Profile load error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    final metadata = user?.userMetadata;
    final metadataName = metadata is Map<String, dynamic>
        ? metadata['full_name'] as String?
        : null;
    final displayName = _displayName ?? metadataName ?? user?.email ?? user?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const GoRouterBackButton(),
        title: const Text('Redigera profil'),
        actions: const [TopNavActionButtons()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profilinformation',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (displayName != null) ...[
                        Text('Namn',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(displayName),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _photoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Bild-URL',
                          hintText: 'https://…',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Beskrivning',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _save,
                          icon: const Icon(Icons.save),
                          label: const Text('Spara'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    if (sb == null || user == null) return;
    setState(() => _loading = true);
    try {
      final photo = _photoCtrl.text.trim();
      final bio = _bioCtrl.text.trim();
      await sb.schema('app').from('profiles').update({
        'photo_url': photo.isEmpty ? null : photo,
        'bio': bio.isEmpty ? null : bio,
      }).eq('user_id', user.id);
      if (!mounted) return;
      showSnack(context, 'Profil uppdaterad');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      showSnack(context, 'Fel: ${e.message}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
