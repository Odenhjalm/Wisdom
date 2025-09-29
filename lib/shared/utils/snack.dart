import 'package:flutter/material.dart';

import 'package:wisdom/shared/utils/context_safe.dart';

void showSnack(
  BuildContext context,
  String message, {
  Color? backgroundColor,
}) {
  context.ifMounted((c) {
    final messenger = ScaffoldMessenger.of(c);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
  });
}
