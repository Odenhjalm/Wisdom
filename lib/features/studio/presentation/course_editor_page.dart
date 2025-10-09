import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/glass_card.dart';
import 'package:wisdom/features/studio/data/studio_repository.dart';
import 'package:wisdom/features/studio/application/studio_providers.dart';
import 'package:wisdom/features/studio/application/studio_upload_queue.dart';
import 'package:wisdom/features/media/application/media_providers.dart';
import 'package:wisdom/features/editor/widgets/media_toolbar.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/widgets/base_page.dart';

enum _UploadKind { image, video, audio, pdf }

extension _UploadKindExtension on _UploadKind {
  IconData get icon {
    switch (this) {
      case _UploadKind.image:
        return Icons.image_outlined;
      case _UploadKind.video:
        return Icons.movie_creation_outlined;
      case _UploadKind.audio:
        return Icons.audiotrack_outlined;
      case _UploadKind.pdf:
        return Icons.picture_as_pdf_outlined;
    }
  }
}

class CourseEditorScreen extends ConsumerStatefulWidget {
  final String? courseId;
  final StudioRepository? studioRepository;
  final CoursesRepository? coursesRepository;

  const CourseEditorScreen({
    super.key,
    this.courseId,
    this.studioRepository,
    this.coursesRepository,
  });

  @override
  ConsumerState<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends ConsumerState<CourseEditorScreen> {
  bool _checking = true;
  bool _allowed = false;
  late final StudioRepository _studioRepo;
  List<Map<String, dynamic>> _courses = <Map<String, dynamic>>[];
  String? _selectedCourseId;
  List<Map<String, dynamic>> _modules = <Map<String, dynamic>>[];
  String? _selectedModuleId;
  bool _modulesLoading = false;

  List<Map<String, dynamic>> _lessons = <Map<String, dynamic>>[];
  String? _selectedLessonId;
  bool _lessonsLoading = false;
  bool _lessonIntro = false;
  bool _updatingLessonIntro = false;

  List<Map<String, dynamic>> _lessonMedia = <Map<String, dynamic>>[];
  bool _mediaLoading = false;
  String? _mediaStatus;
  bool _downloadingMedia = false;
  String? _downloadStatus;
  bool _moduleActionBusy = false;
  bool _lessonActionBusy = false;

  quill.QuillController? _lessonContentController;
  final FocusNode _lessonContentFocusNode = FocusNode();
  final ScrollController _lessonEditorScrollController = ScrollController();
  final TextEditingController _lessonTitleCtrl = TextEditingController();
  bool _lessonContentDirty = false;
  bool _lessonContentSaving = false;
  String _lastSavedLessonTitle = '';
  String _lastSavedLessonMarkdown = '';

  final ScrollController _previewScrollController = ScrollController();
  final TextEditingController _htmlEditorController = TextEditingController();
  final FocusNode _htmlEditorFocusNode = FocusNode();
  bool _htmlEditorExpanded = false;

  late final md.Document _markdownDocument;
  late final MarkdownToDelta _markdownToDelta;
  late final DeltaToMarkdown _deltaToMarkdown;

  final TextEditingController _newCourseTitle = TextEditingController();
  final TextEditingController _newCourseDesc = TextEditingController();
  final TextEditingController _courseTitleCtrl = TextEditingController();
  final TextEditingController _courseSlugCtrl = TextEditingController();
  final TextEditingController _courseDescCtrl = TextEditingController();
  final TextEditingController _coursePriceCtrl = TextEditingController();

  bool _courseMetaLoading = false;
  bool _savingCourseMeta = false;
  bool _courseIsFreeIntro = false;
  bool _courseIsPublished = false;

  static const double _previewCanvasWidth = 560;
  static const double _previewCanvasHeight = 420;
  static const double _previewOuterPadding = 16;
  static const double _previewEditorGutter = 24;
  static const double _editorMinWidth = 420;

  ProviderSubscription<List<UploadJob>>? _uploadSubscription;

  Map<String, dynamic>? _quiz;
  final TextEditingController _qPrompt = TextEditingController();
  final TextEditingController _qOptions = TextEditingController();
  final TextEditingController _qCorrect = TextEditingController();
  String _qKind = 'single';
  List<Map<String, dynamic>> _questions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _studioRepo = widget.studioRepository ?? ref.read(studioRepositoryProvider);
    _markdownDocument = md.Document(encodeHtml: false);
    _markdownToDelta = MarkdownToDelta(markdownDocument: _markdownDocument);
    _deltaToMarkdown = DeltaToMarkdown();
    _lessonTitleCtrl.addListener(_handleLessonTitleChanged);
    _replaceLessonDocument(quill.Document());
    _bootstrap();
    _uploadSubscription = ref.listenManual<List<UploadJob>>(
      studioUploadQueueProvider,
      _onUploadQueueChanged,
    );
  }

