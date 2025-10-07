import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/shared/utils/snack.dart';

class TopNavActionButtons extends ConsumerWidget {
  const TopNavActionButtons({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    if (profile == null) {
      return IconButton(
        tooltip: 'Logga in',
        icon: Icon(Icons.login,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface),
        onPressed: () => context.go('/login'),
      );
    }

    final color = iconColor ?? Theme.of(context).colorScheme.onSurface;
    final isTeacher = profile.isTeacher || profile.isAdmin;

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
          onPressed: () {
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
