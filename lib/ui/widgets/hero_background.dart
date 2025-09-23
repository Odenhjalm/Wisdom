import 'package:flutter/material.dart';

/// Fullscreen bakgrundsbild med mjuk gradient för bättre läsbarhet.
class HeroBackground extends StatelessWidget {
  final String asset;
  final Alignment alignment;
  final double opacity;
  const HeroBackground({
    super.key,
    required this.asset,
    this.alignment = Alignment.center,
    this.opacity = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover, alignment: alignment),
        // Subtil mörk gradient för att text/widgets ligger tydligt ovanpå
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.20 * opacity),
                Colors.black.withValues(alpha: 0.45 * opacity),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
