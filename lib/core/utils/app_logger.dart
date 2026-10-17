import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized Colorful ANSI Logger for Roots Classes App
/// Prints vibrant, formatted, and readable ANSI-colored logs in the terminal.
class AppLogger {
  AppLogger._();

  static const String _defaultTag = 'RootsClasses';

  // ANSI Escape Codes for Terminal Colors
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  // Standard Foreground Colors
  static const String _red = '\x1B[31m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  // High-Intensity / Bright Foreground Colors
  static const String _brightRed = '\x1B[91m';
  static const String _brightGreen = '\x1B[92m';
  static const String _brightYellow = '\x1B[93m';
  static const String _brightBlue = '\x1B[94m';
  static const String _brightMagenta = '\x1B[95m';
  static const String _brightCyan = '\x1B[96m';
  static const String _brightWhite = '\x1B[97m';

  /// Informational log (Bright Cyan)
  static void i(String message, {String tag = _defaultTag}) {
    if (!kDebugMode) return;
    final formatted = '$_brightCyan💡 [INFO]$_reset $_bold[$tag]$_reset $_cyan$message$_reset';
    developer.log(message, name: tag);
    debugPrint(formatted);
  }

  /// Debug log (Bright Blue)
  static void d(String message, {String tag = _defaultTag}) {
    if (!kDebugMode) return;
    final formatted = '$_brightBlue🔍 [DEBUG]$_reset $_bold[$tag]$_reset $_blue$message$_reset';
    developer.log(message, name: tag);
    debugPrint(formatted);
  }

  /// Warning log (Bright Yellow)
  static void w(String message, {String tag = _defaultTag}) {
    if (!kDebugMode) return;
    final formatted = '$_brightYellow⚠️  [WARN]$_reset $_bold[$tag]$_reset $_brightYellow$message$_reset';
    developer.log(message, name: tag);
    debugPrint(formatted);
  }

  /// Error log (Bright Red + StackTrace)
  static void e(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    final buffer = StringBuffer('$_brightRed🚨 [ERROR]$_reset $_bold[$tag]$_reset $_brightRed$message$_reset');
    if (error != null) {
      buffer.write(' $_dim|$_reset $_bold$_red Error: $error$_reset');
    }
    developer.log(
      buffer.toString(),
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint(buffer.toString());
    if (stackTrace != null) {
      debugPrint('$_dim$stackTrace$_reset');
    }
  }

  /// Success log (Bright Green)
  static void s(String message, {String tag = _defaultTag}) {
    if (!kDebugMode) return;
    final formatted = '$_brightGreen✅ [SUCCESS]$_reset $_bold[$tag]$_reset $_brightGreen$message$_reset';
    developer.log(message, name: tag);
    debugPrint(formatted);
  }

  /// Log outgoing HTTP Request (Vibrant Magenta / Cyan Box)
  static void logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;
    final logText = StringBuffer();
    logText.writeln('$_brightMagenta┌─────────────────────────── 🚀 HTTP REQUEST ───────────────────────────┐$_reset');
    logText.writeln('$_brightMagenta│$_reset ➡️  $_bold$_brightYellow$method$_reset $_brightCyan$uri$_reset');
    if (headers != null && headers.isNotEmpty) {
      logText.writeln('$_brightMagenta├───────────────────────────────────────────────────────────────────────┤$_reset');
      logText.writeln('$_brightMagenta│$_reset $_dim Headers:$_reset $_white$headers$_reset');
    }
    if (body != null) {
      logText.writeln('$_brightMagenta├───────────────────────────────────────────────────────────────────────┤$_reset');
      final formattedBody = _prettyJson(body);
      logText.writeln('$_brightMagenta│$_reset $_dim Body:$_reset\n$formattedBody');
    }
    logText.write('$_brightMagenta└───────────────────────────────────────────────────────────────────────┘$_reset');
    debugPrint(logText.toString());
  }

