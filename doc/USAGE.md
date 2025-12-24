# MyLog Usage (Short)

## 1) Add dependency

```yaml
dependencies:
  my_log: ^1.0.0+6
```

## 2) Initialize in `main`

```dart
import 'package:flutter/material.dart';
import 'package:my_log/my_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await myLog.setUp(
    path: 'path/to/logfile.txt', // optional
    printTime: true,
    isLogging: true,
    noteInfoFileLog: 'This is the log file for my Flutter app.',
  );

  runApp(const MyApp());
}
```

Tip: use path_provider to build a writable path on mobile.

## 3) Log messages

```dart
myLog.trace('trace', tag: 'Auth', flag: 'Login');
myLog.debug('button pressed');
myLog.info('user signed in');
myLog.warning('slow response');
myLog.error('request failed');
myLog.fatal('fatal error', error: 'ERROR');
```

## 4) Show realtime logs (optional)

```dart
final MyConsoleLogController consoleLogController = MyConsoleLogController();

return MaterialApp(
  builder: (context, child) {
    return MyConsoleLog(
      controller: consoleLogController,
      children: [child ?? const SizedBox()],
    );
  },
);
```

```dart
consoleLogController.setShowConsoleLog(true);
```
