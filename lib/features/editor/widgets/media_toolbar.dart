import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:wisdom/core/env/app_config.dart';

/// Toolbar that allows inserting media HTML tags into a text editor.
class MediaToolbar extends ConsumerStatefulWidget {
  const MediaToolbar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onUploadComplete,
    this.uploadHandler,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(MediaToolbarResult result)? onUploadComplete;
  final MediaUploadHandler? uploadHandler;

  @override
  ConsumerState<MediaToolbar> createState() => _MediaToolbarState();
}

class _MediaToolbarState extends ConsumerState<MediaToolbar> {
  bool _isUploading = false;
  bool _isDraggingOver = false;
  String? _statusMessage;
  final List<MediaToolbarResult> _recentUploads = <MediaToolbarResult>[];

  bool get _supportsDesktopDrop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const buttons = [
      _MediaButtonConfig(
        label: '🖼 Bild',
        tooltip: 'Ladda upp bild (.jpg, .png, .webp)',
        type: _MediaType.image,
      ),
      _MediaButtonConfig(
        label: '🎵 Ljud',
        tooltip: 'Ladda upp ljud (.mp3, .wav, .m4a)',
        type: _MediaType.audio,
      ),
      _MediaButtonConfig(
        label: '🎬 Video',
        tooltip: 'Ladda upp video (.mp4, .mov, .webm)',
        type: _MediaType.video,
      ),
    ];

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_supportsDesktopDrop) ...[
          _buildDropRegion(theme),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final button in buttons)
              Tooltip(
                message: button.tooltip,
                child: FilledButton.tonal(
                  onPressed: _isUploading ? null : () => _handleUpload(button),
                  child: Text(
                    button.label,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
        if (_isUploading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (_statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _statusMessage!,
            style: theme.textTheme.labelSmall,
          ),
        ],
        if (_recentUploads.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentUploads(theme),
        ],
      ],
    );

    if (!_supportsDesktopDrop) {
      return content;
    }

    return DropTarget(
      onDragEntered: (_) {
        setState(() => _isDraggingOver = true);
      },
      onDragExited: (_) {
        setState(() => _isDraggingOver = false);
      },
      onDragDone: (details) {
        _isDraggingOver = false;
        unawaited(_handleDrop(details));
      },
      child: content,
    );
  }

  Widget _buildDropRegion(ThemeData theme) {
    final borderColor = _isDraggingOver
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    final backgroundColor = _isDraggingOver
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surface.withValues(alpha: 0.04);
    final textStyle = theme.textTheme.bodyMedium;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.6),
        color: backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.upload_file_outlined, color: borderColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isDraggingOver
                  ? 'Släpp filerna för att ladda upp.'
                  : 'Dra & släpp mediafiler här eller använd knapparna nedan.',
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUploads(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senaste uppladdningar',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _recentUploads
              .map((result) => _buildRecentUploadCard(theme, result))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentUploadCard(
    ThemeData theme,
    MediaToolbarResult result,
  ) {
    switch (result.mediaType) {
      case MediaToolbarType.image:
        return SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    result.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      case MediaToolbarType.audio:
      case MediaToolbarType.video:
        return Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                result.mediaType.icon,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.mediaType.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _handleUpload(_MediaButtonConfig button) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: button.type.allowedExtensions,
      allowMultiple: true,
    );

    if (!mounted) return;

    if (picked == null || picked.files.isEmpty) {
      setState(() => _statusMessage = 'Ingen fil vald.');
      return;
    }

    final requests = <_PendingUploadRequest>[];
    final skipped = <String>[];

    for (final file in picked.files) {
      final pending = _pendingFileFromPlatformFile(file);
      if (pending == null) {
        skipped.add(file.name);
        continue;
      }
      requests.add(
        _PendingUploadRequest(
          type: button.type,
          file: pending,
        ),
      );
    }

    if (requests.isEmpty) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final message = skipped.isEmpty
          ? 'Kunde inte läsa de valda filerna.'
          : 'Kunde inte läsa ${skipped.length} filer.';
      setState(() => _statusMessage = message);
      messenger?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await _uploadRequests(requests);

    if (mounted && skipped.isNotEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            skipped.length == 1
                ? 'En fil hoppades över då den saknade läsbar källa.'
                : '${skipped.length} filer hoppades över då de saknade läsbar källa.',
          ),
        ),
      );
    }
  }

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final droppedFiles = details.files;
    if (droppedFiles.isEmpty) {
      setState(() => _statusMessage = 'Ingen fil släpptes.');
      return;
    }

    final requests = <_PendingUploadRequest>[];
    final unsupported = <String>[];

    for (final file in droppedFiles) {
      final type = _mediaTypeForFileName(file.name);
      if (type == null) {
        unsupported.add(file.name);
        continue;
      }
      final pending = await _pendingFileFromXFile(file);
      if (pending == null) {
        unsupported.add(file.name);
        continue;
      }
      requests.add(_PendingUploadRequest(type: type, file: pending));
    }

    if (requests.isEmpty) {
      final message = unsupported.isEmpty
          ? 'Inga filer kunde laddas upp.'
          : 'Filerna stöds inte: ${unsupported.join(', ')}';
      setState(() => _statusMessage = message);
      messenger?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await _uploadRequests(requests);

    if (mounted && unsupported.isNotEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            unsupported.length == 1
                ? 'En fil hoppades över eftersom formatet inte stöds.'
                : '${unsupported.length} filer hoppades över eftersom formatet inte stöds.',
          ),
        ),
      );
    }
  }

  Future<void> _uploadRequests(List<_PendingUploadRequest> requests) async {
    if (!mounted || requests.isEmpty) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _isUploading = true;
      _statusMessage = requests.length == 1
          ? 'Laddar upp ${requests.first.file.name}...'
          : 'Laddar upp ${requests.length} filer...';
    });

    final successes = <MediaToolbarResult>[];
    final failures = <String>[];

    for (var i = 0; i < requests.length; i++) {
      if (!mounted) return;
      final request = requests[i];
      setState(() {
        _statusMessage =
            'Laddar upp ${request.file.name} (${i + 1}/${requests.length})...';
      });

      try {
        final result = await _uploadSingle(request);
        successes.add(result);
      } on MediaUploadException catch (error) {
        failures.add('${request.file.name}: ${error.message}');
      } catch (error) {
        failures.add('${request.file.name}: $error');
      }
    }

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      if (failures.isEmpty) {
        _statusMessage = successes.isEmpty
            ? 'Ingen fil laddades upp.'
            : 'Media uppladdad (${successes.length}).';
      } else if (successes.isEmpty) {
        _statusMessage = 'Uppladdning misslyckades.';
      } else {
        _statusMessage =
            'Media uppladdad (${successes.length}), ${failures.length} fel.';
      }
    });

    if (successes.isNotEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            successes.length == 1
                ? 'Media uppladdad.'
                : 'Media uppladdad (${successes.length} filer).',
          ),
        ),
      );
    }

    if (failures.isNotEmpty) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            failures.length == 1
                ? 'Fel vid uppladdning: ${failures.first}'
                : 'Fel vid uppladdning: ${failures.length} filer misslyckades.',
          ),
        ),
      );
    }
  }

  Future<MediaToolbarResult> _uploadSingle(
    _PendingUploadRequest request,
  ) async {
    final handler = widget.uploadHandler;
    MediaUploadResult? handlerResult;

    if (handler != null) {
      final uploadRequest = request.toPublicRequest();
      handlerResult = await handler(uploadRequest);
    }

    String url;
    String? htmlTag;

    if (handlerResult == null) {
      final config = ref.read(appConfigProvider);
      final uri = Uri.parse('${config.apiBaseUrl}/upload');
      final httpRequest = http.MultipartRequest('POST', uri);
      httpRequest.files.add(await request.file.toMultipartFile());

      final streamedResponse = await httpRequest.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw MediaUploadException(
          '(${streamedResponse.statusCode}) '
          '${streamedResponse.reasonPhrase ?? 'Okänt fel'}',
        );
      }

      final extractedUrl = _extractUrl(responseBody, config.apiBaseUrl);
      if (extractedUrl == null) {
        throw const MediaUploadException('Ogiltigt svar från servern.');
      }

      url = extractedUrl;
      htmlTag = request.type.htmlTagFor(url);
    } else {
      url = handlerResult.url;
      htmlTag = handlerResult.htmlTag;
    }

    htmlTag ??= request.type.htmlTagFor(url);
    _insertAtSelection('$htmlTag\n');

    final result = MediaToolbarResult(
      url: url,
      htmlTag: htmlTag,
      fileName: request.file.name,
      mediaType: request.type.toPublicType(),
      uploadedAt: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _recentUploads.insert(0, result);
        if (_recentUploads.length > 6) {
          _recentUploads.removeRange(6, _recentUploads.length);
        }
      });
    }

    widget.onUploadComplete?.call(result);
    return result;
  }

  void _insertAtSelection(String snippet) {
    final controller = widget.controller;
    final currentText = controller.text;
    final selection = controller.selection;
    final hasSelection = selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start <= currentText.length &&
        selection.end <= currentText.length;
    final start = hasSelection ? selection.start : currentText.length;
    final end = hasSelection ? selection.end : currentText.length;

    final updatedText = currentText.replaceRange(start, end, snippet);
    controller.value = controller.value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
      composing: TextRange.empty,
    );
    widget.focusNode?.requestFocus();
  }

  String? _extractUrl(String responseBody, String baseUrl) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final candidate = decoded['url'] ??
            decoded['downloadUrl'] ??
            decoded['download_url'] ??
            decoded['path'];
        if (candidate is String && candidate.isNotEmpty) {
          return _resolveUrl(candidate, baseUrl);
        }
      }
    } catch (_) {
      // Ignore JSON parse errors, fallback to null.
    }
    return null;
  }

  String _resolveUrl(String candidate, String baseUrl) {
    final base = Uri.parse(baseUrl);
    final uri = Uri.parse(candidate);
    if (uri.hasScheme) {
      return uri.toString();
    }
    final normalized = candidate.startsWith('/') ? candidate : '/$candidate';
    return base.resolve(normalized).toString();
  }

  MediaUploadFile? _pendingFileFromPlatformFile(PlatformFile platformFile) {
    final path = platformFile.path;
    if (path != null && path.isNotEmpty) {
      return MediaUploadFile(name: platformFile.name, path: path);
    }
    final bytes = platformFile.bytes;
    if (bytes != null) {
      return MediaUploadFile(name: platformFile.name, bytes: bytes);
    }
    return null;
  }

  Future<MediaUploadFile?> _pendingFileFromXFile(XFile file) async {
    final path = file.path;
    if (path.isNotEmpty) {
      return MediaUploadFile(name: file.name, path: path);
    }
    try {
      final bytes = await file.readAsBytes();
      return MediaUploadFile(name: file.name, bytes: bytes);
    } catch (_) {
      return null;
    }
  }
}

