import 'package:flutter/material.dart';

/// Safe helper to use BuildContext after async gaps.
extension ContextMountedX on BuildContext {
  /// Runs [fn] only if the context is still mounted.
  T? ifMounted<T>(T Function(BuildContext c) fn) {
    final isMounted = Navigator.maybeOf(this)?.context.mounted ?? true;
    if (!isMounted) return null;
    return fn(this);
  }
}
