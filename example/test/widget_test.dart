import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_log/my_log.dart';

class _SpyLog extends MyLog {
  int setUpCalls = 0;
  String? lastPath;
  bool? lastPrintTime;
  String? lastInfo;
  String? lastError;

  @override
  Future<void> setUp({
    String? path,
    bool printTime = true,
    bool isLogging = true,
    String? noteInfoFileLog,
  }) async {
    setUpCalls++;
    lastPath = path;
    lastPrintTime = printTime;
  }

  @override
  void info(Object? object, {String? tag, String? flag, Object? error}) {
    lastInfo = object?.toString();
  }

  @override
  void error(Object? object, {String? tag, String? flag}) {
    lastError = object?.toString();
  }
}

void main() {
  setUp(() {
    consoleLogController = MyConsoleLogController();
  });

  testWidgets('renders log screen and log path', (tester) async {
    await tester.pumpWidget(const MyApp(logPath: 'log.txt'));

    expect(find.text('Flutter Logging Example'), findsOneWidget);
    expect(find.text('STEP 1: show log dialog'), findsOneWidget);
    expect(find.text('STEP 2: create log'), findsOneWidget);
    expect(find.text('STEP 3: save file log'), findsOneWidget);
    expect(find.text('Log file saved at: log.txt'), findsOneWidget);

    expect(find.text('Show realtime logs'), findsOneWidget);
    expect(find.text('Press Me'), findsOneWidget);
    expect(find.text('See logFile content'), findsOneWidget);
  });

  testWidgets('show realtime logs displays overlay', (tester) async {
    await tester.pumpWidget(const MyApp(logPath: 'log.txt'));

    expect(find.byType(MyConsoleLogWidget), findsNothing);

    await tester.tap(find.text('Show realtime logs'));
    await tester.pump();

    expect(find.byType(MyConsoleLogWidget), findsOneWidget);
  });

  testWidgets('press me does not throw', (tester) async {
    await tester.pumpWidget(const MyApp(logPath: 'log.txt'));

    await tester.tap(find.text('Press Me'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('reads log file content', (tester) async {
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final logPath = '${dir.path}/log.txt';
    File(logPath).writeAsStringSync('LOG_CONTENT');

    await tester.pumpWidget(MyApp(logPath: logPath));

    final state = tester.state(find.byType(LogScreen));
    await tester.runAsync(() async {
      await (state as dynamic).readLogFile();
    });
    await tester.pump();

    expect(find.text('LOG_CONTENT'), findsOneWidget);
  });

  testWidgets('shows not found when log file is missing', (tester) async {
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final logPath = '${dir.path}/missing.txt';

    await tester.pumpWidget(MyApp(logPath: logPath));

    final state = tester.state(find.byType(LogScreen));
    await tester.runAsync(() async {
      await (state as dynamic).readLogFile();
    });
    await tester.pump();

    expect(find.text('Log file not found.'), findsOneWidget);
  });

  testWidgets('shows not found when log path is a directory', (tester) async {
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final logPath = dir.path;

    await tester.pumpWidget(MyApp(logPath: logPath));

    final state = tester.state(find.byType(LogScreen));
    await tester.runAsync(() async {
      await (state as dynamic).readLogFile();
    });
    await tester.pump();

    expect(find.text('Log file not found.'), findsOneWidget);
  });

  test('resolveAppDirectory uses documents on iOS', () async {
    var documentsCalls = 0;
    var downloadsCalls = 0;
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final result = await resolveAppDirectory(
      isIOS: true,
      isAndroid: false,
      getDocumentsDirectory: () async {
        documentsCalls++;
        return dir;
      },
      getDownloadsDirectory: () async {
        downloadsCalls++;
        return null;
      },
    );

    expect(result?.path, dir.path);
    expect(documentsCalls, 1);
    expect(downloadsCalls, 0);
  });

  test('resolveAppDirectory uses downloads on Android', () async {
    var documentsCalls = 0;
    var downloadsCalls = 0;
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final result = await resolveAppDirectory(
      isIOS: false,
      isAndroid: true,
      getDocumentsDirectory: () async {
        documentsCalls++;
        return null;
      },
      getDownloadsDirectory: () async {
        downloadsCalls++;
        return dir;
      },
    );

    expect(result?.path, dir.path);
    expect(documentsCalls, 0);
    expect(downloadsCalls, 1);
  });

  test('setUpLogging returns null when app dir is missing', () async {
    final log = _SpyLog();

    final result = await setUpLogging(
      log: log,
      isIOS: false,
      isAndroid: false,
      getDocumentsDirectory: () async => null,
      getDownloadsDirectory: () async => null,
    );

    expect(result, isNull);
    expect(log.lastError, 'Can not get path');
  });

  test('setUpLogging returns path and calls setUp', () async {
    final log = _SpyLog();
    final dir = Directory.systemTemp.createTempSync('my_log_example_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final result = await setUpLogging(
      log: log,
      isIOS: true,
      isAndroid: false,
      getDocumentsDirectory: () async => dir,
      getDownloadsDirectory: () async => null,
    );

    expect(result, '${dir.path}/logfile.txt');
    expect(log.setUpCalls, 1);
    expect(log.lastPath, result);
    expect(log.lastPrintTime, isTrue);
    expect(log.lastInfo, 'App started');
  });
}
