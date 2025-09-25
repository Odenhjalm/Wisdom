import 'package:flutter/material.dart';

class GradientTextSpan extends WidgetSpan {
  GradientTextSpan({
    required String text,
    required Gradient gradient,
    TextStyle? style,
  }) : super(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _GradientText(
            text: text,
            gradient: gradient,
            style: style,
          ),
        );
}

class _GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? style;

  const _GradientText({required this.text, required this.gradient, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: baseStyle),
    );
  }
}
