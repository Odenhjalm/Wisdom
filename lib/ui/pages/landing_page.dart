// lib/ui/pages/landing_page.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/hero_badge.dart';
import '../widgets/hero_cta.dart';
import '../widgets/intro_card.dart';
import '../widgets/app_scaffold.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final _scroll = ScrollController();
  double _offset = 0.0;
  late final ImageProvider _bg;

  // 🔒 säkerställ att vi bara precachar en gång, och först när inherited widgets finns
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _bg = const AssetImage('assets/images/hero_landingpage.png');

    _scroll.addListener(() {
      setState(() => _offset = _scroll.offset.clamp(0.0, 400.0));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ precache här (inte i initState) för att undvika “dependOnInheritedWidget”–felet
    if (!_didPrecache) {
      precacheImage(_bg, context);
      _didPrecache = true;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    // Subtil parallax – ytterligare förfinad: lite svagare och hårdare cap
    final f = size.width >= 900 ? 0.20 : 0.14;
    final y = -(_offset.clamp(0.0, 120.0)) * f;
    // Premium-gradient – något djupare, tydligare separation
    final topGrad = size.width >= 900 ? 0.40 : 0.44;
    final bottomGrad = size.width >= 900 ? 0.62 : 0.66;
    // Skala upp bilden aningen för att garanterat klippa bort ev. vit kant i asset
    final imgScale = size.width >= 1200
        ? 1.06
        : (size.width >= 900 ? 1.08 : 1.12);
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
                          Colors.white.withOpacity(.18),
                          Colors.white.withOpacity(.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(.28)),
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
                'Andlig Visdom',
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: .25,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(.50),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/profile'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Logga in'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.push('/course/intro'),
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
                child: const Text('Starta gratis'),
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
                              color: Colors.white.withOpacity(.92),
                              height: 1.36,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const HeroCTA(),
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

                // SEKTION 2 – Intro-grenar
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
                              'Introduktioner',
                              style: t.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Välj en gren – 1–2 lektioner gratis per gren.',
                              style:
                                  t.bodyLarge?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),

                            // Grid
                            LayoutBuilder(
                              builder: (context, c) {
                                final w = c.maxWidth;
                                final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);
                                final items = const [
                                  (
                                    'Vit magi – grund',
                                    Icons.auto_fix_high_rounded
                                  ),
                                  ('Ceremoni & Ritual', Icons.park_rounded),
                                  (
                                    'Meditation & Ljud',
                                    Icons.graphic_eq_rounded
                                  ),
                                  ('Tarot & Symbolik', Icons.style_rounded),
                                  ('Växtriket', Icons.eco_rounded),
                                  ('Skuggarbete', Icons.dark_mode_rounded),
                                ];
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cross,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 1.35,
                                  ),
                                  itemBuilder: (_, i) {
                                    final (title, icon) = items[i];
                                    return IntroCard(
                                      title: title,
                                      subtitle: '2 gratis lektioner',
                                      icon: icon,
                                      onTap: () =>
                                          context.push('/course/intro'),
                                    );
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

                // CTA-banderoll
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 44),
                      child: Card(
                        color: Colors.white.withOpacity(.18),
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side:
                              BorderSide(color: Colors.white.withOpacity(.22)),
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
                                  'Bli certifierad och lås upp communityt. '
                                  'Skapa och erbjud egna ceremonier, sessioner och läsningar.',
                                  style: t.bodyLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => context.push('/course/intro'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Läs mer'),
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
          ).createShader(Rect.fromLTWH(0, 0, 400, 80)),
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
      ..color = const Color(0xFFFFFFFF).withOpacity(.10)
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
