import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back button that works with GoRouter and falls back to landing when the
/// stack is empty.
class GoRouterBackButton extends StatelessWidget {
  const GoRouterBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          context.go('/');
        }
      },
    );
  }
}
