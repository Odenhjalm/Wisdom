import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// High-level error classification used across repositories and providers.
enum AppFailureKind {
  network,
  unauthorized,
  notFound,
  validation,
  timeout,
  server,
  configuration,
  unexpected,
}

sealed class AppFailure implements Exception {
  const AppFailure({
    required this.kind,
    required this.message,
    this.code,
    this.original,
    this.stackTrace,
  });

  final AppFailureKind kind;
  final String message;
  final String? code;
  final Object? original;
  final StackTrace? stackTrace;

  factory AppFailure.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) return error;

    if (error is TimeoutException) {
      return TimeoutFailure(
        message: 'Tidsgränsen överskreds. Kontrollera din uppkoppling och försök igen.',
        original: error,
        stackTrace: stackTrace,
      );
    }

    if (_looksLikeConfigError(error)) {
      return ConfigurationFailure(
        message: 'Supabase är inte korrekt konfigurerat.',
        original: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PostgrestException) {
      return _fromPostgrest(error, stackTrace);
    }

    if (error is AuthException) {
      final status = int.tryParse(error.statusCode ?? '') ?? 400;
      if (status == 401 || status == 403) {
        return UnauthorizedFailure(
          message: error.message,
          code: error.code,
          original: error,
          stackTrace: stackTrace,
        );
      }
      return ValidationFailure(
        message: error.message,
        code: error.code,
        original: error,
        stackTrace: stackTrace,
      );
    }

    if (error is StorageException) {
      final status = error.statusCode ?? 500;
      if (status == 404) {
        return NotFoundFailure(
          message: error.message,
          code: error.error,
          original: error,
          stackTrace: stackTrace,
        );
      }
      if (status == 401 || status == 403) {
        return UnauthorizedFailure(
          message: error.message,
          code: error.error,
          original: error,
          stackTrace: stackTrace,
        );
      }
      return ServerFailure(
        message: error.message,
        code: error.error,
        original: error,
        stackTrace: stackTrace,
      );
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Realtime') || typeName.contains('Function')) {
      return ServerFailure(
        message: error.toString(),
        original: error,
        stackTrace: stackTrace,
      );
    }

    if (_looksLikeNetworkIssue(error)) {
      return NetworkFailure(
        message: 'Kunde inte nå servern. Försök igen.',
        original: error,
        stackTrace: stackTrace,
      );
    }

    return UnexpectedFailure(
      message: error.toString(),
      original: error,
      stackTrace: stackTrace,
    );
  }

  static AppFailure _fromPostgrest(
    PostgrestException error,
    StackTrace? stackTrace,
  ) {
    final status = _tryParseStatus(error.code);
    if (status == 404) {
      return NotFoundFailure(
        message: error.message,
        code: error.code,
        original: error,
        stackTrace: stackTrace,
      );
    }
    if (status == 401 || status == 403) {
      return UnauthorizedFailure(
        message: error.message,
        code: error.code,
        original: error,
        stackTrace: stackTrace,
      );
    }
    if (status != null && status >= 400 && status < 500) {
      return ValidationFailure(
        message: error.message,
        code: error.code,
        original: error,
        stackTrace: stackTrace,
      );
    }
    if (_looksLikeNetworkIssue(error)) {
      return NetworkFailure(
        message: 'Kunde inte nå databasen. Försök igen.',
        code: error.code,
        original: error,
        stackTrace: stackTrace,
      );
    }
    return ServerFailure(
      message: error.message,
      code: error.code,
      original: error,
      stackTrace: stackTrace,
    );
  }

  static int? _tryParseStatus(String? code) {
    if (code == null) return null;
    final maybeInt = int.tryParse(code);
    if (maybeInt != null) return maybeInt;
    final digits = RegExp(r'\d+').firstMatch(code)?.group(0);
    return digits == null ? null : int.tryParse(digits);
  }

  static bool _looksLikeConfigError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('supabase') &&
        (text.contains('init') || text.contains('configure')) &&
        text.contains('saknas');
  }

  static bool _looksLikeNetworkIssue(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable');
  }

  @override
  String toString() => 'AppFailure(kind: $kind, message: $message, code: $code)';
}

class NetworkFailure extends AppFailure {
  NetworkFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.network);
}

class UnauthorizedFailure extends AppFailure {
  UnauthorizedFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.unauthorized);
}

class NotFoundFailure extends AppFailure {
  NotFoundFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.notFound);
}

class ValidationFailure extends AppFailure {
  ValidationFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.validation);
}

class TimeoutFailure extends AppFailure {
  TimeoutFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.timeout);
}

class ServerFailure extends AppFailure {
  ServerFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.server);
}

class ConfigurationFailure extends AppFailure {
  ConfigurationFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.configuration);
}

class UnexpectedFailure extends AppFailure {
  UnexpectedFailure({
    required super.message,
    super.code,
    super.original,
    super.stackTrace,
  }) : super(kind: AppFailureKind.unexpected);
}