  @override
  void dispose() {
    _uploadSubscription?.close();
    _qPrompt.dispose();
    _qOptions.dispose();
    _qCorrect.dispose();
    _newCourseTitle.dispose();
    _newCourseDesc.dispose();
    _courseTitleCtrl.dispose();
    _courseSlugCtrl.dispose();
    _courseDescCtrl.dispose();
    _coursePriceCtrl.dispose();
    _lessonContentController?.removeListener(_onLessonDocumentChanged);
    _lessonContentController?.dispose();
    _lessonContentFocusNode.dispose();
    _lessonEditorScrollController.dispose();
    _lessonTitleCtrl.dispose();
    _previewScrollController.dispose();
    _htmlEditorController.dispose();
    _htmlEditorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final authState = ref.read(authControllerProvider);
    final profile = authState.profile;
    if (profile == null) {
      if (!mounted || !context.mounted) return;
      context.go('/login');
      return;
    }
    try {
      final status = await ref.read(studioRepositoryProvider).fetchStatus();
      final allowed = status.isTeacher || profile.isTeacher || profile.isAdmin;
      List<Map<String, dynamic>> myCourses = <Map<String, dynamic>>[];
      if (allowed) {
        myCourses = await _studioRepo.myCourses();
      }
      if (!mounted) return;
      final initialId = widget.courseId;
      final String? selected = (initialId != null &&
              myCourses.any((element) => element['id'] == initialId))
          ? initialId
          : (myCourses.isNotEmpty ? myCourses.first['id'] as String : null);
      setState(() {
        _allowed = allowed;
        _courses = myCourses;
        _selectedCourseId = selected;
        _checking = false;
      });
      if (_selectedCourseId != null) {
        await _loadCourseMeta();
        await _loadModules();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allowed = false;
        _checking = false;
      });
    }
  }

  Future<void> _loadCourseMeta() async {
    final courseId = _selectedCourseId;
    if (courseId == null) return;
    setState(() => _courseMetaLoading = true);
    try {
      final map = await _studioRepo.fetchCourseMeta(courseId) ?? {};
      _courseTitleCtrl.text = (map['title'] as String?) ?? '';
      _courseSlugCtrl.text = (map['slug'] as String?) ?? '';
      _courseDescCtrl.text = (map['description'] as String?) ?? '';
      final priceRaw = map['price_cents'];
      _coursePriceCtrl.text = priceRaw == null
          ? ''
          : int.tryParse('$priceRaw')?.toString() ?? '$priceRaw';
      if (mounted) {
        setState(() {
          _courseIsFreeIntro = map['is_free_intro'] == true;
          _courseIsPublished = map['is_published'] == true;
        });
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte läsa kursmetadata: $e');
      }
    } finally {
      if (mounted) setState(() => _courseMetaLoading = false);
    }
  }

  Widget _buildPreviewSection(BuildContext context) {
    final theme = Theme.of(context);
    const editorHeight = 260.0;
    final toggleIcon =
        _htmlEditorExpanded ? Icons.visibility_off : Icons.visibility;
    final toggleLabel = _htmlEditorExpanded ? 'Dölj HTML' : 'Visa HTML';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'HTML-panel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: toggleLabel,
              onPressed: () =>
                  setState(() => _htmlEditorExpanded = !_htmlEditorExpanded),
              icon: Icon(toggleIcon),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Infoga media-taggar eller skriv egen HTML som bäddas in i lektionen.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        MediaToolbar(
          controller: _htmlEditorController,
          focusNode: _htmlEditorFocusNode,
          uploadHandler: _handleHtmlMediaUpload,
        ),
        const SizedBox(height: 16),
        if (_htmlEditorExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: editorHeight),
                child: TextField(
                  controller: _htmlEditorController,
                  focusNode: _htmlEditorFocusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'HTML-innehåll',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                        width: 1.6,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    helperText:
                        'HTML-taggarna injiceras i lektionen och sparas tillsammans med ditt övriga innehåll.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _htmlEditorController.text.isEmpty
                      ? null
                      : () => setState(_htmlEditorController.clear),
                  icon: const Icon(Icons.clear),
                  label: const Text('Rensa HTML'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPreviewPane(BuildContext context) {
    return SizedBox(
      width: _previewCanvasWidth,
      height: _previewCanvasHeight,
      child: GlassCard(
        borderRadius: BorderRadius.circular(28),
        opacity: 0.14,
        borderColor: Colors.white.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _previewScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _previewScrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: _buildPreviewSection(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadModules({bool preserveSelection = true}) async {
    final courseId = _selectedCourseId;
    if (courseId == null) {
      if (mounted) {
        setState(() {
          _modules = <Map<String, dynamic>>[];
          _selectedModuleId = null;
          _lessons = <Map<String, dynamic>>[];
          _selectedLessonId = null;
          _lessonIntro = false;
          _lessonMedia = <Map<String, dynamic>>[];
        });
      }
    } else {
      if (mounted) setState(() => _modulesLoading = true);
      try {
        final list = await _studioRepo.listModules(courseId);
        if (!mounted) return;
        final listTyped = list;
        final selected = preserveSelection &&
                _selectedModuleId != null &&
                listTyped.any((m) => m['id'] == _selectedModuleId)
            ? _selectedModuleId
            : (listTyped.isNotEmpty ? listTyped.first['id'] as String : null);
        setState(() {
          _modules = listTyped;
          _selectedModuleId = selected;
        });
        if (_selectedModuleId != null) {
          await _loadLessons(preserveSelection: preserveSelection);
        } else if (mounted) {
          setState(() {
            _lessons = <Map<String, dynamic>>[];
            _selectedLessonId = null;
            _lessonIntro = false;
            _lessonMedia = <Map<String, dynamic>>[];
          });
        }
      } catch (e) {
        if (!mounted || !context.mounted) return;
        setState(() {
          _modules = <Map<String, dynamic>>[];
          _selectedModuleId = null;
          _lessons = <Map<String, dynamic>>[];
          _selectedLessonId = null;
          _lessonIntro = false;
          _lessonMedia = <Map<String, dynamic>>[];
        });
        showSnack(context, 'Kunde inte läsa moduler: $e');
      } finally {
        if (mounted) setState(() => _modulesLoading = false);
      }
    }
  }

  Future<void> _loadLessons({bool preserveSelection = true}) async {
    final moduleId = _selectedModuleId;
    if (moduleId == null) {
      if (mounted) {
        setState(() {
          _lessons = <Map<String, dynamic>>[];
          _selectedLessonId = null;
          _lessonIntro = false;
          _lessonMedia = <Map<String, dynamic>>[];
        });
      }
      _replaceLessonDocument(quill.Document(), resetDirty: true);
      _lessonTitleCtrl
        ..removeListener(_handleLessonTitleChanged)
        ..text = ''
        ..addListener(_handleLessonTitleChanged);
      return;
    }
    if (mounted) setState(() => _lessonsLoading = true);
    try {
      final list = await _studioRepo.listLessons(moduleId);
      if (!mounted) return;
      final selected = preserveSelection &&
              _selectedLessonId != null &&
              list.any((lesson) => lesson['id'] == _selectedLessonId)
          ? _selectedLessonId
          : (list.isNotEmpty ? list.first['id'] as String : null);
      final intro = selected == null
          ? false
          : (list.firstWhere((item) => item['id'] == selected)['is_intro'] ==
              true);
      setState(() {
        _lessons = list;
        _selectedLessonId = selected;
        _lessonIntro = intro;
      });
      _applySelectedLesson();
      if (_selectedLessonId != null) {
        await _loadLessonMedia();
      } else if (mounted) {
        setState(() => _lessonMedia = <Map<String, dynamic>>[]);
      }
    } catch (e) {
      if (!mounted || !context.mounted) return;
      setState(() {
        _lessons = <Map<String, dynamic>>[];
        _selectedLessonId = null;
        _lessonIntro = false;
        _lessonMedia = <Map<String, dynamic>>[];
      });
      showSnack(context, 'Kunde inte läsa lektioner: $e');
    } finally {
      if (mounted) setState(() => _lessonsLoading = false);
    }
  }

  Future<void> _loadLessonMedia() async {
    final lessonId = _selectedLessonId;
    if (lessonId == null) {
      if (mounted) setState(() => _lessonMedia = <Map<String, dynamic>>[]);
      _replaceLessonDocument(quill.Document(), resetDirty: true);
      _lessonTitleCtrl
        ..removeListener(_handleLessonTitleChanged)
        ..text = ''
        ..addListener(_handleLessonTitleChanged);
      return;
    }
    if (mounted) setState(() => _mediaLoading = true);
    try {
      final media = await _studioRepo.listLessonMedia(lessonId);
      if (!mounted) return;
      setState(() => _lessonMedia = media);
    } catch (e) {
      if (!mounted || !context.mounted) return;
      setState(() => _lessonMedia = <Map<String, dynamic>>[]);
      showSnack(context, 'Kunde inte läsa media: $e');
    } finally {
      if (mounted) setState(() => _mediaLoading = false);
    }
  }

  Map<String, dynamic>? _lessonById(String? id) {
    if (id == null) return null;
    for (final lesson in _lessons) {
      if (lesson['id'] == id) return lesson;
    }
    return null;
  }

  void _replaceLessonDocument(quill.Document document,
      {bool resetDirty = true}) {
    _lessonContentController?.removeListener(_onLessonDocumentChanged);
    _lessonContentController?.dispose();
    final controller = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    controller.addListener(_onLessonDocumentChanged);
    _lessonContentController = controller;
    if (resetDirty) {
      _lessonContentDirty = false;
    }
  }

  void _onLessonDocumentChanged() {
    if (!_lessonContentDirty) {
      setState(() => _lessonContentDirty = true);
    }
  }

  void _handleLessonTitleChanged() {
    if (!_lessonContentDirty &&
        _lessonTitleCtrl.text.trim() != _lastSavedLessonTitle) {
      setState(() => _lessonContentDirty = true);
    }
  }

  void _applySelectedLesson() {
    final lesson = _lessonById(_selectedLessonId);

    final markdown = lesson?['content_markdown'] as String? ?? '';
    quill.Document document;
    try {
      final delta = _markdownToDelta.convert(markdown);
      document = quill.Document.fromDelta(delta);
    } catch (_) {
      document = quill.Document()..insert(0, markdown);
    }

    _lastSavedLessonMarkdown = markdown;
    _lastSavedLessonTitle = lesson?['title'] as String? ?? '';

    _lessonTitleCtrl.removeListener(_handleLessonTitleChanged);
    _lessonTitleCtrl.text = _lastSavedLessonTitle;
    _lessonTitleCtrl.addListener(_handleLessonTitleChanged);

    _replaceLessonDocument(document);
    setState(() {
      _lessonContentDirty = false;
    });
  }

  void _resetLessonEdits() {
    quill.Document document;
    try {
      document = quill.Document.fromDelta(
        _markdownToDelta.convert(_lastSavedLessonMarkdown),
      );
    } catch (_) {
      document = quill.Document()..insert(0, _lastSavedLessonMarkdown);
    }

    _lessonTitleCtrl.removeListener(_handleLessonTitleChanged);
    _lessonTitleCtrl.text = _lastSavedLessonTitle;
    _lessonTitleCtrl.addListener(_handleLessonTitleChanged);
    _replaceLessonDocument(document);
    setState(() => _lessonContentDirty = false);
  }

  int _currentLessonPosition() {
    final lesson = _lessonById(_selectedLessonId);
    return lesson == null ? 0 : (lesson['position'] as int? ?? 0);
  }

  Future<void> _saveLessonContent() async {
    final controller = _lessonContentController;
    final lessonId = _selectedLessonId;
    final moduleId = _selectedModuleId;

    if (controller == null || lessonId == null || moduleId == null) {
      showSnack(context, 'Välj en lektion att spara.');
      return;
    }
    if (_lessonContentSaving) return;

    final title = _lessonTitleCtrl.text.trim().isEmpty
        ? 'Lektion'
        : _lessonTitleCtrl.text.trim();
    final markdown = _deltaToMarkdown.convert(controller.document.toDelta());

    setState(() => _lessonContentSaving = true);
    try {
      final updated = await _studioRepo.upsertLesson(
        id: lessonId,
        moduleId: moduleId,
        title: title,
        contentMarkdown: markdown,
        position: _currentLessonPosition(),
        isIntro: _lessonIntro,
      );

      if (!mounted) return;

      setState(() {
        _lessons = _lessons
            .map(
              (lesson) =>
                  lesson['id'] == lessonId ? {...lesson, ...updated} : lesson,
            )
            .toList();
        _lastSavedLessonMarkdown = markdown;
        _lastSavedLessonTitle = title;
        _lessonContentDirty = false;
      });

      if (!mounted || !context.mounted) {
        return;
      }
      showSnack(context, 'Lektion sparad.');
    } on DioException catch (error) {
      final message = _friendlyDioMessage(error);
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte spara lektion: $message');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte spara lektion: $e');
      }
    } finally {
      if (mounted) setState(() => _lessonContentSaving = false);
    }
  }

  Future<void> _insertMagicLink() async {
    final controller = _lessonContentController;
    if (controller == null) return;

    final labelController = TextEditingController(text: 'Boka nu');
    final urlController = TextEditingController(text: 'wisdom://');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Magic-link-knapp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Knapptext',
                hintText: 'Till exempel: Boka session',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Deeplink',
                hintText: 'wisdom://checkout?service_id=...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Infoga'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      labelController.dispose();
      urlController.dispose();
      return;
    }

    final label = labelController.text.trim().isEmpty
        ? 'Magic CTA'
        : labelController.text.trim();
    final url = urlController.text.trim();

    labelController.dispose();
    urlController.dispose();

    if (url.isEmpty) {
      if (mounted && context.mounted) {
        showSnack(context, 'Deeplink krävs.');
      }
      return;
    }

    final selection = controller.selection;
    final baseOffset = selection.start;
    final extentOffset = selection.end;
    final length = extentOffset - baseOffset;

    controller.replaceText(
      baseOffset,
      length,
      label,
      TextSelection.collapsed(offset: baseOffset + label.length),
    );
    controller.formatText(
      baseOffset,
      label.length,
      quill.LinkAttribute(url),
    );
    controller.updateSelection(
      TextSelection.collapsed(offset: baseOffset + label.length),
      quill.ChangeSource.local,
    );
  }

  Widget _buildLessonContentEditor(BuildContext context) {
    final controller = _lessonContentController;
    if (controller == null) {
      return const Text('Välj en lektion för att redigera innehållet.');
    }

    final hasVideo = _lessonMedia.any(
      (media) => (media['kind'] as String?) == 'video',
    );
    final hasAudio = _lessonMedia.any(
      (media) => (media['kind'] as String?) == 'audio',
    );

    final badges = <Widget>[];
    if (_lessonIntro) {
      badges.add(const Chip(
        label: Text('Gratis introduktion'),
        visualDensity: VisualDensity.compact,
      ));
    }
    if (hasVideo || hasAudio) {
      final label = hasVideo && hasAudio
          ? 'Innehåller video & ljud'
          : hasVideo
              ? 'Innehåller video'
              : 'Innehåller ljud';
      badges.add(Chip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        avatar: Icon(
          hasVideo ? Icons.movie_creation_outlined : Icons.audiotrack_outlined,
          size: 16,
        ),
      ));
    }

    final toolbarConfig = quill.QuillSimpleToolbarConfig(
      multiRowsDisplay: false,
      showDividers: false,
      showFontFamily: false,
      showFontSize: false,
      showColorButton: false,
      showBackgroundColorButton: false,
      showSubscript: false,
      showSuperscript: false,
      showSmallButton: false,
      showInlineCode: false,
      showClipboardCopy: false,
      showClipboardPaste: false,
      showClipboardCut: false,
      showSearchButton: false,
      customButtons: [
        quill.QuillToolbarCustomButtonOptions(
          icon: Icon(_UploadKind.image.icon),
          tooltip: 'Ladda upp bild',
          onPressed: () => _handleMediaToolbarUpload(_UploadKind.image),
        ),
        quill.QuillToolbarCustomButtonOptions(
          icon: Icon(_UploadKind.video.icon),
          tooltip: 'Ladda upp video',
          onPressed: () => _handleMediaToolbarUpload(_UploadKind.video),
        ),
        quill.QuillToolbarCustomButtonOptions(
          icon: Icon(_UploadKind.audio.icon),
          tooltip: 'Ladda upp ljud',
          onPressed: () => _handleMediaToolbarUpload(_UploadKind.audio),
        ),
        quill.QuillToolbarCustomButtonOptions(
          icon: Icon(_UploadKind.pdf.icon),
          tooltip: 'Ladda upp dokument (PDF)',
          onPressed: () => _handleMediaToolbarUpload(_UploadKind.pdf),
        ),
        quill.QuillToolbarCustomButtonOptions(
          icon: const Icon(Icons.auto_fix_high_rounded),
          tooltip: 'Infoga magic-link-knapp',
          onPressed: _insertMagicLink,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _lessonTitleCtrl,
          decoration: const InputDecoration(
            labelText: 'Lektionstitel',
            hintText: 'Till exempel: Introduktion till modul',
          ),
        ),
        if (badges.isNotEmpty) ...[
          gap8,
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: badges,
          ),
        ],
        gap12,
        quill.QuillSimpleToolbar(
          controller: controller,
          config: toolbarConfig,
        ),
        gap12,
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: quill.QuillEditor.basic(
              controller: controller,
              focusNode: _lessonContentFocusNode,
              scrollController: _lessonEditorScrollController,
              // ignore: unnecessary_const
              config: const quill.QuillEditorConfig(
                minHeight: 280,
                padding: EdgeInsets.all(16),
                placeholder: 'Skriv eller klistra in lektionsinnehåll...',
              ),
            ),
          ),
        ),
        gap12,
        Row(
          children: [
            FilledButton.icon(
              onPressed: !_lessonContentDirty || _lessonContentSaving
                  ? null
                  : _saveLessonContent,
              icon: _lessonContentSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Spara lektionsinnehåll'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: !_lessonContentDirty || _lessonContentSaving
                  ? null
                  : _resetLessonEdits,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Återställ'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _promptCreateModule() async {
    final courseId = _selectedCourseId;
    if (courseId == null || _moduleActionBusy) return;
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ny modul'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Titel'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Avbryt'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Skapa'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final name = title?.trim();
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    setState(() => _moduleActionBusy = true);
    try {
      final nextPos = _modules.isEmpty
          ? 1
          : _modules
                  .map((module) => (module['position'] as int? ?? 0))
                  .fold<int>(0, (a, b) => a > b ? a : b) +
              1;
      final module = await _studioRepo.createModule(
        courseId: courseId,
        title: name,
        position: nextPos,
      );
      if (!mounted) return;
      setState(() => _selectedModuleId = module['id'] as String?);
      await _loadModules(preserveSelection: true);
      if (mounted && context.mounted) {
        showSnack(context, 'Modul skapad.');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte skapa modul: $e');
      }
    } finally {
      if (mounted) setState(() => _moduleActionBusy = false);
    }
  }

  Future<void> _deleteModule(String id) async {
    if (_moduleActionBusy) return;
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ta bort modul?'),
        content: const Text('Detta tar bort modulen och dess lektioner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _moduleActionBusy = true);
    try {
      await _studioRepo.deleteModule(id);
      if (!mounted) return;
      setState(() {
        if (_selectedModuleId == id) {
          _selectedModuleId = null;
        }
      });
      await _loadModules(preserveSelection: false);
      if (mounted && context.mounted) {
        showSnack(context, 'Modul borttagen.');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte ta bort modul: $e');
      }
    } finally {
      if (mounted) setState(() => _moduleActionBusy = false);
    }
  }

  Future<void> _promptCreateLesson() async {
    final moduleId = _selectedModuleId;
    if (moduleId == null || _lessonActionBusy) return;
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ny lektion'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Titel'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Skapa'),
          ),
        ],
      ),
    );
    controller.dispose();
    final name = title?.trim();
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    setState(() => _lessonActionBusy = true);
    try {
      final nextPos = _lessons.isEmpty
          ? 1
          : _lessons
                  .map((lesson) => (lesson['position'] as int? ?? 0))
                  .fold<int>(0, (a, b) => a > b ? a : b) +
              1;
      final lesson = await _studioRepo.upsertLesson(
        moduleId: moduleId,
        title: name,
        position: nextPos,
        isIntro: false,
      );
      if (!mounted) return;
      setState(() {
        _selectedLessonId = lesson['id'] as String?;
        _lessonIntro = lesson['is_intro'] == true;
      });
      await _loadLessons(preserveSelection: true);
      if (mounted && context.mounted) {
        showSnack(context, 'Lektion skapad.');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte skapa lektion: $e');
      }
    } finally {
      if (mounted) setState(() => _lessonActionBusy = false);
    }
  }

  Future<void> _deleteLesson(String id) async {
    if (_lessonActionBusy) return;
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ta bort lektion?'),
        content: const Text('Detta tar bort lektionen och dess media.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _lessonActionBusy = true);
    try {
      await _studioRepo.deleteLesson(id);
      if (!mounted) return;
      setState(() {
        if (_selectedLessonId == id) {
          _selectedLessonId = null;
          _lessonIntro = false;
        }
      });
      await _loadLessons(preserveSelection: false);
      if (mounted && context.mounted) {
        showSnack(context, 'Lektion borttagen.');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte ta bort lektion: $e');
      }
    } finally {
      if (mounted) setState(() => _lessonActionBusy = false);
    }
  }

  Future<void> _setLessonIntro(bool value) async {
    final lessonId = _selectedLessonId;
    if (lessonId == null || _updatingLessonIntro) return;
    if (mounted) {
      setState(() {
        _lessonIntro = value;
        _updatingLessonIntro = true;
      });
    }
    try {
      await _studioRepo.updateLessonIntro(lessonId: lessonId, isIntro: value);
      if (mounted) {
        setState(() {
          _lessons = _lessons
              .map(
                (lesson) => lesson['id'] == lessonId
                    ? {...lesson, 'is_intro': value}
                    : lesson,
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _lessonIntro = !value);
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte uppdatera intro-flagga: $e');
      }
    } finally {
      if (mounted) setState(() => _updatingLessonIntro = false);
    }
  }

  Future<void> _pickAndUploadWith(List<String> extensions) async {
    final courseId = _selectedCourseId;
    final lessonId = _selectedLessonId;
    if (courseId == null || lessonId == null) {
      showSnack(context, 'Välj kurs och lektion innan du laddar upp.');
      return;
    }

    final typeGroup = fs.XTypeGroup(label: 'media', extensions: extensions);
    final file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      if (mounted) {
        setState(() => _mediaStatus = 'Ingen fil vald.');
      }
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      final contentType = _guessContentType(file.name);
      ref.read(studioUploadQueueProvider.notifier).enqueueUpload(
            courseId: courseId,
            lessonId: lessonId,
            data: bytes,
            filename: file.name,
            contentType: contentType,
            isIntro: _lessonIntro,
          );
      if (mounted) {
        setState(() => _mediaStatus = 'Köade ${file.name}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _mediaStatus = 'Fel vid läsning av fil: $e');
      }
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte läsa filen: $e');
      }
    }
  }

  Future<void> _handleMediaToolbarUpload(_UploadKind kind) async {
    if (_selectedCourseId == null || _selectedLessonId == null) {
      showSnack(context, 'Välj kurs och lektion innan du laddar upp media.');
      return;
    }
    switch (kind) {
      case _UploadKind.image:
        await _pickAndUploadWith(
            const ['png', 'jpg', 'jpeg', 'gif', 'webp', 'heic']);
        break;
      case _UploadKind.video:
        await _pickAndUploadWith(const ['mp4', 'mov', 'm4v', 'webm', 'mkv']);
        break;
      case _UploadKind.audio:
        await _pickAndUploadWith(const ['mp3', 'wav', 'm4a', 'aac', 'ogg']);
        break;
      case _UploadKind.pdf:
        await _pickAndUploadWith(const ['pdf']);
        break;
    }
  }

  Future<MediaUploadResult> _handleHtmlMediaUpload(
    MediaUploadRequest request,
  ) async {
    final courseId = _selectedCourseId;
    final lessonId = _selectedLessonId;
    if (courseId == null || lessonId == null) {
      if (mounted) {
        showSnack(
          context,
          'Välj kurs och lektion innan du laddar upp media.',
        );
      }
      throw const MediaUploadException(
        'Ingen kurs/lektion vald för uppladdning.',
      );
    }

    try {
      final data = await request.file.readAsBytes();
      final contentType = _guessContentType(request.file.name);
      final media = await _studioRepo.uploadLessonMedia(
        courseId: courseId,
        lessonId: lessonId,
        data: data,
        filename: request.file.name,
        contentType: contentType,
        isIntro: _lessonIntro,
      );

      final dynamic downloadRaw = media['download_url'] ??
          media['downloadUrl'] ??
          media['url'] ??
          media['storage_path'];
      if (downloadRaw is! String || downloadRaw.isEmpty) {
        throw const MediaUploadException(
          'Servern returnerade ingen nedladdningsadress.',
        );
      }

      final mediaRepo = ref.read(mediaRepositoryProvider);
      final url = mediaRepo.resolveUrl(downloadRaw);
      await _loadLessonMedia();
      if (mounted && !_htmlEditorExpanded) {
        setState(() => _htmlEditorExpanded = true);
      }
      return MediaUploadResult(url: url);
    } on DioException catch (error) {
      final message = _friendlyDioMessage(error);
      if (mounted) {
        showSnack(context, message);
      }
      throw MediaUploadException(message);
    } catch (error, stack) {
      debugPrint('HTML media upload failed: $error\n$stack');
      if (error is MediaUploadException) {
        rethrow;
      }
      if (mounted) {
        showSnack(context, 'Fel vid uppladdning: $error');
      }
      throw MediaUploadException(error.toString());
    }
  }

  String _guessContentType(String filename) {
    final segments = filename.toLowerCase().split('.');
    final ext = segments.length > 1 ? segments.last : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'webm':
        return 'video/webm';
      case 'mkv':
        return 'video/x-matroska';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  String _friendlyDioMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Sessionen verkar ha gått ut. Logga in igen och försök på nytt.';
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }
    final reason = error.response?.statusMessage;
    if (reason != null && reason.isNotEmpty) {
      return reason;
    }
    return error.message ?? 'Nätverksfel';
  }

  void _onUploadQueueChanged(
    List<UploadJob>? previous,
    List<UploadJob> next,
  ) {
    if (!mounted) return;
    final lessonId = _selectedLessonId;
    if (lessonId == null) return;

    for (final job in next.where((job) => job.lessonId == lessonId)) {
      final old = _findJob(previous, job.id);
      if (job.status == UploadJobStatus.success &&
          old?.status != UploadJobStatus.success) {
        unawaited(_loadLessonMedia());
        if (context.mounted) {
          showSnack(context, 'Media uppladdad: ${job.filename}');
        }
      } else if (job.status == UploadJobStatus.failed &&
          old?.status != UploadJobStatus.failed) {
        if (context.mounted) {
          showSnack(context, 'Uppladdning misslyckades: ${job.filename}');
        }
      }
    }
  }

  UploadJob? _findJob(List<UploadJob>? jobs, String id) {
    if (jobs == null) return null;
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  Widget _buildUploadJobCard(UploadJob job) {
    final queue = ref.read(studioUploadQueueProvider.notifier);
    final theme = Theme.of(context);
    final status = job.status;
    final now = DateTime.now();
    final kind = _kindForContentType(job.contentType);
    final icon = _iconForMedia(kind);

    String statusText;
    Color? statusColor;
    Widget? progress;
    final actions = <Widget>[];

    switch (status) {
      case UploadJobStatus.uploading:
        final percent =
            (job.progress * 100).clamp(0.0, 100.0).toStringAsFixed(0);
        statusText = 'Laddar upp $percent%';
        progress = LinearProgressIndicator(value: job.progress.clamp(0, 1));
        actions.add(TextButton.icon(
          onPressed: () => queue.cancelUpload(job.id),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Avbryt'),
        ));
        break;
      case UploadJobStatus.pending:
        if (job.scheduledAt != null && job.scheduledAt!.isAfter(now)) {
          final rawRemaining = job.scheduledAt!.difference(now).inSeconds;
          final remaining = rawRemaining <= 0 ? 1 : rawRemaining;
          statusText = 'Försök igen om ${remaining}s';
        } else {
          statusText = 'Köad';
        }
        actions.add(TextButton.icon(
          onPressed: () => queue.cancelUpload(job.id),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Avbryt'),
        ));
        break;
      case UploadJobStatus.failed:
        statusText = job.error ?? 'Uppladdningen misslyckades';
        statusColor = theme.colorScheme.error;
        actions.add(TextButton.icon(
          onPressed: () => queue.retryUpload(job.id),
          icon: const Icon(Icons.refresh),
          label: const Text('Försök igen'),
        ));
        actions.add(IconButton(
          tooltip: 'Rensa',
          icon: const Icon(Icons.clear),
          onPressed: () => queue.removeJob(job.id),
        ));
        break;
      case UploadJobStatus.cancelled:
        statusText = job.error ?? 'Avbruten';
        statusColor = theme.colorScheme.outline;
        actions.add(IconButton(
          tooltip: 'Rensa',
          icon: const Icon(Icons.clear),
          onPressed: () => queue.removeJob(job.id),
        ));
        break;
      case UploadJobStatus.success:
        statusText = 'Uppladdning klar';
        statusColor = theme.colorScheme.secondary;
        actions.add(IconButton(
          tooltip: 'Rensa',
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => queue.removeJob(job.id),
        ));
        break;
    }

    final attemptInfo =
        'Försök ${job.attempts}/${job.maxAttempts} • ${job.createdAt.toLocal()}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    job.filename,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                for (final action in actions) ...[
                  const SizedBox(width: 8),
                  action,
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
            ),
            const SizedBox(height: 4),
            Text(
              attemptInfo,
              style: theme.textTheme.labelSmall,
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              progress,
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _downloadMedia(Map<String, dynamic> media) async {
    if (_downloadingMedia) return;
    final name = _fileNameFromMedia(media);
    setState(() {
      _downloadingMedia = true;
      _downloadStatus = 'Hämtar $name…';
    });
    try {
      Uint8List bytes;
      final downloadPath = media['download_url'] as String?;
      if (downloadPath != null && downloadPath.isNotEmpty) {
        final cacheKey = (media['media_id'] ?? media['id']).toString();
        final extension = _extensionFromFileName(name);
        bytes = await ref.read(mediaRepositoryProvider).cacheMediaBytes(
              cacheKey: cacheKey,
              downloadPath: downloadPath,
              fileExtension: extension,
            );
      } else {
        bytes = await _studioRepo.downloadMedia(media['id'] as String);
      }
      final location = await fs.getSaveLocation(suggestedName: name);
      if (location == null) {
        if (mounted) {
          setState(() {
            _downloadingMedia = false;
            _downloadStatus = 'Hämtning avbruten.';
          });
        }
        return;
      }
      final file = fs.XFile.fromData(
        bytes,
        mimeType: _mimeForKind(media['kind'] as String?),
        name: name,
      );
      await file.saveTo(location.path);
      if (mounted) {
        setState(() {
          _downloadingMedia = false;
          _downloadStatus = 'Sparad till ${location.path}';
        });
      }
      if (mounted && context.mounted) {
        showSnack(context, 'Media sparad till ${location.path}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadingMedia = false;
          _downloadStatus = 'Fel vid hämtning: $e';
        });
      }
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte hämta media: $e');
      }
    }
  }

  String? _resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      return ref.read(mediaRepositoryProvider).resolveUrl(path);
    } catch (_) {
      return path;
    }
  }

  String _fileNameFromMedia(Map<String, dynamic> media) {
    final originalName = media['original_name'] as String?;
    if (originalName != null && originalName.isNotEmpty) {
      return originalName;
    }
    final storagePath = media['storage_path'] as String?;
    if (storagePath != null && storagePath.isNotEmpty) {
      final segments = storagePath.split('/');
      return segments.isNotEmpty ? segments.last : storagePath;
    }
    final download = media['download_url'] as String?;
    if (download != null && download.isNotEmpty) {
      final uri = Uri.parse(download);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    }
    final id = media['id'];
    return id != null ? 'media_$id' : 'media.bin';
  }

  String? _extensionFromFileName(String name) {
    final index = name.lastIndexOf('.');
    if (index <= 0 || index == name.length - 1) return null;
    final ext = name.substring(index + 1).toLowerCase();
    return ext.isEmpty ? null : ext;
  }

  String _mimeForKind(String? kind) {
    switch (kind) {
      case 'image':
        return 'image/*';
      case 'video':
        return 'video/*';
      case 'audio':
        return 'audio/*';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  String _kindForContentType(String contentType) {
    if (contentType.startsWith('image/')) return 'image';
    if (contentType.startsWith('video/')) return 'video';
    if (contentType.startsWith('audio/')) return 'audio';
    if (contentType == 'application/pdf') return 'pdf';
    return 'other';
  }

  IconData _iconForMedia(String? kind) {
    switch (kind) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.movie_creation_outlined;
      case 'audio':
        return Icons.audiotrack_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _previewMedia(Map<String, dynamic> media) async {
    final kind = media['kind'] as String? ?? 'other';
    final url = _resolveMediaUrl(media['download_url'] as String?);
    if (!mounted) return;
    if (kind == 'image' && url != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      );
    } else {
      await _downloadMedia(media);
    }
  }

  Future<void> _handleMediaReorder(int oldIndex, int newIndex) async {
    if (_selectedLessonId == null) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _lessonMedia.removeAt(oldIndex);
      _lessonMedia.insert(newIndex, item);
    });
    try {
      await _studioRepo.reorderLessonMedia(
        _selectedLessonId!,
        _lessonMedia.map((media) => media['id'] as String).toList(),
      );
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Kunde inte spara ordning: $e');
      await _loadLessonMedia();
    }
  }

  Future<void> _deleteMedia(String id) async {
    try {
      await _studioRepo.deleteLessonMedia(id);
      await _loadLessonMedia();
      if (mounted && context.mounted) {
        showSnack(context, 'Media borttagen.');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte ta bort media: $e');
      }
    }
  }

  Future<void> _saveCourseMeta() async {
    final courseId = _selectedCourseId;
    if (courseId == null || _savingCourseMeta) return;
    final title = _courseTitleCtrl.text.trim();
    final slug = _courseSlugCtrl.text.trim();
    final desc = _courseDescCtrl.text.trim();
    final priceText = _coursePriceCtrl.text.trim();
    final price = priceText.isEmpty ? 0 : int.tryParse(priceText);

    if (title.isEmpty) {
      showSnack(context, 'Titel krävs.');
      return;
    }
    if (slug.isEmpty) {
      showSnack(context, 'Slug krävs.');
      return;
    }
    if (price == null || price < 0) {
      showSnack(context, 'Pris måste vara ett heltal ≥ 0.');
      return;
    }
    if (_courseIsPublished && price == 0) {
      showSnack(context, 'Varning: Sätt ett pris innan du publicerar kursen.');
      return;
    }

    final patch = <String, dynamic>{
      'title': title,
      'slug': slug,
      'description': desc.isEmpty ? null : desc,
      'price_cents': price,
      'is_free_intro': _courseIsFreeIntro,
      'is_published': _courseIsPublished,
    };

    setState(() => _savingCourseMeta = true);
    try {
      final updated = await _studioRepo.updateCourse(courseId, patch);
      final map = Map<String, dynamic>.from(updated);
      setState(() {
        _courses = _courses
            .map(
              (course) =>
                  course['id'] == courseId ? {...course, ...map} : course,
            )
            .toList();
      });
      ref.invalidate(myCoursesProvider);
      await _loadCourseMeta();
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kursinformation sparad.');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte spara kurs: $e');
    } finally {
      if (mounted) setState(() => _savingCourseMeta = false);
    }
  }

  String _slugify(String input) {
    final normalized = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9äöå]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .trim();
    final base = normalized.isNotEmpty ? normalized : 'kurs';
    final random = Random().nextInt(1 << 20).toRadixString(36);
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$base-$random-$ts';
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text('Kursstudio'),
      actions: const [TopNavActionButtons()],
    );
  }

  Future<void> _createCourse() async {
    final profile = ref.read(authControllerProvider).profile;
    if (profile == null) {
      if (!mounted || !context.mounted) return;
      context.go('/login');
      return;
    }
    final title = _newCourseTitle.text.trim();
    final desc = _newCourseDesc.text.trim();
    if (title.isEmpty) {
      showSnack(context, 'Titel krävs.');
      return;
    }
    try {
      final slug = _slugify(title);
      final inserted = await _studioRepo.createCourse(
        title: title,
        slug: slug,
        description: desc.isEmpty ? null : desc,
      );
      if (!mounted) return;
      final row = Map<String, dynamic>.from(inserted);
      setState(() {
        _courses = <Map<String, dynamic>>[row, ..._courses];
        _selectedCourseId = row['id'] as String;
      });
      ref.invalidate(myCoursesProvider);
      _newCourseTitle.clear();
      _newCourseDesc.clear();
      await _loadCourseMeta();
      await _loadModules();
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kurs skapad.');
    } on AppFailure catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte skapa: ${e.message}');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Något gick fel: $e');
    }
  }

  Future<void> _ensureQuiz() async {
    final cid = _selectedCourseId;
    if (cid == null) return;
    try {
      final quiz = await _studioRepo.ensureQuiz(cid);
      final qs = await _studioRepo.quizQuestions(quiz['id'] as String);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _questions = qs;
      });
    } on AppFailure catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte ladda quiz: ${e.message}');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte ladda quiz: $e');
    }
  }

  Future<void> _addQuestion() async {
    if (_quiz == null) {
      await _ensureQuiz();
      if (_quiz == null) return;
    }
    if (!mounted) return;
    final quizId = _quiz!['id'] as String;
    final prompt = _qPrompt.text.trim();
    if (prompt.isEmpty) {
      showSnack(context, 'Frågetext krävs.');
      return;
    }
    final pos = _questions.isEmpty
        ? 0
        : _questions
                .map((e) => (e['position'] ?? 0) as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    dynamic options;
    dynamic correct;
    if (_qKind == 'single') {
      options = _qOptions.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      correct = int.tryParse(_qCorrect.text.trim());
      if (correct == null) {
        showSnack(context, 'Rätt svar: använd ett index (t.ex. 0).');
        return;
      }
    } else if (_qKind == 'multi') {
      options = _qOptions.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      correct = _qCorrect.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toList();
      if ((correct as List).isEmpty) {
        showSnack(context, 'Rätt svar: använd index (t.ex. 0,2).');
        return;
      }
    } else {
      final v = _qCorrect.text.trim().toLowerCase();
      if (v != 'true' && v != 'false') {
        showSnack(context, 'Rätt svar: true eller false.');
        return;
      }
      options = null;
      correct = v == 'true';
    }

    final data = {
      'quiz_id': quizId,
      'position': pos,
      'kind': _qKind,
      'prompt': prompt,
      'options': options,
      'correct': correct,
    };
    try {
      await _studioRepo.upsertQuestion(quizId: quizId, data: data);
      _qPrompt.clear();
      _qOptions.clear();
      _qCorrect.clear();
      final qs = await _studioRepo.quizQuestions(quizId);
      if (mounted) setState(() => _questions = qs);
    } on AppFailure catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte spara quizfråga: ${e.message}');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Fel vid quizfråga: $e');
    }
  }

  Future<void> _deleteQuestion(String id) async {
    try {
      await _studioRepo.deleteQuestion(_quiz!['id'] as String, id);
      if (_quiz != null) {
        final qs = await _studioRepo.quizQuestions(_quiz!['id'] as String);
        if (!mounted) return;
        setState(() => _questions = qs);
      }
    } on AppFailure catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte ta bort fråga: ${e.message}');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Fel vid borttagning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: BasePage(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_allowed) {
      return _GlassScaffold(
        appBar: _buildAppBar(),
        child: Center(
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: BorderRadius.circular(24),
            opacity: 0.18,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48),
                SizedBox(height: 16),
                Text(
                  'Endast certifierade lärare har åtkomst till kurseditorn.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final uploadJobs = ref.watch(studioUploadQueueProvider);
    final lessonUploadJobs = _selectedLessonId == null
        ? const <UploadJob>[]
        : (uploadJobs.where((job) => job.lessonId == _selectedLessonId).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

    final editorContent = SingleChildScrollView(
      padding: p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: 'Välj kurs',
            child: DropdownButtonFormField<String>(
              key: ValueKey('course-${_selectedCourseId ?? 'none'}'),
              initialValue: _selectedCourseId,
              items: _courses
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c['id'] as String,
                      child: Text('${c['title']}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() => _selectedCourseId = value);
                await _loadCourseMeta();
                await _loadModules(preserveSelection: false);
                if (!mounted) return;
                setState(() {
                  _quiz = null;
                  _questions = <Map<String, dynamic>>[];
                });
              },
              decoration: const InputDecoration(hintText: 'Välj kurs'),
            ),
          ),
          if (_selectedCourseId != null) ...[
            gap12,
            _SectionCard(
              title: 'Kursinformation',
              child: _courseMetaLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _courseTitleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Titel',
                          ),
                        ),
                        gap12,
                        TextField(
                          controller: _courseSlugCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Slug',
                          ),
                        ),
                        gap12,
                        TextField(
                          controller: _courseDescCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Beskrivning',
                          ),
                        ),
                        gap12,
                        TextField(
                          controller: _coursePriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Pris (SEK)',
                            helperText: 'Ange 0 för gratis kurs',
                          ),
                        ),
                        gap8,
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _courseIsFreeIntro,
                          onChanged: (value) => setState(() {
                            _courseIsFreeIntro = value;
                          }),
                          title: const Text('Kursen har gratis introduktion'),
                          subtitle: const Text(
                            'Aktivera för att låsa upp introduktionsinnehåll utan köp.',
                          ),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _courseIsPublished,
                          onChanged: (value) => setState(() {
                            _courseIsPublished = value;
                          }),
                          title: const Text('Publicerad'),
                          subtitle: const Text(
                            'När en kurs är publicerad syns den för elever.',
                          ),
                        ),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed:
                                  _savingCourseMeta ? null : _saveCourseMeta,
                              icon: _savingCourseMeta
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: const Text('Spara kurs'),
                            ),
                            const SizedBox(width: 12),
                            if (_courseIsPublished &&
                                (_coursePriceCtrl.text.isEmpty ||
                                    _coursePriceCtrl.text == '0'))
                              const Text(
                                '⚠️ Sätt ett pris innan publicering',
                                style: TextStyle(color: Colors.orange),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
          gap12,
          _SectionCard(
            title: 'Skapa ny kurs',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCourseTitle,
                        decoration: const InputDecoration(labelText: 'Titel'),
                      ),
                    ),
                    gap12,
                    Expanded(
                      child: TextField(
                        controller: _newCourseDesc,
                        decoration: const InputDecoration(
                          labelText: 'Beskrivning (valfri)',
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                gap12,
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _createCourse,
                    child: const Text('Skapa kurs'),
                  ),
                ),
              ],
            ),
          ),
          gap16,
          _SectionCard(
            title: 'Moduler & lektioner',
            actions: [
              if (_selectedCourseId != null)
                OutlinedButton.icon(
                  onPressed: _moduleActionBusy ? null : _promptCreateModule,
                  icon: const Icon(Icons.add),
                  label: const Text('Ny modul'),
                ),
            ],
            child: _selectedCourseId == null
                ? const Text(
                    'Välj en kurs för att hantera moduler och lektioner.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_modulesLoading)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_modules.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Inga moduler ännu.'),
                            gap8,
                            OutlinedButton.icon(
                              onPressed: _moduleActionBusy
                                  ? null
                                  : _promptCreateModule,
                              icon: const Icon(Icons.add),
                              label: const Text('Skapa första modul'),
                            ),
                          ],
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey(
                                  'module-${_selectedModuleId ?? 'none'}',
                                ),
                                initialValue: _selectedModuleId,
                                items: _modules
                                    .map(
                                      (module) => DropdownMenuItem<String>(
                                        value: module['id'] as String,
                                        child: Text(
                                          (module['title'] as String?) ??
                                              'Modul',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedModuleId = value);
                                  _loadLessons(preserveSelection: false);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Välj modul',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Ta bort modul',
                              onPressed: (_selectedModuleId == null ||
                                      _moduleActionBusy)
                                  ? null
                                  : () => _deleteModule(_selectedModuleId!),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        gap12,
                        if (_lessonsLoading)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'lesson-${_selectedLessonId ?? 'none'}',
                                  ),
                                  initialValue: _selectedLessonId,
                                  items: _lessons
                                      .map(
                                        (lesson) => DropdownMenuItem<String>(
                                          value: lesson['id'] as String,
                                          child: Text(
                                            (lesson['title'] as String?) ??
                                                'Lektion',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLessonId = value;
                                      final match = _lessonById(value);
                                      _lessonIntro = match?['is_intro'] == true;
                                    });
                                    _applySelectedLesson();
                                    _loadLessonMedia();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Välj lektion',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Ta bort lektion',
                                onPressed: (_selectedLessonId == null ||
                                        _lessonActionBusy)
                                    ? null
                                    : () => _deleteLesson(_selectedLessonId!),
                                icon: const Icon(Icons.delete_outline),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: (_selectedModuleId == null ||
                                        _lessonActionBusy)
                                    ? null
                                    : _promptCreateLesson,
                                icon: const Icon(Icons.add),
                                label: const Text('Ny lektion'),
                              ),
                            ],
                          ),
                          if (_selectedLessonId != null) ...[
                            gap12,
                            _buildLessonContentEditor(context),
                          ],
                          if (_lessons.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Modulen har inga lektioner ännu.'),
                            )
                          else ...[
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              value: _lessonIntro,
                              onChanged: (_selectedLessonId == null ||
                                      _updatingLessonIntro)
                                  ? null
                                  : (value) => _setLessonIntro(value),
                              title: const Text(
                                'Lektionen är introduktion (gratis)',
                              ),
                              subtitle: const Text(
                                'Intro laddas upp till public-media, betalt till course-media.',
                              ),
                            ),
                            gap12,
                            Builder(
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Använd ikonerna i verktygsfältet ovan för att ladda upp bild, video eller ljud. Dokument (PDF) kan laddas upp via knappen med dokumentikonen.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                );
                              },
                            ),
                            if (lessonUploadJobs.isNotEmpty) ...[
                              gap8,
                              Column(
                                children: [
                                  for (final job in lessonUploadJobs)
                                    _buildUploadJobCard(job),
                                ],
                              ),
                            ],
                            if (_mediaStatus != null) ...[
                              gap8,
                              Text(_mediaStatus!),
                            ],
                            if (_downloadStatus != null) ...[
                              gap4,
                              Text(
                                _downloadStatus!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                            ],
                            const Divider(height: 24),
                            if (_mediaLoading)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_lessonMedia.isEmpty)
                              const Text('Inget media uppladdat ännu.')
                            else
                              SizedBox(
                                height: 260,
                                child: ReorderableListView.builder(
                                  itemCount: _lessonMedia.length,
                                  onReorder: _handleMediaReorder,
                                  buildDefaultDragHandles: false,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  itemBuilder: (context, index) {
                                    final media = _lessonMedia[index];
                                    final bucket =
                                        (media['storage_bucket'] as String?) ??
                                            '';
                                    final intro = media['is_intro'] == true ||
                                        bucket == 'public-media';
                                    final kind =
                                        (media['kind'] as String?) ?? 'other';
                                    final position =
                                        media['position'] as int? ?? index + 1;
                                    final downloadUrl = _resolveMediaUrl(
                                      media['download_url'] as String?,
                                    );
                                    final fileName = _fileNameFromMedia(
                                      media,
                                    );

                                    Widget leading;
                                    if (kind == 'image' &&
                                        downloadUrl != null) {
                                      leading = ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        child: Image.network(
                                          downloadUrl,
                                          fit: BoxFit.cover,
                                          width: 64,
                                          height: 64,
                                          errorBuilder: (_, __, ___) => Icon(
                                            _iconForMedia(kind),
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    } else {
                                      leading = Icon(
                                        _iconForMedia(kind),
                                        size: 32,
                                      );
                                    }

                                    return Padding(
                                      key: ValueKey(media['id']),
                                      padding: const EdgeInsets.only(
                                        bottom: 8,
                                      ),
                                      child: Card(
                                        child: ListTile(
                                          onTap: () => _previewMedia(media),
                                          leading: SizedBox(
                                            width: 64,
                                            child: Center(child: leading),
                                          ),
                                          title: Text(
                                            fileName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Chip(
                                                label: Text(
                                                  intro
                                                      ? 'Intro (gratis)'
                                                      : 'Premium',
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              Text(
                                                bucket.isEmpty
                                                    ? 'Intern lagring'
                                                    : bucket,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                              Text(
                                                'Position $position • ${kind.toUpperCase()}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Ladda ner',
                                                icon: const Icon(
                                                  Icons.download_outlined,
                                                ),
                                                onPressed: () =>
                                                    _downloadMedia(media),
                                              ),
                                              IconButton(
                                                tooltip: 'Ta bort',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () => _deleteMedia(
                                                  media['id'] as String,
                                                ),
                                              ),
                                              ReorderableDragStartListener(
                                                index: index,
                                                child: const Icon(
                                                  Icons.drag_handle_rounded,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ],
                      ],
                    ],
                  ),
          ),
          gap16,
          _SectionCard(
            title: 'Quiz',
            actions: [
              OutlinedButton.icon(
                onPressed: _selectedCourseId == null ? null : _ensureQuiz,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Skapa/Hämta quiz'),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_quiz == null) const Text('Inget quiz laddat.'),
                if (_quiz != null) ...[
                  Text(
                    'Quiz: ${_quiz!['title']} (gräns: ${_quiz!['pass_score']}%)',
                  ),
                  gap12,
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final kind in <String>[
                        'single',
                        'multi',
                        'boolean',
                      ])
                        ChoiceChip(
                          label: Text(kind),
                          selected: _qKind == kind,
                          onSelected: (selected) => setState(
                            () => _qKind = selected ? kind : _qKind,
                          ),
                        ),
                    ],
                  ),
                  gap8,
                  TextField(
                    controller: _qPrompt,
                    decoration: const InputDecoration(labelText: 'Frågetext'),
                  ),
                  if (_qKind != 'boolean') ...[
                    gap8,
                    TextField(
                      controller: _qOptions,
                      decoration: const InputDecoration(
                        labelText: 'Alternativ (komma-separerade)',
                      ),
                    ),
                    gap8,
                    TextField(
                      controller: _qCorrect,
                      decoration: const InputDecoration(
                        labelText: 'Rätt svar (index eller index, index)',
                      ),
                    ),
                  ] else ...[
                    gap8,
                    TextField(
                      controller: _qCorrect,
                      decoration: const InputDecoration(
                        labelText: 'Rätt svar (true/false)',
                      ),
                    ),
                  ],
                  gap10,
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _addQuestion,
                      child: const Text('Lägg till fråga'),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text('Frågor'),
                  gap6,
                  if (_questions.isEmpty)
                    const Text('Inga frågor ännu.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => gap6,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        return ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: Text('${q['prompt']}'),
                          subtitle: Text(
                            'Typ: ${q['kind']} • Pos: ${q['position']}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteQuestion(q['id'] as String),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return _GlassScaffold(
      appBar: _buildAppBar(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const previewTotalWidth =
              _previewCanvasWidth + (_previewOuterPadding * 2);
          const requiredWidth =
              previewTotalWidth + _previewEditorGutter + _editorMinWidth;
          final canShowSideBySide = constraints.maxWidth >= requiredWidth;

          if (canShowSideBySide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(_previewOuterPadding),
                  child: _buildPreviewPane(context),
                ),
                const SizedBox(width: _previewEditorGutter),
                Expanded(child: editorContent),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _previewOuterPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  child: _buildPreviewPane(context),
                ),
                const SizedBox(height: 24),
                editorContent,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlassScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  const _GlassScaffold({required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1920),
            child: BasePage(child: child),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const _SectionCard({required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: p16,
      borderRadius: BorderRadius.circular(20),
      opacity: 0.18,
      borderColor: Colors.white.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
          gap12,
          child,
        ],
      ),
    );
  }
}
