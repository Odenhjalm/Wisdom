// lib/ui/pages/landing_page.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visdom/core/env/env_state.dart';
import 'package:visdom/data/supabase/supabase_client.dart';
import 'package:visdom/core/supabase_ext.dart';
import 'package:visdom/features/community/data/community_repository.dart';
import 'package:visdom/shared/utils/snack.dart';
import 'package:visdom/shared/widgets/glass_card.dart';
import 'package:visdom/shared/widgets/hero_badge.dart';
import 'package:visdom/shared/widgets/app_scaffold.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with WidgetsBindingObserver {
  final _scroll = ScrollController();
  double _offset = 0.0;
  late final ImageProvider _bg;

  // 🔒 säkerställ att vi bara precachar en gång, och först när inherited widgets finns
  bool _didPrecache = false;

  // Data for sections
  bool _loading = true;
  List<Map<String, dynamic>> _popularCourses = const [];
  List<Map<String, dynamic>> _teachers = const [];
  List<Map<String, dynamic>> _services = const [];
  List<Map<String, dynamic>> _introCourses = const [];
  bool _envSnackShown = false;

  @override
  void initState() {
    super.initState();
    _bg = const AssetImage('assets/images/bakgrund.png');

    _scroll.addListener(() {
      setState(() => _offset = _scroll.offset.clamp(0.0, 400.0));
    });
    // kick off data load
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ precache här (inte i initState) för att undvika “dependOnInheritedWidget”–felet
    if (!_didPrecache) {
      precacheImage(_bg, context);
      _didPrecache = true;
    }
    final info = ref.read(envInfoProvider);
    if (!_envSnackShown && info.hasIssues) {
      _envSnackShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final missing = info.missingKeys.isEmpty
            ? 'Supabase-konfiguration saknas.'
            : 'Supabase saknas: ${info.missingKeys.join(', ')}.';
        showSnack(
          context,
          '$missing Lägg till nycklar i .env eller via --dart-define.',
        );
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (!Supa.isReady) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    try {
      final sb = Supa.client;
      final popular = await sb.app
          .from('courses')
          .select('id,slug,title,description,is_free_intro,cover_url')
          .order('is_free_intro', ascending: false)
          .order('created_at', ascending: false)
          .limit(6);
      final intros = await sb.app
          .from('courses')
          .select('id,slug,title,is_free_intro')
          .eq('is_free_intro', true)
          .order('created_at', ascending: false)
          .limit(5);
      final svcRows = await sb.app
          .from('services')
          .select('id,title,description,price_cents,certified_area,active')
          .eq('active', true)
          .order('created_at', ascending: false)
          .limit(6);
      final teachers = await CommunityRepository().listTeachers();
      if (!mounted) return;
      setState(() {
        _popularCourses = (popular as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _introCourses = (intros as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _services = (svcRows as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _teachers = teachers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openIntroModal() {
    if (!Supa.isReady) {
      showSnack(
        context,
        'Supabase saknas. Lägg till SUPABASE_URL och SUPABASE_ANON_KEY för att visa kurser.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final items = _introCourses;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .78),
                border:
                    const Border(top: BorderSide(color: Colors.transparent)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.black87),
                          const SizedBox(width: 8),
                          const Text('Gratis introduktionskurser',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Inga introduktionskurser ännu.'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final c = items[i];
                            final title =
                                (c['title'] as String?) ?? 'Introduktion';
                            return ListTile(
                              leading: const Icon(Icons.play_circle_outline),
                              title: Text(title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: const Chip(label: Text('Gratis intro')),
                              onTap: () {
                                Navigator.of(context).pop();
                                final slug = (c['slug'] as String?) ?? '';
                                if (slug.isNotEmpty) {
                                  context.push('/course/$slug');
                                } else {
                                  context.push('/course/intro');
                                }
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final envInfo = ref.watch(envInfoProvider);
    final hasEnvIssues = envInfo.hasIssues;
    final size = MediaQuery.of(context).size;
    // Subtil parallax – ytterligare förfinad: lite svagare och hårdare cap
    final f = size.width >= 900 ? 0.20 : 0.14;
    final y = -(_offset.clamp(0.0, 120.0)) * f;
    // Premium-gradient – något djupare, tydligare separation
    final topGrad = size.width >= 900 ? 0.40 : 0.44;
    final bottomGrad = size.width >= 900 ? 0.62 : 0.66;
    // Skala upp bilden aningen för att garanterat klippa bort ev. vit kant i asset
    final imgScale =
        size.width >= 1200 ? 1.06 : (size.width >= 900 ? 1.08 : 1.12);
    // Lägg på diskret sidovignette för att dölja ev. ljusa kanter på extrema aspect ratios
    final sideVignette = size.width >= 900 ? 0.08 : 0.10;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // “logo” – glass badge (blur + translucent)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: .18),
                          Colors.white.withValues(alpha: .08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .28)),
                    ),
                    child: const Icon(
                      Icons.self_improvement_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Visdom',
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: .25,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .50),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: hasEnvIssues ? null : () => context.push('/profile'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Logga in'),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: hasEnvIssues ? null : () => context.push('/profile'),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Skapa konto'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: hasEnvIssues ? null : _openIntroModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Text('Gratis kurser'),
              ),
            ],
          ),
        ),
      ),
      body: FullBleedBackground(
        image: _bg,
        alignment: Alignment.topCenter,
        topOpacity: topGrad,
        bottomOpacity: bottomGrad,
        yOffset: y,
        scale: imgScale,
        sideVignette: sideVignette,
        child: Stack(
          children: [
            const _ParticlesLayer(),
            SafeArea(
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.zero,
                children: [
                  if (hasEnvIssues)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Card(
                        color: const Color(0xFFDC2626).withValues(alpha: .9),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            envInfo.missingKeys.isEmpty
                                ? 'Supabase-konfiguration saknas. Lägg till SUPABASE_URL och SUPABASE_ANON_KEY i .env eller via --dart-define för att aktivera inloggning.'
                                : 'Saknade nycklar: ${envInfo.missingKeys.join(', ')}. Lägg till dem i .env eller via --dart-define för att aktivera inloggning.',
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // HERO
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 44),
                        child: Column(
                          children: [
                            const SizedBox(height: 28),
                            const HeroBadge(
                              text:
                                  'Sveriges ledande plattform för andlig utveckling',
                            ),
                            const SizedBox(height: 22),
                            const _GradientHeadline(
                              leading: 'Upptäck din andliga',
                              gradientWord: 'resa',
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Lär dig av erfarna andliga lärare genom personliga kurser, '
                              'privata sessioner och djupa lärdomar som förändrar ditt liv.',
                              textAlign: TextAlign.center,
                              style: t.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: .92),
                                height: 1.36,
                                letterSpacing: .2,
                              ),
                            ),
                            const SizedBox(height: 26),
                            // CTA buttons – hook intro modal
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      hasEnvIssues ? null : _openIntroModal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34D399),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Börja gratis idag'),
                                ),
                                OutlinedButton(
                                  onPressed:
                                      hasEnvIssues ? null : _openIntroModal,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.transparent),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 14),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Utforska utan konto'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const _SocialProofRow(
                              items: [
                                ('Över 1000+', 'nöjda elever'),
                                ('Certifierade', 'lärare'),
                                ('30 dagars', 'garanti'),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SEKTION – Populära kurser
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Populära kurser',
                                style: t.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Se vad andra gillar just nu.',
                                style: t.bodyLarge
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              GlassCard(
                                child: _loading
                                    ? const SizedBox(
                                        height: 180,
                                        child: Center(
                                            child: CircularProgressIndicator()))
                                    : _popularCourses.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text('Inga kurser ännu.'),
                                          )
                                        : LayoutBuilder(builder: (context, c) {
                                            final w = c.maxWidth;
                                            final cross = w >= 900
                                                ? 3
                                                : (w >= 600 ? 2 : 1);
                                            return GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: _popularCourses.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: cross,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                                childAspectRatio: 1.35,
                                              ),
                                              itemBuilder: (_, i) {
                                                final c = _popularCourses[i];
                                                return _CourseTileGlass(
                                                    course: c);
                                              },
                                            );
                                          }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SEKTION – Lärare (carousel)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lärare',
                                style: t.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('Möt certifierade lärare.',
                                style: t.bodyLarge
                                    ?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 10),
                            GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                height: 110,
                                child: _loading
                                    ? ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 6,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (_, __) =>
                                            const _TeacherPillSkeleton(),
                                      )
                                    : _teachers.isEmpty
                                        ? const Center(
                                            child: Text('Inga lärare ännu.'))
                                        : ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _teachers.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 8),
                                            itemBuilder: (_, i) =>
                                                _TeacherPillData(
                                                    map: _teachers[i]),
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SEKTION – Tjänster
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tjänster',
                                style: t.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('Nya sessioner och läsningar.',
                                style: t.bodyLarge
                                    ?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 10),
                            GlassCard(
                              child: _loading
                                  ? const SizedBox(
                                      height: 160,
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : _services.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text('Inga tjänster ännu.'),
                                        )
                                      : LayoutBuilder(builder: (context, c) {
                                          final w = c.maxWidth;
                                          final cross =
                                              w >= 900 ? 3 : (w >= 600 ? 2 : 1);
                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: _services.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: cross,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                              childAspectRatio: 1.4,
                                            ),
                                            itemBuilder: (_, i) =>
                                                _ServiceTileGlass(
                                                    service: _services[i]),
                                          );
                                        }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CTA-banderoll (bottom)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 44),
                        child: Card(
                          color: Colors.white.withValues(alpha: .18),
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: .22)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.workspace_premium_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Börja gratis idag – eller utforska utan konto.',
                                    style: t.bodyLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _openIntroModal,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Börja gratis'),
                                    ),
                                    OutlinedButton(
                                      onPressed: _openIntroModal,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.white),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Utforska utan konto'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Små UI-komponenter i denna fil ---------- */

class _GradientHeadline extends StatelessWidget {
  final String leading;
  final String gradientWord;
  const _GradientHeadline({
    required this.leading,
    required this.gradientWord,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.04,
          letterSpacing: -.5,
        );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(leading, textAlign: TextAlign.center, style: base),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
          ).createShader(const Rect.fromLTWH(0, 0, 400, 80)),
          child: Text(gradientWord,
              textAlign: TextAlign.center,
              style: base?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Liten, billig partikellayer – subtilt glitter.
class _ParticlesLayer extends StatefulWidget {
  const _ParticlesLayer();

  @override
  State<_ParticlesLayer> createState() => _ParticlesLayerState();
}

class _ParticlesLayerState extends State<_ParticlesLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _rnd = Random();
  final _points = <Offset>[];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          // init points once per size
          final size = MediaQuery.of(context).size;
          if (_points.isEmpty) {
            for (var i = 0; i < 60; i++) {
              _points.add(Offset(
                _rnd.nextDouble() * size.width,
                _rnd.nextDouble() * size.height * .7,
              ));
            }
          }
          return CustomPaint(
            painter: _ParticlesPainter(_points, _c.value),
          );
        },
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<Offset> points;
  final double t;
  _ParticlesPainter(this.points, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: .10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var i = 0; i < points.length; i++) {
      final o = points[i];
      final dy = sin((t * 2 * pi) + i) * 0.6; // flyter sakta
      canvas.drawCircle(Offset(o.dx, o.dy + dy), 1.5, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Social proof-raden
class _SocialProofRow extends StatelessWidget {
  final List<(String, String)> items;
  const _SocialProofRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final styleA = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800);
    final styleB = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600);

    return Wrap(
      spacing: 22,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items
          .map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
                Text(e.$1, style: styleA),
                const SizedBox(width: 6),
                Text(e.$2, style: styleB),
              ]))
          .toList(),
    );
  }
}

// ---- Section item widgets (glass style) ----

class _CourseTileGlass extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseTileGlass({required this.course});

  @override
  Widget build(BuildContext context) {
    final title = (course['title'] as String?) ?? 'Kurs';
    final desc = (course['description'] as String?) ?? '';
    final cover = (course['cover_url'] as String?) ?? '';
    final slug = (course['slug'] as String?) ?? '';
    final isIntro = course['is_free_intro'] == true;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .80),
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: cover.isNotEmpty
                  ? Image.network(cover, fit: BoxFit.cover)
                  : Container(color: Colors.white.withValues(alpha: .4)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isIntro) const SizedBox(width: 8),
                      if (isIntro)
                        const Chip(
                            label: Text('Gratis intro'),
                            visualDensity: VisualDensity.compact),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (slug.isNotEmpty) {
                          context.push('/course/$slug');
                        } else {
                          context.push('/course/intro');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Öppna'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherPillSkeleton extends StatelessWidget {
  const _TeacherPillSkeleton();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 220,
        height: 90,
        color: Colors.white.withValues(alpha: .3),
      ),
    );
  }
}

class _TeacherPillData extends StatelessWidget {
  final Map<String, dynamic> map;
  const _TeacherPillData({required this.map});
  @override
  Widget build(BuildContext context) {
    final prof = (map['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final name = (prof['display_name'] as String?) ?? 'Lärare';
    final avatar = (prof['photo_url'] as String?) ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .65),
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty ? const Icon(Icons.person_outline) : null,
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTileGlass extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServiceTileGlass({required this.service});
  @override
  Widget build(BuildContext context) {
    final title = (service['title'] as String?) ?? 'Tjänst';
    final desc = (service['description'] as String?) ?? '';
    final area = (service['certified_area'] as String?) ?? '';
    final cents = (service['price_cents'] as num?)?.toInt();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .80),
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const Spacer(),
            Row(
              children: [
                if (area.isNotEmpty)
                  Chip(label: Text(area), visualDensity: VisualDensity.compact),
                const Spacer(),
                if (cents != null)
                  Text('${(cents / 100).toStringAsFixed(0)} kr',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