  /// Log incoming HTTP Response (Vibrant Green for Success, Red for Errors)
  static void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required Duration duration,
    dynamic body,
  }) {
    if (!kDebugMode) return;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final borderColor = isSuccess ? _brightGreen : _brightRed;
    final statusColor = isSuccess ? '$_bold$_brightGreen' : '$_bold$_brightRed';
    final icon = isSuccess ? '✅' : '❌';
    final durationStr = '${duration.inMilliseconds}ms';

    final logText = StringBuffer();
    logText.writeln('$borderColor┌─────────────────────────── $icon HTTP RESPONSE ──────────────────────────┐$_reset');
    logText.writeln('$borderColor│$_reset ⬅️  [$statusColor$statusCode$_reset] $_bold$_brightYellow$method$_reset $_brightCyan$uri$_reset $borderColor($durationStr)$_reset');
    if (body != null) {
      logText.writeln('$borderColor├───────────────────────────────────────────────────────────────────────┤$_reset');
      final formattedBody = _prettyJson(body);
      logText.writeln('$borderColor│$_reset $_dim Response:$_reset\n$formattedBody');
    }
    logText.write('$borderColor└───────────────────────────────────────────────────────────────────────┘$_reset');
    debugPrint(logText.toString());
  }

  /// Log HTTP Network / Client Error (Bright Red Box)
  static void logHttpError({
    required String method,
    required Uri uri,
    required Object error,
  }) {
    if (!kDebugMode) return;
    final logText = StringBuffer();
    logText.writeln('$_brightRed┌─────────────────────────── 🚨 HTTP FAILURE ───────────────────────────┐$_reset');
    logText.writeln('$_brightRed│$_reset ❌ $_bold$_brightYellow$method$_reset $_brightCyan$uri$_reset');
    logText.writeln('$_brightRed│$_reset ⚠️ $_bold$_brightRed Error: $error$_reset');
    logText.write('$_brightRed└───────────────────────────────────────────────────────────────────────┘$_reset');
    debugPrint(logText.toString());
  }

  /// App Startup Banner (Stunning ASCII art banner in terminal)
  static void printStartupBanner() {
    if (!kDebugMode) return;
    debugPrint('''
$_brightCyan╔═══════════════════════════════════════════════════════════════════════╗$_reset
$_brightCyan║$_bold$_brightYellow   ____   ____   ____ _____ ____     ____ _        _    ____ ____  _____ ____  $_reset$_brightCyan║$_reset
$_brightCyan║$_bold$_brightYellow  |  _ \\ / __ \\ / __ \\_   _/ ___|   / ___| |      / \\  / ___/ ___|| ____/ ___| $_reset$_brightCyan║$_reset
$_brightCyan║$_bold$_brightYellow  | |_) | |  | | |  | || | \\___ \\  | |   | |     / _ \\ \\___ \\___ \\|  _| \\___ \\  $_reset$_brightCyan║$_reset
$_brightCyan║$_bold$_brightYellow  |  _ <| |__| | |__| || |  ___) | | |___| |___ / ___ \\ ___) |__) | |___ ___) | $_reset$_brightCyan║$_reset
$_brightCyan║$_bold$_brightYellow  |_| \\_\\\\____/ \\____/ |_| |____/   \\____|_____/_/   \\_\\____/____/|_____|____/  $_reset$_brightCyan║$_reset
$_brightCyan║                                                                       ║$_reset
$_brightCyan║  $_brightGreen🌱 Roots Classes EduTech Platform • Ludhiana, Punjab$_reset                  $_brightCyan║$_reset
$_brightCyan║  $_brightWhite🌐 Local Base URL: http://localhost:5050$_reset                             $_brightCyan║$_reset
$_brightCyan╚═══════════════════════════════════════════════════════════════════════╝$_reset
''');
  }

  static String _prettyJson(dynamic json) {
    if (json == null) return 'null';
    try {
      if (json is String) {
        if (json.trim().startsWith('{') || json.trim().startsWith('[')) {
          final decoded = jsonDecode(json);
          const encoder = JsonEncoder.withIndent('  ');
          return encoder.convert(decoded);
        }
        return json;
      }
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (_) {
      return json.toString();
    }
  }
}
