import 'package:flutter/material.dart';

/// Simple helper for rendering text with the Wisdom gradient palette.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.style,
    this.gradient,
    super.key,
  });

  final String text;
  final TextStyle style;
  final Gradient? gradient;

  static const Gradient _defaultGradient = LinearGradient(
    colors: [Color(0xFF9B8CFF), Color(0xFF4FC3F7)],
  );

  @override
  Widget build(BuildContext context) {
    final resolvedGradient = gradient ?? _defaultGradient;
    return ShaderMask(
      shaderCallback: (bounds) => resolvedGradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
