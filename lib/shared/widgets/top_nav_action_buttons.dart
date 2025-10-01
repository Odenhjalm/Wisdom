import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/domain/services/auth_service.dart';
import 'package:wisdom/gate.dart';
import 'package:wisdom/supabase_client.dart';
import 'package:wisdom/shared/utils/snack.dart';

class TopNavActionButtons extends ConsumerWidget {
  const TopNavActionButtons({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sb = ref.watch(supabaseMaybeProvider);
    final user = sb?.auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }
    if (!gate.allowed) {
      gate.allow();
    }
    final color = iconColor ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Home',
          icon: Icon(Icons.home_outlined, color: color),
          onPressed: () => context.go('/home'),
        ),
        IconButton(
          tooltip: 'Teacher Home',
          icon: Icon(Icons.home_work_outlined, color: color),
          onPressed: () async {
            final isTeacher = await userIsTeacher(client: sb);
            if (!context.mounted) return;
            if (!isTeacher) {
              showSnack(context, 'Endast för lärare');
              return;
            }
            context.go('/teacher');
          },
        ),
        IconButton(
          tooltip: 'Min profil',
          icon: Icon(Icons.person_outline, color: color),
          onPressed: () => context.go('/profile/edit'),
        ),
      ],
    );
  }
}
