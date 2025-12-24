import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:my_log/my_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyLog core logging', () {
    test('setUp updates isLogging flag', () async {
      final myLog = MyLog();

      expect(myLog.isLogging, isTrue);
      await myLog.setUp(isLogging: false);
      expect(myLog.isLogging, isFalse);
      await myLog.setUp(isLogging: true);
      expect(myLog.isLogging, isTrue);
    });

    test('log methods emit expected levels and messages', () async {
      final myLog = MyLog();
      await myLog.setUp(printTime: false);

      final events = <LogEvent>[];
      void listener(LogEvent event) {
        events.add(event);
      }

      Logger.addLogListener(listener);
      addTearDown(() => Logger.removeLogListener(listener));

      myLog.trace('trace', tag: 'TAG', flag: 'flag');
      myLog.debug('debug', tag: 'TAG');
      myLog.info('info', tag: '', flag: 'flow');
      myLog.warning('warning', tag: '');
      myLog.error('error', tag: 'TAG', flag: 'FLAG');
      myLog.fatal('fatal', tag: 'TAG', error: 'ERR');

      expect(events, hasLength(6));

      expect(events[0].level, Level.trace);
      expect(events[0].message, 'TAG | FLAG | trace');

      expect(events[1].level, Level.debug);
      expect(events[1].message, 'TAG | debug');

      expect(events[2].level, Level.info);
      expect(events[2].message, 'FLOW | info');

      expect(events[3].level, Level.warning);
      expect(events[3].message, 'warning');

      expect(events[4].level, Level.error);
      expect(events[4].message, 'TAG | FLAG | error');
      expect(events[4].error, 'error');

      expect(events[5].level, Level.fatal);
      expect(events[5].message, 'TAG | fatal');
      expect(events[5].error, 'ERR');
    });

    test('logs when isLogging is false in debug mode', () async {
      final myLog = MyLog();
      await myLog.setUp(isLogging: false, printTime: false);

      final events = <LogEvent>[];
      void listener(LogEvent event) {
        events.add(event);
      }

      Logger.addLogListener(listener);
      addTearDown(() => Logger.removeLogListener(listener));

      myLog.info('info');

      if (kDebugMode) {
        expect(events, isNotEmpty);
      } else {
        expect(events, isEmpty);
      }
    });

    test('log methods pass error parameter', () async {
      final myLog = MyLog();
      await myLog.setUp(printTime: false);

      final events = <LogEvent>[];
      void listener(LogEvent event) {
        events.add(event);
      }

      Logger.addLogListener(listener);
      addTearDown(() => Logger.removeLogListener(listener));

      myLog.trace('trace', error: 'E1');
      myLog.debug('debug', error: 'E2');
      myLog.info('info', error: 'E3');
      myLog.warning('warning', error: 'E4');

      expect(events, hasLength(4));
      expect(events[0].level, Level.trace);
      expect(events[0].error, 'E1');
      expect(events[1].level, Level.debug);
      expect(events[1].error, 'E2');
      expect(events[2].level, Level.info);
      expect(events[2].error, 'E3');
      expect(events[3].level, Level.warning);
      expect(events[3].error, 'E4');
    });
  });

  group('MyLog file logging', () {
    test('setUp with path writes note and skips trace in file', () async {
      final dir = await Directory.systemTemp.createTemp('my_log_test_');
      addTearDown(() => dir.delete(recursive: true));

      final file = File('${dir.path}/log.txt');
      final myLog = MyLog();

      await myLog.setUp(
        path: file.path,
        noteInfoFileLog: 'NOTE\n',
        printTime: false,
      );
      await myLog.logger.init;

      myLog.trace('trace message', tag: 'TAG', flag: 'FLAG');
      myLog.info('info message', tag: 'TAG', flag: 'FLAG');
      await myLog.logger.close();

      final content = await file.readAsString();
      expect(content.startsWith('NOTE'), isTrue);
      expect(content.contains('info |'), isTrue);
      expect(content.contains('TAG | FLAG | info message'), isTrue);
      expect(content.contains('trace |'), isFalse);
    });

    test('FileOutput2 overrideExisting truncates file', () async {
      final dir = await Directory.systemTemp.createTemp('my_log_test_');
      addTearDown(() => dir.delete(recursive: true));

      final file = File('${dir.path}/log.txt');
      await file.writeAsString('OLD');

      final output = FileOutput2(file: file, overrideExisting: true);
      await output.init();
      final event = LogEvent(
        Level.info,
        'NEW MESSAGE',
        time: DateTime.utc(2020, 1, 1),
        error: 'ERR',
      );
      output.output(OutputEvent(event, const ['NEW MESSAGE']));
      await output.destroy();

      final content = await file.readAsString();
      expect(content.contains('OLD'), isFalse);
      expect(content.contains('info |'), isTrue);
      expect(content.contains('NEW MESSAGE'), isTrue);
      expect(content.contains('ERR'), isTrue);
    });

    test('FileOutput2 appends when overrideExisting is false', () async {
      final dir = await Directory.systemTemp.createTemp('my_log_test_');
      addTearDown(() => dir.delete(recursive: true));

      final file = File('${dir.path}/log.txt');
      await file.writeAsString('OLD');

      final output = FileOutput2(file: file);
      await output.init();
      final event = LogEvent(
        Level.warning,
        'APPEND MESSAGE',
        time: DateTime.utc(2021, 1, 1),
        error: 'WARN',
      );
      output.output(OutputEvent(event, const ['APPEND MESSAGE']));
      await output.destroy();

      final content = await file.readAsString();
      expect(content.contains('OLD'), isTrue);
      expect(content.contains('warning |'), isTrue);
      expect(content.contains('APPEND MESSAGE'), isTrue);
      expect(content.contains('WARN'), isTrue);
    });

    test('noteInfoFileLog appends across setUp calls', () async {
      final dir = await Directory.systemTemp.createTemp('my_log_test_');
      addTearDown(() => dir.delete(recursive: true));

      final file = File('${dir.path}/log.txt');
      final myLog = MyLog();

      await myLog.setUp(
        path: file.path,
        noteInfoFileLog: 'NOTE1\n',
        printTime: false,
      );
      await myLog.logger.init;
      await myLog.logger.close();

      await myLog.setUp(
        path: file.path,
        noteInfoFileLog: 'NOTE2\n',
        printTime: false,
      );
      await myLog.logger.init;
      await myLog.logger.close();

      final content = await file.readAsString();
      expect(content.contains('NOTE1'), isTrue);
      expect(content.contains('NOTE2'), isTrue);
      expect(content.indexOf('NOTE1'), lessThan(content.indexOf('NOTE2')));
    });
  });

  group('MyLog utilities', () {
    test('myPrint formats tag and flag', () {
      final lines = _capturePrints(() {
        myPrint('hello', tag: 'TAG', flag: 'flag');
        myPrint('hello', tag: 'TAG');
        myPrint('hello', tag: '', flag: 'flag');
        myPrint('hello', tag: '', flag: '');
      });

      expect(lines[0], 'TAG | FLAG | hello');
      expect(lines[1], 'TAG | hello');
      expect(lines[2], 'FLAG | hello');
      expect(lines[3], 'hello');
    });

    test('myDebugPrint uses formatter', () {
      final lines = <String?>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        lines.add(message);
      };
      addTearDown(() => debugPrint = original);

      myDebugPrint('hello', tag: 'TAG', flag: 'flag');

      expect(lines, ['TAG | FLAG | hello']);
    });

    test('myLogDev does not throw', () {
      expect(() => myLogDev('hello', tag: 'TAG'), returnsNormally);
    });

    test('myDebugger does not throw when disabled', () {
      expect(() => myDebugger('hello', when: false), returnsNormally);
    });

    test('myFucGetParentMethodName includes caller', () {
      final name = _captureParentName();
      expect(name, isNotNull);
      expect(name, contains('my_log_test.dart'));
    });

    test('myWriteln writes to stderr', () {
      final output = _captureStderr(() {
        myWriteln('hello', tag: 'TAG', flag: 'flag');
      });

      expect(output.trim(), 'TAG | FLAG | hello');
    });
  });
}

