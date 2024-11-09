import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  d,
  w,
  e,
}

typedef LogPrinter = void Function(LogItem item);

class Log {
  static final List<LogPrinter> _logPrinters = [];

  // static final FileLogger _fileLogger =
  //     (kIsWeb || isTesting) ? WebFileLogger() : RealFileLogger();
  static const _mainIsolateName = 'main';
  static const _webIsolateName = 'web';
  static bool remotePrintLogsEnabled = false;
  static bool devPrintLogsEnabled = false;

  static void addLogPrinter(LogPrinter logPrinter) {
    _logPrinters.add(logPrinter);
  }

  static void d(String tag, Object? message) {
    log(LogLevel.d, tag, message);
  }

  static void w(String tag, Object? message) {
    log(LogLevel.w, tag, message);
  }

  static void e(String tag, Object? message, {StackTrace? stackTrace}) {
    log(LogLevel.e, tag, message, stackTrace: stackTrace);
  }

  static void log(
    LogLevel level,
    String tag,
    Object? message, {
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now();
    final isolateName = kIsWeb ? _webIsolateName : Isolate.current.debugName;

    final logItem = LogItem(
      level: level,
      date: now,
      tag: tag,
      message: '$message',
      isolateName: isolateName,
      stackTrace: stackTrace,
    );

    for (final logPrinter in _logPrinters) {
      logPrinter(logItem);
    }

    debugPrint('$logItem');

    // Print logs only from the main isolate or in web
    // if (isolateName == _mainIsolateName || isolateName == _webIsolateName) {
    //   _fileLogger.print(logItem);
    // }
  }

  /// Get all available logs
// static Future<List<String>> getLogs({String? filePath}) =>
//     _fileLogger.getLogs(filePath: filePath);
//
  /// Get log file
// static Future<File> getLogFile({String? filePath}) =>
//     _fileLogger.getLogFile(filePath: filePath);

// static Future<List<File>> getLogFiles() => _fileLogger.getLogFiles();

  /// Get all logs as a single string
// static Future<String> logsToString() => getLogs().then((it) => it.join('\n'));
}

/// Log item model
class LogItem {
  LogItem({
    required this.level,
    required this.date,
    required this.tag,
    required this.message,
    required this.isolateName,
    this.stackTrace,
  });

  static const _dateFormatString = 'dd-MM-yyyy–HH:mm:ss:ms';
  static final _dateFormat = DateFormat(_dateFormatString);

  /// Log level
  final LogLevel level;

  /// Event date
  final DateTime date;

  /// The tag of the class in which the event occurred
  final String tag;

  /// Message
  final String message;

  /// The isolate in which the event occurred
  final String? isolateName;

  /// Error stackTrace
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result =
        '${level.name.toUpperCase()}/${_dateFormat.format(date)} [$isolateName] $tag: $message';
    if (stackTrace != null) {
      result += '\n$stackTrace';
    }
    return result;
  }
}
