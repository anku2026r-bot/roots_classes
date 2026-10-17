import 'package:flutter/material.dart';

/// Central bulletproof navigation utility that handles:
/// 1. Rapid multiple click debounce protection
/// 2. Duplicate page navigation prevention (does not push if same page is already open)
/// 3. Consistent MaterialPageRoute transitions
class AppNavigator {
  AppNavigator._();

  static DateTime _lastNavigationTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _debounceThresholdMs = 180;
  static String? _currentRouteType;

  /// Safely pushes a new page, preventing rapid double taps and duplicate pushes
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    bool allowDuplicate = false,
  }) async {
    final now = DateTime.now();
    if (now.difference(_lastNavigationTime).inMilliseconds < _debounceThresholdMs) {
      return null;
    }

    final targetType = page.runtimeType.toString();
    if (!allowDuplicate && _currentRouteType == targetType) {
      return null;
    }

    _lastNavigationTime = now;
    final previousType = _currentRouteType;
    _currentRouteType = targetType;

    try {
      final result = await Navigator.push<T>(
        context,
        MaterialPageRoute<T>(
          builder: (_) => page,
          settings: RouteSettings(name: targetType),
        ),
      );
      return result;
    } finally {
      _currentRouteType = previousType;
    }
  }

  /// Replaces the current route with a new page
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page,
  ) async {
    final now = DateTime.now();
    if (now.difference(_lastNavigationTime).inMilliseconds < _debounceThresholdMs) {
      return null;
    }
    _lastNavigationTime = now;
    final targetType = page.runtimeType.toString();
    _currentRouteType = targetType;

    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: RouteSettings(name: targetType),
      ),
    );
  }

  /// Clears navigation stack and opens root page
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
  ) async {
    _lastNavigationTime = DateTime.now();
    final targetType = page.runtimeType.toString();
    _currentRouteType = targetType;

    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: RouteSettings(name: targetType),
      ),
      (route) => false,
    );
  }

  /// Safely pops the current screen if possible
  static void pop<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }
}
