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

/// `myPrint` is a utility function for printing messages to the console.
///
/// It is intended for general-purpose logging and debugging during development.
/// It only prints if the `enviIsDevelop` flag is true.
///
/// Parameters:
///   - `object`: The object to print.
///   - `tag`: An optional tag to include in the message.
///   - `flag`: An optional flag to include in the message.
///
/// Level 0: NOT important information.
void myPrint(
  Object? object, {
  String? tag,
  String? flag,
}) {
  print(
    _print(
      object,
      tag: tag ?? _getParentMethodName(),
      flag: flag,
    ),
  );
}

/// `myDebugPrint` is a utility function for printing messages to the debug console.
///
/// It uses Flutter's `debugPrint` function, which is optimized for debugging
/// and may handle large messages more efficiently.
///
/// Parameters:
///   - `object`: The object to print.
///   - `tag`: An optional tag to include in the message.
///   - `flag`: An optional flag to include in the message.
void myDebugPrint(
  Object? object, {
  String? tag,
  String? flag,
}) {
  debugPrint(
    _print(
      object,
      tag: tag ?? _getParentMethodName(),
      flag: flag,
    ),
  );
}

/// `myWriteln` is a utility function for writing messages to the standard error stream.
///
/// It is typically used for error messages or other important information that
/// should be displayed even if the standard output stream is redirected.
///
/// Parameters:
///   - `object`: The object to write.
///   - `tag`: An optional tag to include in the message.
///   - `flag`: An optional flag to include in the message.
void myWriteln(
  Object? object, {
  String? tag,
  String? flag,
}) {
  stderr.writeln(
    _print(
      object,
      tag: tag ?? _getParentMethodName(),
      flag: flag,
    ),
  );
}

/// `myLogDev` is a utility function for logging messages using the Dart developer log.
///
/// It is used for more structured logging and can be used to send log messages
/// to external tools or services.
///
/// Parameters:
///   - `object`: The object to log.
///   - `tag`: An optional tag to include in the message.
///   - `flag`: An optional flag to include in the message.
void myLogDev(
  Object? object, {
  String? tag,
  String? flag,
}) {
  developer.log(
    _print(
      object,
      tag: tag ?? _getParentMethodName(),
      flag: flag,
    ),
    name: tag ?? "",
    error: jsonEncode(object),
  );
}

// For release
// Learn more: https://stackoverflow.com/a/77970691
/// `PermissiveFilter` is a [LogFilter] that allows all log events topass through.
///
/// It is used when you want to log every event without any filtering.
/// This filter is useful for debugging or when you need to capture all log
/// messages for analysis.
class PermissiveFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

/// `MyLog` is a utility class for managing logging within the application.
///
/// It provides a centralized way to configure and use the [Logger] from the
/// `logging` package. It allows you to control whether logging is enabled
/// and to setup a custom log filter.
///
/// This class is designed to simplify the process of logging and to provide
/// a consistent logging mechanism throughout the application.
class MyLog {
  /// Indicates whether logging is currently enabled.
  ///
  /// If `true`, log events will be processed. If `false`, log events will be ignored.
  bool isLogging = true;

  /// The [Logger] instance used for logging.
  ///
  /// This logger is configured with a [PermissiveFilter] to allow all log events.
  Logger logger = Logger(
    filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
    printer: PrettyPrinter(
        methodCount: 3,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat
            .dateAndTime // Should each log print contain a timestamp
        ),
  );

