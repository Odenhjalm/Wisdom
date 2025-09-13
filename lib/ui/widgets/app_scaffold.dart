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
  /// Neutral bakgrund: ingen gradient, ljus/ren yta för t.ex. login.
  final bool neutralBackground;
  /// Valfri full-bleed bakgrund (t.ex. bild) som fyller hela skärmen.
  final Widget? background;
  /// Låt innehållet/bakgrunden gå bakom appbaren (för herosidor).
  final bool extendBodyBehindAppBar;
  /// Gör appbaren helt transparent (använd tillsammans med `extendBodyBehindAppBar`).
  final bool transparentAppBar;
  /// Valfri färg för appbarens ikon/text (annars beräknas från temat).
  final Color? appBarForegroundColor;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.disableBack = false,
    this.neutralBackground = false,
    this.background,
    this.extendBodyBehindAppBar = false,
    this.transparentAppBar = false,
    this.appBarForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final canPop = router.canPop();
    final showBack = !disableBack;
    final cs = Theme.of(context).colorScheme;

    final fg = appBarForegroundColor ??
        (transparentAppBar ? Colors.white : Theme.of(context).colorScheme.onSurface);

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: AppBar(
        backgroundColor: transparentAppBar
            ? Colors.transparent
            : Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: fg,
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
          // Bakgrund
          Positioned.fill(
            child: neutralBackground
                ? Container(color: const Color(0xFFFFFFFF))
                : (background ?? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(0.04),
                          Colors.transparent,
                          cs.secondary.withOpacity(0.03),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  )),
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

/// Full-bleed bakgrund med bild i cover-läge och en subtil gradient för läsbarhet.
class FullBleedBackground extends StatelessWidget {
  final Widget child;
  final ImageProvider image;
  final Alignment alignment;
  final double topOpacity;
  final double bottomOpacity;
  /// Positivt värde flyttar bilden nedåt (px). Använd för parallax.
  final double yOffset;
  /// Skala upp bilden något för att undvika ev. inbyggda kanter i asseten.
  final double scale;
  /// Vignette från sidorna (0.0–1.0). 0 = av.
  final double sideVignette;
  const FullBleedBackground({
    super.key,
    required this.child,
    required this.image,
    this.alignment = Alignment.center,
    this.topOpacity = 0.20,
    this.bottomOpacity = 0.45,
    this.yOffset = 0,
    this.scale = 1.0,
    this.sideVignette = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid svart bas så att inga vita kanter någonsin "lyser igenom" bakom bilden
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, yOffset),
            child: Transform.scale(
              scale: scale,
              alignment: alignment,
              child: Image(
                image: image,
                fit: BoxFit.cover,
                alignment: alignment,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(topOpacity),
                  Colors.black.withOpacity(bottomOpacity),
                ],
              ),
            ),
          ),
        ),
        if (sideVignette > 0)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(sideVignette),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(sideVignette),
                  ],
                  stops: const [0.0, 0.15, 0.85, 1.0],
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
