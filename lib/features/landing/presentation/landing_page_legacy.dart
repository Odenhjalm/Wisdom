import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/shared/theme/ui_consts.dart';
import 'package:wisdom/shared/widgets/glass_card.dart';
import 'package:wisdom/features/landing/application/landing_providers.dart';
import 'package:wisdom/shared/widgets/background_layer.dart';
import 'package:wisdom/widgets/base_page.dart';

const String _devConfigHint = 'Konfigurera Supabase i .env om data saknas.';

class LegacyLandingPage extends ConsumerStatefulWidget {
  const LegacyLandingPage({super.key});

  @override
  ConsumerState<LegacyLandingPage> createState() => _LegacyLandingPageState();
}

class _LegacyLandingPageState extends ConsumerState<LegacyLandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _coursesKey = GlobalKey();
  final GlobalKey _teachersKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final BuildContext? ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openIntroModal(BuildContext context) async {
    final state = await ref.read(introCoursesProvider.future);
    final items = state.items;

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                ),
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
                          const Icon(Icons.auto_awesome, color: Colors.black87),
                          const SizedBox(width: 8),
                          const Text(
                            'Gratis introduktionskurser',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (items.isEmpty)
                        Padding(
                          padding: p12,
                          child: _LandingMessage(
                            message: state.hasError
                                ? (state.errorMessage ??
                                    'Kunde inte hämta introduktionskurser just nu.')
                                : 'Inga introduktionskurser ännu.',
                            hint: state.devHint,
                            center: true,
                          ),
                        )
                      else ...[
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                            child: _LandingMessage(
                              message: state.errorMessage ??
                                  'Kunde inte hämta introduktionskurser just nu.',
                              hint: state.devHint,
                              center: true,
                            ),
                          ),
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length > 5 ? 5 : items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, int index) {
                            final m = items[index];
                            final id = (m['id'] ?? '').toString();
                            final title =
                                (m['title'] ?? 'Introduktion').toString();
                            return ListTile(
                              leading: const Icon(Icons.play_circle_outline),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Chip(
                                label: Text('Gratis intro'),
                                visualDensity: VisualDensity.compact,
                              ),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                if (!context.mounted) return;
                                context.go(
                                  '/course-intro?id=$id&title=${Uri.encodeComponent(title)}',
                                );
                              },
                            );
                          },
                        ),
                      ],
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
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700 && size.width < 1000;
    final bool isDesktop = size.width >= 1000;
    final double titleSize = isDesktop ? 58.0 : (isTablet ? 42.0 : 32.0);

    final ButtonStyle loginButtonStyle = ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(Color(0xFF0B1526)),
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      iconSize: const WidgetStatePropertyAll(18),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? const Color(0xFF0B1526).withValues(alpha: 0.08)
            : null,
      ),
    );

    const ButtonStyle exploreStyle = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Color(0xFF0B1526)),
      backgroundColor: WidgetStatePropertyAll(Colors.white),
      side: WidgetStatePropertyAll(BorderSide(color: Color(0xFFE2E8F0))),
      padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
      shape: WidgetStatePropertyAll(StadiumBorder()),
    );

    const ButtonStyle primaryAccentStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xFF35C284)),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
      shape: WidgetStatePropertyAll(StadiumBorder()),
    );

    return Scaffold(
      body: BasePage(
        child: Stack(
          children: [
            const Positioned.fill(child: BackgroundLayer()),
            SafeArea(
              top: false,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const GlassCard(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.auto_awesome,
                                            color: Colors.black54, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Kurser, tjänster och lärare – i ett ljust, välkomnande flöde.',
                                          style:
                                              TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                  gap16,
                                  const SizedBox(height: 2),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: const Color(0xFF0B1526),
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Upptäck din '),
                                        TextSpan(
                                          text: 'andliga resa',
                                          style: TextStyle(
                                            fontSize: titleSize * 1.12,
                                            fontWeight: FontWeight.w900,
                                            foreground: Paint()
                                              ..shader = const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF22C55E),
                                                  Color(0xFFA855F7)
                                                ],
                                              ).createShader(
                                                const Rect.fromLTWH(
                                                    0, 0, 200, 60),
                                              ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  gap12,
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 720),
                                    child: const Text(
                                      'På Wisdom kan du hitta inspirerande kurser, möta lärare och ta del av tjänster som guidar dig framåt – i ditt tempo.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black87, fontSize: 16),
                                    ),
                                  ),
                                  gap16,
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      FilledButton(
                                        style: primaryAccentStyle,
                                        onPressed: () =>
                                            _openIntroModal(context),
                                        child: const Text(
                                            'Starta gratis introduktion'),
                                      ),
                                      OutlinedButton(
                                        style: exploreStyle,
                                        onPressed: () => _scrollTo(_coursesKey),
                                        child:
                                            const Text('Utforska utan konto'),
                                      ),
                                    ],
                                  ),
                                  gap16,
                                  const Wrap(
                                    spacing: 16,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _StatChip(
                                          icon: Icons.emoji_events,
                                          a: 'Över 1000+',
                                          b: 'nöjda elever'),
                                      _StatChip(
                                          icon: Icons.verified,
                                          a: 'Certifierade',
                                          b: 'lärare'),
                                      _StatChip(
                                          icon: Icons.verified_user,
                                          a: '30 dagars',
                                          b: 'garanti'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const _SectionTitle('Populära kurser'),
                            GlassCard(
                              key: _coursesKey,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final async =
                                      ref.watch(popularCoursesProvider);
                                  return async.when(
                                    loading: () => const _GlassGridSkeleton(
                                        itemHeight: 220),
                                    error: (_, __) => const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _GlassGridSkeleton(itemHeight: 220),
                                        gap12,
                                        _LandingMessage(
                                          message:
                                              'Kunde inte hämta kurslistan just nu.',
                                          hint: _devConfigHint,
                                        ),
                                      ],
                                    ),
                                    data: (state) {
                                      if (state.hasError) {
                                        return const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _GlassGridSkeleton(itemHeight: 220),
                                            gap12,
                                            _LandingMessage(
                                              message:
                                                  'Kunde inte hämta kurslistan just nu.',
                                              hint: _devConfigHint,
                                            ),
                                          ],
                                        );
                                      }
                                      final items = state.items;
                                      if (items.isEmpty) {
                                        return const _LandingMessage(
                                          message: 'Inga kurser ännu.',
                                          hint: _devConfigHint,
                                        );
                                      }
                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double w = constraints.maxWidth;
                                          int cols = 1;
                                          if (w >= 1200) {
                                            cols = 4;
                                          } else if (w >= 900) {
                                            cols = 3;
                                          } else if (w >= 600) {
                                            cols = 2;
                                          }
                                          final double width =
                                              (w - ((cols - 1) * 12)) / cols;
                                          return Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              for (final m in items)
                                                SizedBox(
                                                  width: width,
                                                  child: _CourseTile(
                                                    title: '${m['title']}',
                                                    description:
                                                        (m['description'] ?? '')
                                                            as String?,
                                                    imageUrl: (m['cover_url'] ??
                                                        '') as String?,
                                                    isIntro:
                                                        m['is_free_intro'] ==
                                                            true,
                                                    onTap: () => context.go(
                                                        '/course-intro?id=${m['id']}&title=${Uri.encodeComponent(m['title'] ?? '')}'),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            gap24,
                            const _SectionTitle('Lärare'),
                            GlassCard(
                              key: _teachersKey,
                              padding: p12,
                              child: SizedBox(
                                height: 180,
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final async = ref.watch(teachersProvider);
                                    return async.when(
                                      loading: () =>
                                          const _TeacherSkeletonList(),
                                      error: (_, __) => const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: _TeacherSkeletonList()),
                                          gap8,
                                          _LandingMessage(
                                            message:
                                                'Kunde inte hämta lärarlistan just nu.',
                                            hint: _devConfigHint,
                                          ),
                                        ],
                                      ),
                                      data: (state) {
                                        if (state.hasError) {
                                          return const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child:
                                                      _TeacherSkeletonList()),
                                              gap8,
                                              _LandingMessage(
                                                message:
                                                    'Kunde inte hämta lärarlistan just nu.',
                                                hint: _devConfigHint,
                                              ),
                                            ],
                                          );
                                        }
                                        final items = state.items;
                                        if (items.isEmpty) {
                                          return const Center(
                                            child: _LandingMessage(
                                              message: 'Inga lärare ännu.',
                                              hint: _devConfigHint,
                                              center: true,
                                            ),
                                          );
                                        }
                                        return ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: items.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 12),
                                          itemBuilder: (context, index) {
                                            final t = items[index];
                                            return _TeacherPill(
                                              name: (t['display_name'] ??
                                                  'Lärare') as String,
                                              avatarUrl: (t['photo_url'] ?? '')
                                                  as String?,
                                              bio: (t['bio'] ?? '') as String?,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            gap24,
                            const _SectionTitle('Tjänster'),
                            GlassCard(
                              key: _servicesKey,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final async =
                                      ref.watch(recentServicesProvider);
                                  return async.when(
                                    loading: () => const _GlassGridSkeleton(
                                        itemHeight: 160),
                                    error: (_, __) => const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _GlassGridSkeleton(itemHeight: 160),
                                        gap12,
                                        _LandingMessage(
                                          message:
                                              'Kunde inte hämta tjänsterna just nu.',
                                          hint: _devConfigHint,
                                        ),
                                      ],
                                    ),
                                    data: (state) {
                                      if (state.hasError) {
                                        return const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _GlassGridSkeleton(itemHeight: 160),
                                            gap12,
                                            _LandingMessage(
                                              message:
                                                  'Kunde inte hämta tjänsterna just nu.',
                                              hint: _devConfigHint,
                                            ),
                                          ],
                                        );
                                      }
                                      final items = state.items;
                                      if (items.isEmpty) {
                                        return const _LandingMessage(
                                          message: 'Inga tjänster ännu.',
                                          hint: _devConfigHint,
                                        );
                                      }
                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double w = constraints.maxWidth;
                                          int cols = 1;
                                          if (w >= 1200) {
                                            cols = 3;
                                          } else if (w >= 900) {
                                            cols = 3;
                                          } else if (w >= 600) {
                                            cols = 2;
                                          }
                                          final double width =
                                              (w - ((cols - 1) * 12)) / cols;
                                          return Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              for (final s in items)
                                                SizedBox(
                                                  width: width,
                                                  child: _ServiceTile(
                                                    title: '${s['title']}',
                                                    description:
                                                        (s['description'] ?? '')
                                                            as String?,
                                                    area:
                                                        (s['certified_area'] ??
                                                            '') as String?,
                                                    priceCents: s['price_cents']
                                                        as int?,
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            gap24,
                            const _SectionTitle('Hur fungerar Wisdom?'),
                            const _HowItWorks(),
                            gap24,
                            const Align(
                              alignment: Alignment.center,
                              child: GlassCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Colors.black54, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sveriges ledande plattform för andlig utveckling',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            gap24,
                            GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.workspace_premium,
                                        color: Colors.black87),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                          'Redo att börja? Skapa konto eller utforska kurser.'),
                                    ),
                                    FilledButton(
                                      onPressed: () => context.go('/signup'),
                                      child: const Text('Börja gratis idag'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _scrollTo(_coursesKey),
                                      child: const Text('Utforska kurser'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            gap24,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 16,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: TextButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.login,
                            size: 18, color: Colors.black54),
                        label: const Text('Logga in'),
                        style: loginButtonStyle,
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _LandingMessage extends StatelessWidget {
  final String message;
  final String? hint;
  final bool center;
  const _LandingMessage(
      {required this.message, this.hint, this.center = false});

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment alignment =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final TextAlign textAlign = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: textAlign,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (hint != null && hint!.isNotEmpty) ...[
          gap4,
          Text(
            hint!,
            textAlign: textAlign,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String a;
  final String b;
  const _StatChip({required this.icon, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(b,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}

class _GlassGridSkeleton extends StatelessWidget {
  final double itemHeight;
  const _GlassGridSkeleton({required this.itemHeight});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        int cols = 1;
        if (w >= 1200) {
          cols = 4;
        } else if (w >= 900) {
          cols = 3;
        } else if (w >= 600) {
          cols = 2;
        }
        final double width = (w - ((cols - 1) * 12)) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            cols * 2,
            (_) => _GlassBlock(width: width, height: itemHeight),
          ),
        );
      },
    );
  }
}

class _GlassBlock extends StatelessWidget {
  final double width;
  final double height;
  const _GlassBlock({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          border:
              Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final String title;
  final String? description;
  final String? imageUrl;
  final bool isIntro;
  final VoidCallback onTap;

  const _CourseTile({
    required this.title,
    this.description,
    this.imageUrl,
    required this.isIntro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: Colors.black38),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (isIntro)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Gratis intro',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    gap8,
                    Text(
                      description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherPill extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? bio;
  const _TeacherPill({required this.name, this.avatarUrl, this.bio});

  @override
  Widget build(BuildContext context) {
    final bool hasBio = bio != null && bio!.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (hasBio) ...[
                      const SizedBox(height: 6),
                      Text(
                        bio!.trim(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                      const Text('Bio saknas',
                          style: TextStyle(color: Colors.black54)),
                      TextButton(
                        onPressed: () => context.go('/profile/edit'),
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          minimumSize: WidgetStatePropertyAll(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Uppdatera profil'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String? description;
  final String? area;
  final int? priceCents;

  const _ServiceTile({
    required this.title,
    this.description,
    this.area,
    this.priceCents,
  });

  @override
  Widget build(BuildContext context) {
    final String priceText = priceCents == null
        ? ''
        : '${(priceCents! / 100).toStringAsFixed(0)} kr';
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (description != null && description!.isNotEmpty) ...[
              gap8,
              Text(
                description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            gap12,
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (area != null && area!.isNotEmpty)
                  Chip(
                    label: Text(area!),
                    visualDensity: VisualDensity.compact,
                  ),
                if (priceText.isNotEmpty)
                  Chip(
                    label: Text(priceText),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherSkeletonList extends StatelessWidget {
  const _TeacherSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              border: Border.all(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                gap12,
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                gap8,
                Container(
                  height: 12,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.search,
        title: 'Utforska',
        text: 'Bläddra bland kurser, lärare och tjänster som matchar din väg.',
      ),
      (
        icon: Icons.play_circle_outline,
        title: 'Starta',
        text: 'Dyk in i gratis introduktioner eller boka en kurs direkt.',
      ),
      (
        icon: Icons.favorite_outline,
        title: 'Följ upp',
        text:
            'Spara favoriter, fortsätt där du slutade och väx tillsammans med communityn.',
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        for (final item in items)
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 28, color: const Color(0xFF2563EB)),
                  gap12,
                  Text(
                    item.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  gap8,
                  Text(
                    item.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
