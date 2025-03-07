import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'log_bug.dart';

/// * setup off when build release.
/*
run:
    flutter run  --release -t lib/main/main_production.dart
    flutter run  --release -t lib/main/main_staging.dart
    flutter run  --release -t lib/main/main_development.dart

SET UP
void main() {
  myEnviDevelop = false;
  ...
}

How to use?
Turn on/off:
      myEnviDevelop = false;
      await MyFlutter.engine.reloadApp();
 */
// bool myEnviDevelop = true;
late bool myEnviDevelop;

Future<void> myFuncChangeToDevMode({bool turnOn = true}) async {
  myEnviDevelop = turnOn;
  await WidgetsFlutterBinding.ensureInitialized().performReassemble();
}

MyLog myLog = MyLog();

/*
USE |
void main() {
  myMain(() {
  // runApp();
    });
}
 */
void myMain<R>(R Function() body, {Function(Object, StackTrace)? onError}) {
  runZonedGuarded(
    body,
        (error, stackTrace) {
      myLog.fatal(error.toString(), tag: "myMain", error: error, stackTrace: stackTrace);
      onError?.call(error, stackTrace);
    },
  );
}
