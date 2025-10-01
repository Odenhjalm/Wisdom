import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0, bottom: 12.0),
        child: Image.asset(
          'assets/loggo_clea.png',
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          cacheWidth: (size * devicePixelRatio).round(),
        ),
      ),
    );
  }
}
