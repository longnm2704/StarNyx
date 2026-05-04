import 'package:flutter/foundation.dart';

/// Small logging abstraction so debug traces stay injectable and testable.
abstract interface class AppLogService {
  void debug(String tag, String message);

  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

class NoOpAppLogService implements AppLogService {
  const NoOpAppLogService();

  @override
  void debug(String tag, String message) {}

  @override
  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

class ConsoleAppLogService implements AppLogService {
  const ConsoleAppLogService();

  @override
  void debug(String tag, String message) {
    if (kReleaseMode) {
      return;
    }

    debugPrint(_format(tag, message));
  }

  @override
  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) {
      return;
    }

    debugPrint(_format(tag, message));
    if (error != null) {
      debugPrint(_format(tag, 'error: $error'));
    }
    if (stackTrace != null) {
      debugPrint(_format(tag, 'stackTrace:\n$stackTrace'));
    }
  }

  String _format(String tag, String message) {
    return '[${DateTime.now().toIso8601String()}][$tag] $message';
  }
}
