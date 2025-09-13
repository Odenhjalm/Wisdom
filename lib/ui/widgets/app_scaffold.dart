import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Baslayout: backknapp (pop eller fallback hem), maxbredd, padding, diskret bakgrund.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Sätt true där du *inte* vill visa back (t.ex. på Home).
  final bool disableBack;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.disableBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final canPop = router.canPop();
    final showBack = !disableBack;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (canPop) {
                    router.pop();
                  } else {
                    context.go('/'); // fallback hem om ingen stack
                  }
                },
              )
            : null,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // diskret gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.08),
                    Colors.transparent,
                    cs.secondary.withOpacity(0.06),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // innehåll
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