  // #TESTED
  /// Setsup the logging environment.
  ///
  /// This method can be used to perform any asynchronous setup tasks
  /// related to logging. Currently, it does not perform any asynchronous
  /// operations, but it is designed to be extended in the future if needed.
  ///
  /// Returns a [Future] that completes when the setup is finished.
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
            dateTimeFormat:
                printTime ? DateTimeFormat.dateAndTime : DateTimeFormat.none
            // printTime: printTime, // Should each log print contain a timestamp
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
            dateTimeFormat: printTime
                ? DateTimeFormat.dateAndTime
                : DateTimeFormat
                    .none // Should each log print contain a timestamp
            ),
        filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
      );
    }
  }

  /// Level 1: trace truy vết
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

  /// Level 2: debug truy vết debug
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

  /// Level 3: info lấy thông tin
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

  /// Level 4: warning tạo cảnh báo
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

  /// Level 5: error Lỗi
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

  /// Level 6: fatal Lỗi nghiêm trọng
  void fatal(Object? object,
      {String? tag,
      String? flag,
      required Object error,
      StackTrace? stackTrace}) {
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

    return father == "" && grandfather == ""
        ? null
        : "$father${grandfather == "" ? grandfather : "\n$grandfather"}\n";
  }
}

/// `myFucGetParentMethodName` is a utility function that attempts to determine the name of the calling method (parent method) andits grandparent method from the current stack trace.
///
/// This function is useful for debugging or logging purposes when you need to know
/// the context from which a particular function was called.
///
/// It works by throwing an exception to capture the current stack trace, then
/// parsing the stack trace stringto extract the method names.
///
/// Note: This function relies on the format of the stack trace, which may vary
/// between Dart versions or platforms. Therefore, it should be used with caution
/// and may need to be adjusted if the stack trace format changes.
///
/// Returns:
///   - A string containing the parent method name and optionally the grandparent
///     method name, separated by " - ".
///   - `null` if neither the parent nor grandparent method names could be determined.
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

    return father == "" && grandfather == ""
        ? null
        : "$father${grandfather == "" ? grandfather : " - $grandfather"}";
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
/// `FileOutput2` is a [LogOutput] implementation that writes log messages to a file.
///
/// It allows you to persist log data to a file for later analysis or debugging.
/// You can configure whether to override an existing file or append to it, and
/// you can specify the encoding to use when writingto the file.
///
/// This class is useful for applications that need to maintain a persistent log
/// of their activity, especially in scenarios where console output is not
/// sufficient or available.
///
/// Learn more: https://stackoverflow.com/a/66374780
class FileOutput2 extends LogOutput {
  /// The file to write log messages to.
  final File file;

  /// Determines whether to override an existing file.
  ///
  /// If `true`, the file will be overwritten. If `false`, new log messages will
  /// be appended to the end of the file. Defaults to `false`.
  final bool overrideExisting;

  /// The encoding to use when writing to the file.
  ///
  /// Defaults to [utf8].
  final Encoding encoding;

  /// The [IOSink] used to write to the file.
  ///
  /// This is initialized in the constructor.
  late IOSink _sink;

  /// Creates a [FileOutput2] instance.
  ///
  /// [file] is the file to write log messages to.
  /// [overrideExisting] determines whether to override an existing file.
  /// [encoding] is the encoding to usewhen writing to the file.
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
    try {
      if (event.origin.level != Level.trace) {
        _sink.writeAll([
          "${event.origin.level.name} | ${event.origin.time} | ${event.origin.error} \n${event.origin.message} \n\n"
        ], '\n');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> destroy() async {
    await _sink.flush();
    await _sink.close();
  }
}

/// `myDebugger` is a utility function for debugging that conditionally triggers the Dart debugger and printsa formatted message.
///
/// It allows you to pause execution at a specific point in your code and inspect
/// the current state of your application. It also prints a formatted message to
/// the console, which can include a tag, a flag, and the value of an object.
///
///This function is particularly useful for debugging complex logic or when you
/// need to inspect the state of your application at a specific point.
///
/// Parameters:
///   - `object`: The object to print to the console.
///   - `tag`: An optional tag to include in the printed message. If not provided,
///     the name of the calling method will be used as the tag.
///   - `flag`: An optional flag to include in the printed message.
///   - `when`: A boolean indicating whether the debugger should be triggered.
///     Defaults to `true`. If`false`, the debugger will not be triggered, and
///     only the message will be printed to the console.
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
