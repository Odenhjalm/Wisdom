// lib/ui/pages/landing_page.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdom/core/env/env_state.dart';
import 'package:wisdom/features/landing/application/landing_providers.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/glass_card.dart';
import 'package:wisdom/shared/widgets/hero_badge.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';
import 'package:wisdom/widgets/base_page.dart';

const _wisdomBrandGradient = LinearGradient(
  colors: [
    Color(0xFF63C7D6),
    Color(0xFF9B87EB),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _wisdomPrimaryGradient = LinearGradient(
  colors: [
    Color(0xFF63C7D6),
    Color(0xFF8C8EEE),
    Color(0xFFC79DF6),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Size _backgroundImageSize = Size(1536, 1024);

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
  LandingSectionState _popularCourses = const LandingSectionState(items: []);
  LandingSectionState _teachers = const LandingSectionState(items: []);
  LandingSectionState _services = const LandingSectionState(items: []);
  LandingSectionState _introCourses = const LandingSectionState(items: []);
  bool _envSnackShown = false;

  List<Map<String, dynamic>> get _popularItems => _popularCourses.items;
  List<Map<String, dynamic>> get _teacherItems => _teachers.items;
  List<Map<String, dynamic>> get _serviceItems => _services.items;
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
            ? 'API-konfiguration saknas.'
            : 'Miljövariabler saknas: ${info.missingKeys.join(', ')}.';
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
    try {
      final popular = await ref.read(popularCoursesProvider.future);
      final intros = await ref.read(introCoursesProvider.future);
      final services = await ref.read(recentServicesProvider.future);
      final teachers = await ref.read(teachersProvider.future);
      if (!mounted) return;
      setState(() {
        _popularCourses = popular;
        _introCourses = intros;
        _services = services;
        _teachers = teachers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openIntroModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final items = _introCourses.items;
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
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isLightMode = theme.brightness == Brightness.light;
    final envInfo = ref.watch(envInfoProvider);
    final hasEnvIssues = envInfo.hasIssues;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Fokusera bakgrundens huvud mot mitten av logotypen
    final alignX = _legacyAlignXForWidth(size.width);
    final focalX = _computeFocalFromLegacyAlign(
      alignX: alignX,
      viewportSize: size,
    );
    final pixelNudgeX = _pixelNudgeForWidth(size.width);
    final f = size.width >= 900 ? 0.20 : 0.14;
    final baseYOffset = size.width >= 900 ? -80.0 : -40.0;
    final y = baseYOffset - (_offset.clamp(0.0, 120.0)) * f;
    final topScrimOpacity = size.width >= 900 ? 0.30 : 0.34;
    final imgScale =
        size.width >= 1200 ? 1.06 : (size.width >= 900 ? 1.08 : 1.12);
    final logoSize = size.width >= 900 ? 160.0 : 140.0;
    final topBarHeight = size.width >= 900 ? 96.0 : 84.0;
    final topLogoHeight = size.width >= 900 ? 86.0 : 68.0;
    final heroTopSpacing = size.width >= 900 ? 28.0 : 18.0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: topBarHeight,
        titleSpacing: 0,
        leadingWidth: topBarHeight,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: _Logo(height: topLogoHeight),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    _wisdomBrandGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'Wisdom',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .25,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: hasEnvIssues
                            ? null
                            : () => context.push('/profile'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Logga in'),
                      ),
                      TextButton(
                        onPressed: hasEnvIssues
                            ? null
                            : () => context.push('/profile'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Skapa konto'),
                      ),
                      _PrimaryGradientButton(
                        label: 'Gratis kurser',
                        onTap: hasEnvIssues ? null : _openIntroModal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FullBleedBackground(
              image: _bg,
              focalX: focalX,
              pixelNudgeX: pixelNudgeX,
              topOpacity: topScrimOpacity,
              yOffset: y,
              scale: imgScale,
              sideVignette: 0,
              overlayColor: isLightMode
                  ? const Color(0xFFFFE2B8).withValues(alpha: 0.10)
                  : null,
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: _ParticlesLayer()),
          ),
          Positioned.fill(
            child: BasePage(
              logoSize: logoSize,
              child: SafeArea(
                top: false,
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
                                  ? 'API-konfiguration saknas. Lägg till API_BASE_URL i .env eller via --dart-define för att aktivera inloggning.'
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
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                          child: Column(
                            children: [
                              SizedBox(height: heroTopSpacing),
                              const SizedBox(height: 16),
                              const _GradientHeadline(
                                leading: 'Upptäck din andliga',
                                gradientWord: 'resa',
                              ),
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 18),
                              // CTA buttons – hook intro modal
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _PrimaryGradientButton(
                                    label: 'Börja gratis idag',
                                    onTap:
                                        hasEnvIssues ? null : _openIntroModal,
                                  ),
                                  _GradientOutlineButton(
                                    label: 'Utforska utan konto',
                                    onTap:
                                        hasEnvIssues ? null : _openIntroModal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const _SocialProofRow(
                                items: [
                                  ('Över 1000+', 'nöjda elever'),
                                  ('Certifierade', 'lärare'),
                                  ('30 dagars', 'garanti'),
                                ],
                              ),
                              const SizedBox(height: 28),
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
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: HeroBadge(
                                    text:
                                        'Sveriges ledande plattform för andlig utveckling',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Populära kurser',
                                  style: t.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .2,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                                              child:
                                                  CircularProgressIndicator()))
                                      : _popularItems.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text('Inga kurser ännu.'),
                                            )
                                          : LayoutBuilder(
                                              builder: (context, c) {
                                              final w = c.maxWidth;
                                              final cross = w >= 900
                                                  ? 3
                                                  : (w >= 600 ? 2 : 1);
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: _popularItems.length,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: cross,
                                                  crossAxisSpacing: 12,
                                                  mainAxisSpacing: 12,
                                                  childAspectRatio: 1.35,
                                                ),
                                                itemBuilder: (_, i) {
                                                  final c = _popularItems[i];
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
                                      : _teacherItems.isEmpty
                                          ? const Center(
                                              child: Text('Inga lärare ännu.'))
                                          : ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _teacherItems.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(width: 8),
                                              itemBuilder: (_, i) =>
                                                  _TeacherPillData(
                                                      map: _teacherItems[i]),
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
                                    : _serviceItems.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text('Inga tjänster ännu.'),
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
                                              itemCount: _serviceItems.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: cross,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                                childAspectRatio: 1.4,
                                              ),
                                              itemBuilder: (_, i) =>
                                                  _ServiceTileGlass(
                                                      service:
                                                          _serviceItems[i]),
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
                                    runSpacing: 10,
                                    children: [
                                      _PrimaryGradientButton(
                                        label: 'Börja gratis',
                                        onTap: _openIntroModal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                      ),
                                      _GradientOutlineButton(
                                        label: 'Utforska utan konto',
                                        onTap: _openIntroModal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 12,
                                        ),
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
            ),
          ),
        ],
      ),
    );
  }

  double _legacyAlignXForWidth(double width) {
    if (width >= 1200) return -0.84;
    if (width >= 900) return -0.82;
    return -0.78;
  }

  double _computeFocalFromLegacyAlign({
    required double alignX,
    required Size viewportSize,
  }) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      return 0.5;
    }
    final coverScale = math.max(
      viewportSize.width / _backgroundImageSize.width,
      viewportSize.height / _backgroundImageSize.height,
    );
    if (!coverScale.isFinite || coverScale <= 0) {
      return 0.5;
    }
    final sourceWidth = viewportSize.width / coverScale;
    final targetX = _backgroundImageSize.width / 2 +
        alignX * (_backgroundImageSize.width - sourceWidth) / 2;
    return (targetX / _backgroundImageSize.width).clamp(0.0, 1.0);
  }

  double _pixelNudgeForWidth(double width) {
    // Negativ pixel-nudge flyttar motivet åt höger i viewporten.
    if (width >= 1200) return -2.0;
    if (width >= 900) return -3.0;
    return -4.0;
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: Image.asset(
        'assets/loggo_clea.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        cacheWidth: (height * dpr).round(),
      ),
    );
  }
}

/* ---------- Små UI-komponenter i denna fil ---------- */

class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  final String label;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        gradient: _wisdomPrimaryGradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C8EEE).withAlpha(110),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
            ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      result = Opacity(opacity: 0.5, child: result);
    }

    return SizedBox(height: 48, child: result);
  }
}