class MediaToolbarResult {
  MediaToolbarResult({
    required this.url,
    required this.htmlTag,
    required this.fileName,
    required this.mediaType,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  final String url;
  final String htmlTag;
  final String fileName;
  final MediaToolbarType mediaType;
  final DateTime uploadedAt;
}

enum MediaToolbarType { image, audio, video }

extension MediaToolbarTypeX on MediaToolbarType {
  String get label {
    switch (this) {
      case MediaToolbarType.image:
        return 'Bild';
      case MediaToolbarType.audio:
        return 'Ljud';
      case MediaToolbarType.video:
        return 'Video';
    }
  }

  IconData get icon {
    switch (this) {
      case MediaToolbarType.image:
        return Icons.image_outlined;
      case MediaToolbarType.audio:
        return Icons.audiotrack_outlined;
      case MediaToolbarType.video:
        return Icons.movie_creation_outlined;
    }
  }
}

enum _MediaType { image, audio, video }

extension _MediaTypeExtension on _MediaType {
  List<String> get allowedExtensions {
    switch (this) {
      case _MediaType.image:
        return const ['jpg', 'jpeg', 'png', 'webp'];
      case _MediaType.audio:
        return const ['mp3', 'wav', 'm4a'];
      case _MediaType.video:
        return const ['mp4', 'mov', 'webm'];
    }
  }

  MediaToolbarType toPublicType() {
    switch (this) {
      case _MediaType.image:
        return MediaToolbarType.image;
      case _MediaType.audio:
        return MediaToolbarType.audio;
      case _MediaType.video:
        return MediaToolbarType.video;
    }
  }

  String htmlTagFor(String url) {
    switch (this) {
      case _MediaType.image:
        return '<img src="$url" alt="" />';
      case _MediaType.audio:
        return '<audio controls src="$url"></audio>';
      case _MediaType.video:
        return '<video controls src="$url"></video>';
    }
  }
}

_MediaType? _mediaTypeForFileName(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == fileName.length - 1) {
    return null;
  }
  final ext = fileName.substring(dotIndex + 1).toLowerCase();
  for (final type in _MediaType.values) {
    if (type.allowedExtensions.contains(ext)) {
      return type;
    }
  }
  return null;
}

class _MediaButtonConfig {
  const _MediaButtonConfig({
    required this.label,
    required this.tooltip,
    required this.type,
  });