List<String> _capturePrints(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        lines.add(line);
      },
    ),
  );
  return lines;
}

String? _captureParentName() => myFucGetParentMethodName();

String _captureStderr(void Function() body) {
  final sink = _TestStdout();
  IOOverrides.runZoned(body, stderr: () => sink);
  return sink.buffer.toString();
}

class _TestStdout implements Stdout {
  final StringBuffer buffer = StringBuffer();
  final Completer<void> _done = Completer<void>();
  Encoding _encoding = utf8;
  String _lineTerminator = '\n';

  @override
  Encoding get encoding => _encoding;

  @override
  set encoding(Encoding value) {
    _encoding = value;
  }

  @override
  bool get hasTerminal => false;

  @override
  int get terminalColumns => 0;

  @override
  int get terminalLines => 0;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  IOSink get nonBlocking => this;

  @override
  String get lineTerminator => _lineTerminator;

  @override
  set lineTerminator(String value) {
    if (value != '\n' && value != '\r\n') {
      throw ArgumentError.value(
          value, 'lineTerminator', 'must be "\\n" or "\\r\\n"');
    }
    _lineTerminator = value;
  }

  @override
  void add(List<int> data) {
    buffer.write(_encoding.decode(data));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  Future close() async {
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  @override
  Future flush() async {}

  @override
  Future get done => _done.future;

  @override
  void write(Object? object) {
    buffer.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    buffer.writeAll(objects, separator);
  }

  @override
  void writeln([Object? object = ""]) {
    buffer.write(object);
    buffer.write(_lineTerminator);
  }

  @override
  void writeCharCode(int charCode) {
    buffer.writeCharCode(charCode);
  }
}