class _GradientOutlineButton extends StatelessWidget {
  const _GradientOutlineButton({
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  final String label;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999);
    final backgroundColor = Colors.white.withValues(alpha: 0.10);
    final splashColor = Colors.white.withValues(alpha: 0.12);
    final highlightColor = Colors.white.withValues(alpha: 0.06);

    Widget button = Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .15,
                ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      button = Opacity(opacity: 0.5, child: button);
    }

    return SizedBox(height: 48, child: button);
  }
}

class _GradientHeadline extends StatefulWidget {
  final String leading;
  final String gradientWord;
  const _GradientHeadline({
    required this.leading,
    required this.gradientWord,
  });

  @override
  State<_GradientHeadline> createState() => _GradientHeadlineState();
}

class _GradientHeadlineState extends State<_GradientHeadline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        Text(widget.leading, textAlign: TextAlign.center, style: base),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                final sweep = bounds.width * 1.5;
                final start = -bounds.width + sweep * _controller.value;
                return const LinearGradient(
                  colors: [
                    Color(0xFF63C7D6),
                    Color(0xFFB58FF3),
                    Color(0xFF63C7D6),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(
                  Rect.fromLTWH(start, 0, sweep, bounds.height),
                );
              },
              child: child,
            );
          },
          child: Text(
            widget.gradientWord,
            textAlign: TextAlign.center,
            style: base?.copyWith(color: Colors.white),
          ),
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
  final _rnd = math.Random();
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
      final dy = math.sin((t * 2 * math.pi) + i) * 0.6; // flyter sakta
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
