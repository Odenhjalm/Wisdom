import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/data/models/activity.dart';
import 'package:wisdom/data/models/service.dart';
import 'package:wisdom/data/repositories/orders_repository.dart';
import 'package:wisdom/features/home/application/home_providers.dart';
import 'package:wisdom/features/landing/application/landing_providers.dart'
    as landing;
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  final Set<String> _loadingServiceIds = <String>{};

  @override
  Widget build(BuildContext context) {
    ref.watch(authControllerProvider);
    final feedAsync = ref.watch(homeFeedProvider);
    final servicesAsync = ref.watch(homeServicesProvider);
    final exploreAsync = ref.watch(landing.popularCoursesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wisdom',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: 'Studio',
            onPressed: () => context.go('/studio'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: FullBleedBackground(
        image: const AssetImage('assets/images/bakgrund.png'),
        alignment: Alignment.center,
        topOpacity: 0.22,
        overlayColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFFFE2B8).withValues(alpha: 0.16),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeFeedProvider);
            ref.invalidate(homeServicesProvider);
            ref.invalidate(landing.popularCoursesProvider);
            await ref.read(authControllerProvider.notifier).loadSession();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 110, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ExploreCoursesSection(
                              section: exploreAsync,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FeedSection(feedAsync: feedAsync),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ServicesSection(
                              servicesAsync: servicesAsync,
                              isLoading: (id) =>
                                  _loadingServiceIds.contains(id),
                              onCheckout: (service) =>
                                  _handleServiceCheckout(context, service),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SfuSection(),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 110, 16, 32),
                children: [
                  _ExploreCoursesSection(section: exploreAsync),
                  const SizedBox(height: 16),
                  _FeedSection(feedAsync: feedAsync),
                  const SizedBox(height: 16),
                  _ServicesSection(
                    servicesAsync: servicesAsync,
                    isLoading: (id) => _loadingServiceIds.contains(id),
                    onCheckout: (service) =>
                        _handleServiceCheckout(context, service),
                  ),
                  const SizedBox(height: 16),
                  _SfuSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleServiceCheckout(
    BuildContext context,
    Service service,
  ) async {
    if (_loadingServiceIds.contains(service.id)) return;
    final messenger = ScaffoldMessenger.of(context);
    void showMessage(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() => _loadingServiceIds.add(service.id));
    try {
      final ordersRepo = ref.read(ordersRepositoryProvider);
      final authState = ref.read(authControllerProvider);
      final order = await ordersRepo.createServiceOrder(serviceId: service.id);
      if (!mounted) return;
      final url = await ordersRepo.createStripeCheckout(
        orderId: order.id,
        successUrl: 'https://example.com/success',
        cancelUrl: 'https://example.com/cancel',
        email: authState.profile?.email,
      );
      if (url.isEmpty) {
        if (!mounted) return;
        showMessage('Kunde inte starta betalflödet.');
        return;
      }
      final launched = await launchUrlString(url);
      if (!mounted) return;
      if (!launched) {
        showMessage('Kunde inte öppna betalningslänken.');
      }
    } catch (error, stackTrace) {
      debugPrint('checkout failed: $error\n$stackTrace');
      if (!mounted) return;
      showMessage('Kunde inte skapa beställning: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingServiceIds.remove(service.id));
      }
    }
  }
}

class _ExploreCoursesSection extends StatelessWidget {
  const _ExploreCoursesSection({required this.section});

  final AsyncValue<landing.LandingSectionState> section;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Utforska kurser',
      trailing: TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        onPressed: () => context.go('/course-intro'),
        child: const Text('Visa alla'),
      ),
      child: section.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Text('Kunde inte hämta kurser: ${error.toString()}'),
        data: (state) {
          final items = state.items;
          if (items.isEmpty) {
            return const Text('Inga kurser publicerade ännu.');
          }
          return Column(
            children: items.take(6).map((course) {
              final title = (course['title'] as String?) ?? 'Kurs';
              final description = (course['description'] as String?) ?? '';
              final slug = (course['slug'] as String?) ?? '';
              final isIntro = course['is_free_intro'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: slug.isEmpty
                      ? null
                      : () =>
                          context.go('/course/${Uri.encodeComponent(slug)}'),
                  borderRadius: BorderRadius.circular(16),
                  child: _GlassTile(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_stories, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                              if (isIntro) ...[
                                const SizedBox(height: 6),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    label: Text('Gratis intro'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}

class _FeedSection extends StatelessWidget {
  const _FeedSection({required this.feedAsync});

  final AsyncValue<List<Activity>> feedAsync;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Gemensam vägg',
      trailing: TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        onPressed: () => context.go('/community'),
        child: const Text('Visa allt'),
      ),
      child: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Kunde inte hämta feed: ${error.toString()}'),
        data: (activities) {
          if (activities.isEmpty) {
            return const Text(
              'Inga aktiviteter ännu.',
              style: TextStyle(color: Colors.white70),
            );
          }
          return Column(
            children: [
              for (final activity in activities.take(10))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _GlassTile(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_outlined, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activity.summary.isEmpty
                                    ? activity.type
                                    : activity.summary,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                MaterialLocalizations.of(context)
                                    .formatFullDate(
                                  activity.occurredAt.toLocal(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.servicesAsync,
    required this.onCheckout,
    required this.isLoading,
  });

  final AsyncValue<List<Service>> servicesAsync;
  final Future<void> Function(Service service) onCheckout;
  final bool Function(String id) isLoading;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tjänster',
      trailing: TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        onPressed: () => context.go('/services'),
        child: const Text('Visa alla'),
      ),
      child: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Text('Kunde inte hämta tjänster: ${error.toString()}'),
        data: (services) {
          if (services.isEmpty) {
            return const Text(
              'Inga tjänster publicerade just nu.',
              style: TextStyle(color: Colors.white70),
            );
          }
          return Column(
            children: services.take(5).map((service) {
              final loading = isLoading(service.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _GlassTile(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        service.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          service.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${service.price.toStringAsFixed(2)} ${service.currency.toUpperCase()}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                          FilledButton(
                            onPressed:
                                loading ? null : () => onCheckout(service),
                            child: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Boka'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _GlassSection(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SfuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Liveseminar (SFU)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Testa LiveKit-anslutningen mot backendens `/sfu/token` '
            'genom att öppna demo-sidan. Kräver att LiveKit-nycklar finns i `.env`.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go('/sfu-demo'),
            icon: const Icon(Icons.video_call_rounded),
            label: const Text('Öppna LiveKit-demo'),
          ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.38);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                baseColor.withValues(alpha: 0.68),
              ],
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassTile extends StatelessWidget {
  const _GlassTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            color: Colors.white.withValues(alpha: 0.22),
          ),
          child: child,
        ),
      ),
    );
  }
}
