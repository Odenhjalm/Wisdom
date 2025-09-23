import 'package:flutter/material.dart';

/// Full-viewport background image with a soft, readable overlay.
/// - Always covers the entire available space (desktop/web/mobile)
/// - Low-opacity white/mint gradient for text readability
/// - Does not capture gestures (content above remains interactive)
class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid backdrop so no white tone shines through around the image edges.
        const ColoredBox(color: Colors.black),
        // Base image covers entire viewport
        IgnorePointer(
          child: Transform.scale(
            scale: 1.05,
            child: Image.asset(
              'assets/images/bakgrund.png',
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        // Soft vertical overlay with a hint of mint
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.20),
                    const Color(0xFF22C55E).withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Utility wrapper that paints the shared background behind `child`.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const BackgroundLayer(),
        child,
      ],
    );
  }
}