  final String label;
  final String tooltip;
  final _MediaType type;
}

class _PendingUploadRequest {
  const _PendingUploadRequest({
    required this.type,
    required this.file,
  });

  final _MediaType type;
  final MediaUploadFile file;

  MediaUploadRequest toPublicRequest() => MediaUploadRequest(
        mediaType: type.toPublicType(),
        file: file,
      );
}

class MediaUploadFile {
  const MediaUploadFile({
    required this.name,
    this.path,
    this.bytes,
  });

  final String name;
  final String? path;
  final Uint8List? bytes;

  Future<http.MultipartFile> toMultipartFile() async {
    if (path != null && path!.isNotEmpty) {
      return http.MultipartFile.fromPath('file', path!);
    }
    if (bytes != null) {
      return http.MultipartFile.fromBytes(
        'file',
        bytes!,
        filename: name,
      );
    }
    throw MediaUploadException('Saknar filinnehåll för $name.');
  }

  Future<Uint8List> readAsBytes() async {
    if (bytes != null) {
      return bytes!;
    }
    if (path != null && path!.isNotEmpty) {
      final file = File(path!);
      return file.readAsBytes();
    }
    throw MediaUploadException('Saknar filinnehåll för $name.');
  }
}

class MediaUploadException implements Exception {
  const MediaUploadException(this.message);
  final String message;

  @override
  String toString() => 'MediaUploadException: $message';
}

class MediaUploadRequest {
  const MediaUploadRequest({
    required this.mediaType,
    required this.file,
  });

  final MediaToolbarType mediaType;
  final MediaUploadFile file;
}

class MediaUploadResult {
  const MediaUploadResult({
    required this.url,
    this.htmlTag,
  });

  final String url;
  final String? htmlTag;
}

typedef MediaUploadHandler = Future<MediaUploadResult> Function(
  MediaUploadRequest request,
);
