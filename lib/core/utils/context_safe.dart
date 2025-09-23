import 'package:flutter/material.dart';

extension ContextSafeNav on BuildContext {
  bool get _mounted => mounted;

  Future<T?> pushSafe<T>(Route<T> route) async {
    if (!_mounted) return null;
    return Navigator.of(this).push(route);
  }

  void popSafe<T extends Object?>([T? result]) {
    if (!_mounted) return;
    final navigator = Navigator.of(this);
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  void goSnack(String message) {
    if (!_mounted) return;
    final messenger = ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
