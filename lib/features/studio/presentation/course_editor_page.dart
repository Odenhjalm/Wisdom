import 'dart:math';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';
import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/glass_card.dart';
import 'package:wisdom/features/studio/data/teacher_repository.dart';
import 'package:wisdom/features/studio/data/studio_repository.dart';
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/payments/presentation/paywall_prompt.dart';
import 'package:wisdom/domain/services/auth_service.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/widgets/base_page.dart';

class CourseEditorScreen extends ConsumerStatefulWidget {
  final String? courseId;
  final TeacherRepository? teacherRepository;
  final StudioRepository? studioRepository;
  final CoursesRepository? coursesRepository;
  final AuthService? authService;
  final SupabaseClient? supabaseClient;

  const CourseEditorScreen({
    super.key,
    this.courseId,
    this.teacherRepository,
    this.studioRepository,
    this.coursesRepository,
    this.authService,
    this.supabaseClient,
  });

  @override
  ConsumerState<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends ConsumerState<CourseEditorScreen> {
  bool _checking = true;
  bool _allowed = false;
  late final TeacherRepository _repo;
  late final StudioRepository _studioRepo;
  late final CoursesRepository _courseRepo;
  AuthService? _authService;
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
  bool _uploadingMedia = false;
  String? _mediaStatus;
  bool _moduleActionBusy = false;
  bool _lessonActionBusy = false;

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
  bool _previewLoading = false;
  String? _previewError;
  CourseDetailData? _previewDetail;

  Map<String, dynamic>? _quiz;
  final TextEditingController _qPrompt = TextEditingController();
  final TextEditingController _qOptions = TextEditingController();
  final TextEditingController _qCorrect = TextEditingController();
  String _qKind = 'single';
  List<Map<String, dynamic>> _questions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _repo = widget.teacherRepository ?? TeacherRepository();
    _studioRepo = widget.studioRepository ?? StudioRepository();
    _courseRepo = widget.coursesRepository ?? CoursesRepository();
    _authService = widget.authService;
    _bootstrap();
  }

