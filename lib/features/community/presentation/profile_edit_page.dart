import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/env/app_config.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/data/repositories/profile_repository.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/go_router_back_button.dart';
import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:wisdom/widgets/base_page.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  static const _maxAvatarBytes = 5 * 1024 * 1024;

  final _displayNameCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _loading = false;

  Uint8List? _avatarDraft;
  String? _avatarDraftName;
  String? _avatarDraftContentType;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _photoCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = ref.read(authControllerProvider).profile;
    if (profile != null) {
      _applyProfile(profile);
    }

    try {
      final repo = ref.read(profileRepositoryProvider);
      final fresh = await repo.getMe();
      if (fresh != null) {
        if (!mounted) return;
        _applyProfile(fresh);
      }
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (!mounted) return;
      showSnack(context, 'Kunde inte läsa profilen: ${failure.message}');
    }
  }

  void _applyProfile(Profile profile) {
    _displayNameCtrl.text = profile.displayName ?? '';
    _photoCtrl.text = profile.photoUrl ?? '';
    _bioCtrl.text = profile.bio ?? '';
    if (!mounted) {
      _currentPhotoUrl = profile.photoUrl;
      _avatarDraft = null;
      _avatarDraftName = null;
      _avatarDraftContentType = null;
      return;
    }
    setState(() {
      _currentPhotoUrl = profile.photoUrl;
      _avatarDraft = null;
      _avatarDraftName = null;
      _avatarDraftContentType = null;
    });
  }

  String? _resolvePhotoUrl(String? path, AppConfig config) {
    if (path == null || path.isEmpty) return null;
    return Uri.parse(config.apiBaseUrl).resolve(path).toString();
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final Uint8List? data = file.bytes;
      if (data == null) {
        if (mounted) {
          showSnack(context, 'Kunde inte läsa den valda filen.');
        }
        return;
      }
      if (data.length > _maxAvatarBytes) {
        if (mounted) {
          showSnack(context, 'Bildfilen är större än 5 MB.');
        }
        return;
      }

      final contentType = _detectContentType(file.name);
      setState(() {
        _avatarDraft = data;
        _avatarDraftName = file.name;
        _avatarDraftContentType = contentType;
      });
    } catch (error) {
      if (mounted) {
        showSnack(context, 'Kunde inte välja bild: $error');
      }
    }
  }

  void _clearAvatarDraft() {
    if (!mounted) return;
    setState(() {
      _avatarDraft = null;
      _avatarDraftName = null;
      _avatarDraftContentType = null;
    });
  }

  String _detectContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.bmp')) return 'image/bmp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).profile;
    final config = ref.watch(appConfigProvider);
    final nameFallback = profile?.displayName ?? profile?.email ?? 'Profil';
    final effectivePhotoPath = _photoCtrl.text.trim().isNotEmpty
        ? _photoCtrl.text.trim()
        : _currentPhotoUrl;
    final resolvedPhotoUrl =
        _avatarDraft != null ? null : _resolvePhotoUrl(effectivePhotoPath, config);
    final ImageProvider<Object>? avatarImage = _avatarDraft != null
        ? MemoryImage(_avatarDraft!)
        : (resolvedPhotoUrl != null ? NetworkImage(resolvedPhotoUrl) : null);

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
      body: BasePage(
        child: SafeArea(
          top: false,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? const Icon(Icons.person_outline, size: 36)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FilledButton.icon(
                                    onPressed: _loading ? null : _pickAvatar,
                                    icon: const Icon(Icons.image_outlined),
                                    label: Text(
                                      _avatarDraft != null
                                          ? 'Byt vald bild'
                                          : 'Välj bild',
                                    ),
                                  ),
                                  if (_avatarDraftName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _avatarDraftName!,
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                    )
                                  else if (resolvedPhotoUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        resolvedPhotoUrl,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Max 5 MB, format: PNG/JPG/WebP.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (_avatarDraft != null)
                                    TextButton.icon(
                                      onPressed:
                                          _loading ? null : _clearAvatarDraft,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Ångra vald bild'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _displayNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Visningsnamn',
                            hintText: nameFallback,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _photoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Extern bild-URL (valfritt)',
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
                            onPressed: _loading ? null : () => _save(context),
                            icon: const Icon(Icons.save),
                            label: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Spara'),
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
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      var updated = await repo.updateMe(
        displayName: _displayNameCtrl.text.trim().isEmpty
            ? null
            : _displayNameCtrl.text.trim(),
        photoUrl:
            _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      );

      final draft = _avatarDraft;
      final draftName = _avatarDraftName;
      final draftType = _avatarDraftContentType;
      if (draft != null && draftName != null && draftType != null) {
        final avatarProfile = await repo.uploadAvatar(
          bytes: draft,
          filename: draftName,
          contentType: draftType,
        );
        updated = avatarProfile;
      }

      await ref.read(authControllerProvider.notifier).loadSession();
      if (!context.mounted) return;

      final refreshed = ref.read(authControllerProvider).profile ?? updated;
      _applyProfile(refreshed);
      showSnack(context, 'Profilen sparades.');
    } catch (error, stackTrace) {
      final failure = AppFailure.from(error, stackTrace);
      if (!context.mounted) return;
      showSnack(context, 'Kunde inte spara: ${failure.message}');
    } finally {
      if (context.mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
