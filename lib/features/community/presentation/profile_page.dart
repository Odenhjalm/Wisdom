import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/certificate.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/features/courses/application/course_providers.dart'
    as courses_front;
import 'package:wisdom/features/courses/data/courses_repository.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/shared/utils/snack.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';
import 'package:wisdom/shared/widgets/top_nav_action_buttons.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final certificatesAsync = ref.watch(myCertificatesProvider);
    final coursesAsync = ref.watch(courses_front.myCoursesProvider);

    if (authState.isLoading && profile == null) {
      return const AppScaffold(
        title: 'Profil',
        neutralBackground: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const _LoginRequiredCard();
    }

    return AppScaffold(
      title: 'Profil',
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      appBarForegroundColor: Colors.white,
      actions: const [TopNavActionButtons(iconColor: Colors.white)],
      background: FullBleedBackground(
        image: const AssetImage('assets/images/bakgrund.png'),
        alignment: Alignment.center,
        topOpacity: 0.38,
        sideVignette: 0.15,
        overlayColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFFFE2B8).withValues(alpha: 0.22),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 880;
          const columnGap = SizedBox(height: 16);
          const rowGap = SizedBox(width: 16);

          Widget buildRow(Widget left, Widget right) {
            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  left,
                  columnGap,
                  right,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                rowGap,
                Expanded(child: right),
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 130, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IdentitySection(
                  profile: profile,
                  onEdit: () => context.push('/profile/edit'),
                  onLogout: () => _logout(context, ref),
                ),
                columnGap,
                buildRow(
                  _BioSection(
                    profile: profile,
                    onEdit: () => context.push('/profile/edit'),
                  ),
                  _CertificatesSection(certificatesAsync: certificatesAsync),
                ),
                columnGap,
                buildRow(
                  _ServicesSection(
                    profile: profile,
                    onOpenStudio: () => context.go('/studio'),
                  ),
                  _CoursesSection(
                    coursesAsync: coursesAsync,
                    onSeeAll: () => context.go('/course-intro'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    showSnack(context, 'Utloggad');
    context.go('/landing');
  }
}

class _IdentitySection extends StatelessWidget {
  const _IdentitySection({
    required this.profile,
    required this.onEdit,
    required this.onLogout,
  });

  final Profile profile;
  final VoidCallback onEdit;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = profile.displayName?.trim().isNotEmpty == true
        ? profile.displayName!
        : profile.email;
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part.characters.first.toUpperCase())
        .take(2)
        .join();
    final joinDate = MaterialLocalizations.of(context)
        .formatFullDate(profile.createdAt.toLocal());

    final chips = <Widget>[
      _ProfileChip(
        icon: Icons.calendar_today_rounded,
        label: 'Medlem sedan $joinDate',
      ),
      _ProfileChip(
        icon: Icons.workspace_premium_rounded,
        label: profile.isProfessional ? 'Pro-medlem' : 'Medlem',
      ),
      if (profile.isAdmin)
        const _ProfileChip(icon: Icons.shield_rounded, label: 'Admin'),
    ];

    return _GlassSection(
      title: 'Din profil',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(
                  initials.isEmpty
                      ? displayName.characters.first.toUpperCase()
                      : initials,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: onEdit,
                child: const Text('Redigera profil'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () async => await onLogout(),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Logga ut'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection({required this.profile, required this.onEdit});

  final Profile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bio = profile.bio?.trim();
    return _GlassSection(
      title: 'Om mig',
      actions: [
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Redigera'),
        ),
      ],
      child: Text(
        bio?.isNotEmpty == true
            ? bio!
            : 'Berätta kort om dig själv och vad du erbjuder. Denna text visas i communityt och för potentiella kunder.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }
}

class _CoursesSection extends StatelessWidget {
  const _CoursesSection({
    required this.coursesAsync,
    required this.onSeeAll,
  });

  final AsyncValue<List<CourseSummary>> coursesAsync;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassSection(
      title: 'Pågående kurser',
      actions: [
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Utforska fler'),
        ),
      ],
      child: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(
          error is AppFailure ? error.message : error.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Text(
              'Du är inte inskriven i någon kurs ännu.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            );
          }
          return Column(
            children: courses.take(5).map((course) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    final slug = course.slug ?? course.id;
                    if (slug.isEmpty) return;
                    context.go('/course/${Uri.encodeComponent(slug)}');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if ((course.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            course.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        if (course.isFreeIntro) ...[
                          const SizedBox(height: 10),
                          const _ProfileChip(
                            icon: Icons.auto_awesome,
                            label: 'Gratis intro',
                          ),
                        ],
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

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.profile,
    required this.onOpenStudio,
  });

  final Profile profile;
  final VoidCallback onOpenStudio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (profile.isProfessional) {
      return _GlassSection(
        title: 'Mina tjänster',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Du är certifierad Pro och kan sälja sessioner, ceremonier och vägledning.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onOpenStudio,
              child: const Text('Hantera i Studio'),
            ),
            const SizedBox(height: 8),
            Text(
              'Öppna Studio för att uppdatera tjänster, priser och tillgänglighet.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return _GlassSection(
      title: 'Mina tjänster',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'När du slutfört sista delen i Pro-kursen aktiveras möjligheten att sälja tjänster.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Dina publicerade tjänster visas här så snart certifieringen är klar.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection({required this.certificatesAsync});

  final AsyncValue<List<Certificate>> certificatesAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassSection(
      title: 'Mina certifikat',
      child: certificatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(
          error is AppFailure ? error.message : error.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        data: (certificates) {
          if (certificates.isEmpty) {
            return Text(
              'Inga certifikat är registrerade ännu. Lägg till dina diplom och intyg via Studio.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            );
          }
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: certificates
                .map((c) => _CertificateBadge(certificate: c))
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (actions != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: actions!,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _CertificateBadge extends StatelessWidget {
  const _CertificateBadge({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = certificate.status;
    final color = switch (status) {
      CertificateStatus.verified => Colors.greenAccent,
      CertificateStatus.rejected => Colors.redAccent,
      CertificateStatus.pending => Colors.orangeAccent,
      CertificateStatus.unknown => Colors.lightBlueAccent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            certificate.isVerified
                ? Icons.workspace_premium_rounded
                : certificate.isPending
                    ? Icons.hourglass_top_rounded
                    : certificate.isRejected
                        ? Icons.highlight_off_rounded
                        : Icons.description_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                certificate.title.trim().isEmpty
                    ? 'Certifikat'
                    : certificate.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _statusLabel(certificate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _statusLabel(Certificate certificate) {
    switch (certificate.status) {
      case CertificateStatus.pending:
        return 'Under granskning';
      case CertificateStatus.verified:
        return 'Verifierat';
      case CertificateStatus.rejected:
        return 'Avslaget';
      case CertificateStatus.unknown:
        return certificate.statusRaw;
    }
  }
}

class _LoginRequiredCard extends StatelessWidget {
  const _LoginRequiredCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Profil',
      neutralBackground: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logga in för att fortsätta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Du behöver ett konto för att se din profil.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/login?redirect=%2Fprofile'),
                    child: const Text('Logga in'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.go('/signup?redirect=%2Fprofile'),
                    child: const Text('Skapa konto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