  @override
  void dispose() {
    _qPrompt.dispose();
    _qOptions.dispose();
    _qCorrect.dispose();
    _newCourseTitle.dispose();
    _newCourseDesc.dispose();
    _courseTitleCtrl.dispose();
    _courseSlugCtrl.dispose();
    _courseDescCtrl.dispose();
    _coursePriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final sb = widget.supabaseClient ?? ref.read(supabaseMaybeProvider);
    if (sb == null || sb.auth.currentUser == null) {
      if (!mounted || !context.mounted) return;
      context.go('/login');
      return;
    }
    try {
      final authSvc = _authService ?? AuthService(client: sb);
      final allowed = await authSvc.isTeacher();
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
    await _loadPreviewDetail();
  }

  Future<void> _loadPreviewDetail() async {
    final slug = _courseSlugCtrl.text.trim();
    if (slug.isEmpty) {
      setState(() {
        _previewDetail = null;
        _previewError = 'Ingen slug angiven';
      });
      return;
    }
    setState(() {
      _previewLoading = true;
      _previewError = null;
    });
    try {
      final detail = await _courseRepo.fetchCourseDetailBySlug(slug);
      if (!mounted) return;
      setState(() {
        _previewDetail = detail;
        _previewError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previewDetail = null;
        _previewError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _previewLoading = false);
    }
  }

  Widget _buildPreviewSection(BuildContext context) {
    if (_previewLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_previewError != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Kan inte visa förhandsgranskning: $_previewError'),
      );
    }
    final detail = _previewDetail;
    if (detail == null) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Ingen kursdata att visa.'),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lärare'),
              Tab(text: 'Elev utan köp'),
              Tab(text: 'Elev med köp'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: TabBarView(
              children: [
                _buildTeacherPreview(context, detail),
                _buildLockedPreview(context, detail),
                _buildFullAccessPreview(context, detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherPreview(BuildContext context, CourseDetailData detail) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Lärarvy: allt material visas.'),
        const SizedBox(height: 12),
        ..._buildLessonTiles(context, detail, hasAccess: true),
      ],
    );
  }

  Widget _buildLockedPreview(BuildContext context, CourseDetailData detail) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Elev utan köp ser paywall för betalt material.'),
        const SizedBox(height: 12),
        PaywallPrompt(courseId: detail.course.id),
        const SizedBox(height: 12),
        ..._buildLessonTiles(context, detail, hasAccess: false),
      ],
    );
  }

  Widget _buildFullAccessPreview(
      BuildContext context, CourseDetailData detail) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Elev med köp: allt material är upplåst.'),
        const SizedBox(height: 12),
        ..._buildLessonTiles(context, detail, hasAccess: true),
      ],
    );
  }

  List<Widget> _buildLessonTiles(
    BuildContext context,
    CourseDetailData detail, {
    required bool hasAccess,
  }) {
    final theme = Theme.of(context);
    final result = <Widget>[];
    for (final module in detail.modules) {
      final lessons = detail.lessonsByModule[module.id] ?? const [];
      result.add(Text(
        module.title,
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ));
      result.add(const SizedBox(height: 6));
      for (final lesson in lessons) {
        final locked = !hasAccess && !lesson.isIntro;
        result.add(ListTile(
          dense: true,
          leading: Icon(
            locked ? Icons.lock_outline_rounded : Icons.play_circle_outline,
          ),
          title: Text(lesson.title),
          subtitle: Text(
            lesson.isIntro ? 'Intro (gratis)' : 'Betalt innehåll',
          ),
          trailing: Chip(
            label: Text(lesson.isIntro ? 'Intro' : 'Betalt'),
            visualDensity: VisualDensity.compact,
          ),
        ));
      }
      result.add(const SizedBox(height: 12));
    }
    if (result.isEmpty) {
      result.add(const Text('Inga lektioner skapade ännu.'));
    }
    return result;
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
      await _loadPreviewDetail();
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
      await _loadPreviewDetail();
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
      await _loadPreviewDetail();
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
      await _loadPreviewDetail();
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
      await _studioRepo.updateLessonIntro(
        lessonId: lessonId,
        isIntro: value,
      );
      if (mounted) {
        setState(() {
          _lessons = _lessons
              .map((lesson) => lesson['id'] == lessonId
                  ? {
                      ...lesson,
                      'is_intro': value,
                    }
                  : lesson)
              .toList();
        });
      }
      await _loadPreviewDetail();
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
    if (_selectedCourseId == null ||
        _selectedLessonId == null ||
        _uploadingMedia) {
      return;
    }
    if (mounted) {
      setState(() {
        _uploadingMedia = true;
        _mediaStatus = null;
      });
    }
    try {
      final typeGroup = fs.XTypeGroup(label: 'media', extensions: extensions);
      final file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        if (mounted) {
          setState(() {
            _uploadingMedia = false;
            _mediaStatus = 'Ingen fil vald.';
          });
        }
        return;
      }
      final bytes = await file.readAsBytes();
      final contentType = _guessContentType(file.name);
      await _studioRepo.uploadLessonMedia(
        courseId: _selectedCourseId!,
        lessonId: _selectedLessonId!,
        data: bytes,
        filename: file.name,
        contentType: contentType,
        isIntro: _lessonIntro,
      );
      await _loadLessonMedia();
      await _loadPreviewDetail();
      if (mounted) {
        setState(() {
          _uploadingMedia = false;
          _mediaStatus = 'Uppladdning klar.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadingMedia = false;
          _mediaStatus = 'Fel vid uppladdning: $e';
        });
      }
      if (mounted && context.mounted) {
        showSnack(context, 'Kunde inte ladda upp media: $e');
      }
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
      await _loadPreviewDetail();
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
      await _loadPreviewDetail();
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
            .map((course) =>
                course['id'] == courseId ? {...course, ...map} : course)
            .toList();
      });
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
    final sb = ref.read(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    if (sb == null || user == null) {
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
      _newCourseTitle.clear();
      _newCourseDesc.clear();
      await _loadCourseMeta();
      await _loadModules();
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kurs skapad.');
    } on PostgrestException catch (e) {
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
      final quiz = await _repo.ensureQuiz(cid);
      final qs = await _repo.quizQuestions(quiz['id'] as String);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _questions = qs;
      });
    } on PostgrestException catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Quiz stöds bara för äldre kurser: ${e.message}');
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
      await _repo.upsertQuestion(data);
      _qPrompt.clear();
      _qOptions.clear();
      _qCorrect.clear();
      final qs = await _repo.quizQuestions(quizId);
      if (mounted) setState(() => _questions = qs);
    } on PostgrestException catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Kunde inte spara quizfråga: ${e.message}');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      showSnack(context, 'Fel vid quizfråga: $e');
    }
  }

  Future<void> _deleteQuestion(String id) async {
    try {
      await _repo.deleteQuestion(id);
      if (_quiz != null) {
        final qs = await _repo.quizQuestions(_quiz!['id'] as String);
        if (!mounted) return;
        setState(() => _questions = qs);
      }
    } on PostgrestException catch (e) {
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
        body: BasePage(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (!_allowed) {
      return _GlassScaffold(
        appBar: _buildAppBar(),
        child: const Center(child: Text('Behörighet krävs (läraråtkomst).')),
      );
    }
    return _GlassScaffold(
      appBar: _buildAppBar(),
      child: SingleChildScrollView(
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
                    .map((c) => DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text('${c['title']}'),
                        ))
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
                            decoration:
                                const InputDecoration(labelText: 'Titel'),
                          ),
                          gap12,
                          TextField(
                            controller: _courseSlugCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Slug'),
                          ),
                          gap12,
                          TextField(
                            controller: _courseDescCtrl,
                            maxLines: 3,
                            decoration:
                                const InputDecoration(labelText: 'Beskrivning'),
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
                                            strokeWidth: 2),
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
                              labelText: 'Beskrivning (valfri)'),
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
                                        'module-${_selectedModuleId ?? 'none'}'),
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
                                        'lesson-${_selectedLessonId ?? 'none'}'),
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
                                        final match = _lessons.firstWhere(
                                          (lesson) => lesson['id'] == value,
                                          orElse: () => <String, dynamic>{},
                                        );
                                        _lessonIntro =
                                            match['is_intro'] == true;
                                      });
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
                                    'Lektionen är introduktion (gratis)'),
                                subtitle: const Text(
                                  'Intro laddas upp till public-media, betalt till course-media.',
                                ),
                              ),
                              gap12,
                              Builder(
                                builder: (context) {
                                  final canUpload = _selectedLessonId != null &&
                                      !_uploadingMedia;
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: canUpload
                                            ? () => _pickAndUploadWith(const [
                                                  'png',
                                                  'jpg',
                                                  'jpeg',
                                                  'gif',
                                                  'webp',
                                                  'heic'
                                                ])
                                            : null,
                                        icon: const Icon(Icons.image_outlined),
                                        label: const Text('Ladda upp bild'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: canUpload
                                            ? () => _pickAndUploadWith(const [
                                                  'mp4',
                                                  'mov',
                                                  'm4v',
                                                  'webm',
                                                  'mkv'
                                                ])
                                            : null,
                                        icon: const Icon(
                                            Icons.movie_creation_outlined),
                                        label: const Text('Ladda upp video'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: canUpload
                                            ? () => _pickAndUploadWith(const [
                                                  'mp3',
                                                  'wav',
                                                  'm4a',
                                                  'aac',
                                                  'ogg'
                                                ])
                                            : null,
                                        icon: const Icon(
                                            Icons.audiotrack_outlined),
                                        label: const Text('Ladda upp ljud'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: canUpload
                                            ? () => _pickAndUploadWith(
                                                const ['pdf'])
                                            : null,
                                        icon: const Icon(
                                            Icons.picture_as_pdf_outlined),
                                        label: const Text('Ladda upp PDF'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if (_mediaStatus != null) ...[
                                gap8,
                                Text(_mediaStatus!),
                              ],
                              const Divider(height: 24),
                              if (_mediaLoading)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
                                      final bucket = (media['storage_bucket']
                                              as String?) ??
                                          'course-media';
                                      final intro = bucket == 'public-media';
                                      final kind =
                                          (media['kind'] as String?) ?? 'media';
                                      final path =
                                          media['storage_path'] as String? ??
                                              '';
                                      final position =
                                          (media['position'] ?? '').toString();
                                      return Padding(
                                        key: ValueKey(media['id']),
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Card(
                                          child: ListTile(
                                            leading:
                                                ReorderableDragStartListener(
                                              index: index,
                                              child: const Icon(
                                                  Icons.drag_handle_rounded),
                                            ),
                                            title: Text(kind),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  path,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$bucket • pos $position',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall,
                                                ),
                                                const SizedBox(height: 4),
                                                Chip(
                                                  label: Text(intro
                                                      ? 'Intro (gratis)'
                                                      : 'Betalt'),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              tooltip: 'Ta bort',
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              onPressed: () => _deleteMedia(
                                                  media['id'] as String),
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
                        'Quiz: ${_quiz!['title']} (gräns: ${_quiz!['pass_score']}%)'),
                    gap12,
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final kind in <String>[
                          'single',
                          'multi',
                          'boolean'
                        ])
                          ChoiceChip(
                            label: Text(kind),
                            selected: _qKind == kind,
                            onSelected: (selected) => setState(
                                () => _qKind = selected ? kind : _qKind),
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
                            labelText: 'Alternativ (komma-separerade)'),
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
                            labelText: 'Rätt svar (true/false)'),
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
                                'Typ: ${q['kind']} • Pos: ${q['position']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _deleteQuestion(q['id'] as String),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
            if (_selectedCourseId != null) ...[
              gap16,
              _SectionCard(
                title: 'Förhandsgranska kurs',
                child: _buildPreviewSection(context),
              ),
            ],
          ],
        ),
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
            constraints: const BoxConstraints(maxWidth: 1200),
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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
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
