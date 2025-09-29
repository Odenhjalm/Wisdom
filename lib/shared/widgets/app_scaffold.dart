import 'package:flutter/material.dart';

import 'go_router_back_button.dart';

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
    final theme = Theme.of(context);
    final showBack = !disableBack;
    final useTransparentAppBar = transparentAppBar || !neutralBackground;
    final appBarColor = useTransparentAppBar
        ? Colors.transparent
        : theme.scaffoldBackgroundColor;
    final fg = appBarForegroundColor ?? theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: AppBar(
        backgroundColor: appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: fg,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        flexibleSpace:
            background != null ? IgnorePointer(child: background!) : null,
        leading: showBack ? const GoRouterBackButton() : null,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          if (neutralBackground)
            const Positioned.fill(
              child: ColoredBox(color: Color(0xFFFFFFFF)),
            )
          else if (background != null)
            Positioned.fill(child: background!),
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

/// Full-bleed bakgrund i cover-läge med mjuk toppscrim (och valfri varm overlay).
class FullBleedBackground extends StatelessWidget {
  final Widget child;
  final ImageProvider image;
  final Alignment alignment;
  final double topOpacity;

  /// Positivt värde flyttar bilden nedåt (px). Använd för parallax.
  final double yOffset;

  /// Skala upp bilden något för att undvika ev. inbyggda kanter i asseten.
  final double scale;

  /// Vignette från sidorna (0.0–1.0). 0 = av.
  final double sideVignette;
  final Color? overlayColor;
  final List<Color>? scrimColors;
  final List<double>? scrimStops;
  const FullBleedBackground({
    super.key,
    required this.child,
    required this.image,
    this.alignment = Alignment.center,
    this.topOpacity = 0.26,
    this.yOffset = 0,
    this.scale = 1.0,
    this.sideVignette = 0.0,
    this.overlayColor,
    this.scrimColors,
    this.scrimStops,
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
                colors: scrimColors ??
                    [
                      Colors.black.withValues(alpha: topOpacity),
                      Colors.transparent,
                    ],
                stops: scrimStops ?? const [0.0, 0.25],
              ),
            ),
          ),
        ),
        if (overlayColor != null)
          Positioned.fill(
            child: ColoredBox(color: overlayColor!),
          ),
        if (sideVignette > 0)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: sideVignette),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: sideVignette),
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
