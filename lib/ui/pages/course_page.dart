import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/course_service.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:andlig_app/domain/services/payments/payments_service.dart';
import 'package:flutter/foundation.dart';

class CoursePage extends StatefulWidget {
  final String slug;
  const CoursePage({super.key, required this.slug});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final _svc = CourseService();
  Map<String, dynamic>? _course;
  bool _loading = true;
  bool _enrolling = false;
  bool _ordering = false;
  String? _error;
  List<Map<String, dynamic>> _modules = [];
  final Map<String, List<Map<String, dynamic>>> _lessonsByModule = {};
  int _freeCount = 0;
  bool _hasEnrollment = false;
  Map<String, dynamic>? _latestOrder;
  int _freeLimit = 5;
  VoidCallback? _cancelOrderWatch;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await _svc.getCourseBySlug(widget.slug);
      if (c == null) {
        setState(() {
          _error = 'Kursen kunde inte hittas.';
          _loading = false;
        });
        return;
      }
      final courseId = c['id'] as String;
      final mods = await _svc.listModules(courseId);
      final lessonsMap = <String, List<Map<String, dynamic>>>{};
      for (final m in mods) {
        // RLS på servern avgör vilka lektioner som exponeras (intro eller alla)
        lessonsMap[m['id'] as String] =
            await _svc.listLessonsForModule(m['id'] as String);
      }
      final freeCnt = await _svc.freeConsumedCount();
      final enrolled = await _svc.isEnrolled(courseId);
      final order = await _svc.latestOrderForCourse(courseId);
      final cfg = await _svc.getAppConfig();
      setState(() {
        _course = c;
        _modules = mods;
        _lessonsByModule
          ..clear()
          ..addAll(lessonsMap);
        _freeCount = freeCnt;
        _hasEnrollment = enrolled;
        _latestOrder = order;
        _freeLimit = (cfg?['free_course_limit'] as int?) ?? 5;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Något gick fel: $e';
        _loading = false;
      });
    }
  }

  Future<void> _enrollFree() async {
    if (_freeCount >= _freeLimit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Du har förbrukat alla $_freeLimit gratis-intros.')),
      );
      return;
    }
    final id = _course?['id'] as String?;
    if (id == null) return;
    setState(() => _enrolling = true);
    try {
      await _svc.enrollFreeIntro(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Du är nu anmäld till introduktionen.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte anmäla: $e')),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Future<void> _buyCourse() async {
    final id = _course?['id'] as String?;
    final price = (_course?['price_cents'] as int?) ?? 0;
    if (id == null || price <= 0) return;
    setState(() => _ordering = true);
    try {
      final pay = PaymentsService();
      final order = await pay.startCourseOrder(courseId: id, amountCents: price);
      if (!mounted) return;
      // Watch order updates in realtime
      try {
        _cancelOrderWatch?.call();
        _cancelOrderWatch = await pay.watchOrderStatus(
          orderId: order['id'] as String,
          onUpdate: (row) {
            if (!mounted) return;
            setState(() => _latestOrder = row);
          },
        );
      } catch (_) {}
      final url = await pay.createCheckoutSession(
        orderId: order['id'] as String,
        amountCents: price,
        successUrl: 'https://andlig.app/payment/success?order_id=${order['id']}',
        cancelUrl: 'https://andlig.app/payment/cancel?order_id=${order['id']}',
        customerEmail: null,
      );
      if (url != null) {
        await launchUrlString(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kunde inte initiera betalning.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skapa order: $e')),
      );
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  void dispose() {
    _cancelOrderWatch?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Kurs',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return AppScaffold(
        title: 'Kurs',
        body: Center(child: Text(_error!)),
      );
    }
    final c = _course!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final priceCents = (c['price_cents'] as int?) ?? 0;
    final enrolledText = _hasEnrollment ? '• Du är anmäld' : '';

    return AppScaffold(
      title: c['title'] as String? ?? 'Kurs',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['title'] ?? 'Kurs',
                    style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  if (c['description'] != null)
                    Text(c['description'] as String,
                        style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _enrolling ? null : _enrollFree,
                        child: _enrolling
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Starta gratis intro'),
                      ),
                      const SizedBox(width: 10),
                      if (priceCents > 0)
                        OutlinedButton(
                          onPressed: _ordering ? null : _buyCourse,
                          child: _ordering
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Köp hela kursen (${priceCents / 100} kr)'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Använda gratis-intros: $_freeCount/$_freeLimit $enrolledText',
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  if (_latestOrder != null)
                    Row(
                      children: [
                        Text('Betalstatus: ${_latestOrder!['status']}', style: t.bodySmall),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            final order = await _svc.latestOrderForCourse(c['id'] as String);
                            if (!mounted) return;
                            setState(() => _latestOrder = order);
                          },
                          child: const Text('Uppdatera status'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._modules.map((m) {
            final lessons = _lessonsByModule[m['id']] ?? const [];
            if (lessons.isEmpty) return const SizedBox.shrink();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['title'] as String, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...lessons.map((l) => ListTile(
                          leading: const Icon(Icons.play_circle_outline_rounded),
                          title: Text(l['title'] as String? ?? 'Lektion'),
                          subtitle: (l['is_intro'] == true)
                              ? const Text('Förhandsvisning')
                              : null,
                          onTap: () {
                            final id = l['id'] as String?;
                            if (id != null) {
                              context.push('/lesson/$id');
                            }
                          },
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
