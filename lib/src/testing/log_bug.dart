import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/*
Learn more: https://pub.dev/packages/logger

NOTE:
tag is for function which want to trace.
E.g: tag:  "saveFile"
flag is for flow which want to trace.
E.g: flag: "Bluetooth"

 */


// For release
// Learn more: https://stackoverflow.com/a/77970691
class PermissiveFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class MyLog {
  bool isLogging = true;

  Logger logger = Logger(
    filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 3,
      printEmojis: false,
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  // #TESTED
  Future<void> setUp({
    String? path,
    bool printTime = true,
    bool isLogging = true,
    String? noteInfoFileLog,
  }) async {
    if (this.isLogging != isLogging) this.isLogging = isLogging;
    if (path != null) {
      /// STEP 1 | Write noteInfoFileLog
      final file = File(path);
      if (noteInfoFileLog != null) {
        await file.writeAsString(
          noteInfoFileLog,
          mode: FileMode.writeOnlyAppend,
        );
      }

      /// STEP 2 | Write log
      final FileOutput2 fileOutPut = FileOutput2(
        // overrideExisting: true,
        file: file,
      );
      final ConsoleOutput consoleOutput = ConsoleOutput();
      final List<LogOutput> multiOutput = [fileOutPut, consoleOutput];
      logger = Logger(
        printer: PrettyPrinter(
          methodCount: 3,
          errorMethodCount: 12,
          lineLength: 150,
          // colors: false,
          printEmojis: false,
          printTime: printTime, // Should each log print contain a timestamp
        ),
        filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
        // Use the PrettyPrinter to format and print log
        output: MultiOutput(
          multiOutput,
        ), // Use the default LogOutput (-> send everything to console)
      );
    } else {
      logger = Logger(
        printer: PrettyPrinter(
          methodCount: 3,
          errorMethodCount: 12,
          lineLength: 150,
          printEmojis: false,
          printTime: printTime, // Should each log print contain a timestamp
        ),
        filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
      );
    }
  }

  /// Level 1: truy vết
  void trace(Object? object, {String? tag, String? flag, Object? error}) {
    if (kDebugMode || isLogging) {
      logger.t(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: error,
      );
    }
  }

  /// Level 2: truy vết debug
  void debug(Object? object, {String? tag, String? flag, Object? error}) {
    if (kDebugMode || isLogging) {
      logger.d(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: error,
      );
    }
  }

  /// Level 3: lấy thông tin
  void info(Object? object, {String? tag, String? flag, Object? error}) {
    if (kDebugMode || isLogging) {
      logger.i(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: error,
      );
    }
  }

  /// Level 4: tạo cảnh báo
  void warning(Object? object, {String? tag, String? flag, Object? error}) {
    if (kDebugMode || isLogging) {
      logger.w(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: error,
      );
    }
  }

  /// Level 5: Lỗi
  void error(
    Object? object, {
    String? tag,
    String? flag,
  }) {
    if (kDebugMode || isLogging) {
      logger.e(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: object,
      );
    }
  }

  /// Level 6: Lỗi nghiêm trọng
  void fatal(Object? object, {String? tag, String? flag, required Object error, StackTrace? stackTrace}) {
    if (kDebugMode || isLogging) {
      logger.f(
        _print(
          object,
          tag: tag ?? _getParentMethodName(),
          flag: flag,
        ),
        time: DateTime.now(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

String? _getParentMethodName() {
  try {
    throw Exception();
  } catch (e, stackTrace) {
    final frames = stackTrace.toString().split('\n');

    var father = "";
    var grandfather = "";

    try {
      final fatherFrame = frames[3];
      father = fatherFrame.split(' ').last;
    } catch (_) {}
    try {
      final grandfatherFrame = frames[4];
      grandfather = grandfatherFrame.split(' ').last;
    } catch (_) {}

    return father == "" && grandfather == "" ? null : "$father${grandfather == "" ? grandfather : "\n$grandfather"}\n";
  }
}

String? myFucGetParentMethodName() {
  try {
    throw Exception();
  } catch (e, stackTrace) {
    final frames = stackTrace.toString().split('\n');

    var father = "";
    var grandfather = "";

    try {
      final fatherFrame = frames[2];
      father = fatherFrame.split(' ').last;
    } catch (_) {}
    try {
      final grandfatherFrame = frames[3];
      grandfather = grandfatherFrame.split(' ').last;
    } catch (_) {}

    return father == "" && grandfather == "" ? null : "$father${grandfather == "" ? grandfather : " - $grandfather"}";
  }
}

String _print(
  Object? object, {
  String? tag,
  String? flag,
}) =>
    (tag == null || tag == "") && (flag == null || flag == "")
        ? object.toString()
        : tag != null && tag != "" && flag != null && flag != ""
            ? "$tag | ${flag.toUpperCase()} | $object"
            : (tag == null || tag == "") && flag != null && flag != ""
                ? "${flag.toUpperCase()} | $object"
                : "$tag | $object";

/// Writes the log output to a file.
/// Learn more: https://stackoverflow.com/a/66374780
class FileOutput2 extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  late IOSink _sink;

  // IOSink? _sink;

  FileOutput2({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  @override
  Future<void> init() async {
    _sink = file.openWrite(
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: encoding,
    );
  }

  @override
  void output(OutputEvent event) {
    // myPrint("aaa ${event.lines.map((e) => e.replaceAll('â', "").replaceAll('"', "").replaceAll("€", "")).toList()}");
    // _sink.writeAll(event.lines.map((e) => e.replaceAll('â', "").replaceAll('"', "").replaceAll("€", "")).toList(), '\n');
    // myPrint("event.origin.message");
    // myPrint(event.origin.message);
    try {
      if (event.origin.level != Level.trace) _sink.writeAll(["${event.origin.level.name} | ${event.origin.time} | ${event.origin.error} \n${event.origin.message} \n\n"], '\n');
    } catch (e) {
      print(e);
    }

    // _sink.writeAll(event.lines, '\n');
  }

  @override
  Future<void> destroy() async {
    await _sink.flush();
    await _sink.close();
  }
}

void myDebugger(Object? object, {String? tag, String? flag, bool when = true}) {
  developer.debugger(
    when: when,
    message: _print(
      object,
      tag: tag ?? _getParentMethodName(),
      flag: flag,
    ),
  );
}
