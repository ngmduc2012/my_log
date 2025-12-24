import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_log/my_log.dart';
import 'package:path_provider/path_provider.dart';

typedef DirectoryProvider = Future<Directory?> Function();

Future<Directory?> resolveAppDirectory({
  required bool isIOS,
  required bool isAndroid,
  required DirectoryProvider getDocumentsDirectory,
  required DirectoryProvider getDownloadsDirectory,
}) async {
  if (isIOS) {
    return getDocumentsDirectory();
  }
  if (isAndroid) {
    return getDownloadsDirectory();
  }
  return null;
}

Future<String?> setUpLogging({
  required MyLog log,
  required bool isIOS,
  required bool isAndroid,
  required DirectoryProvider getDocumentsDirectory,
  required DirectoryProvider getDownloadsDirectory,
}) async {
  final appDir = await resolveAppDirectory(
    isIOS: isIOS,
    isAndroid: isAndroid,
    getDocumentsDirectory: getDocumentsDirectory,
    getDownloadsDirectory: getDownloadsDirectory,
  );

  if (appDir == null) {
    log.error('Can not get path');
    return null;
  }

  final logPath = '${appDir.path}/logfile.txt';
  log.info('App started');
  await log.setUp(
    path: logPath,
    printTime: true,
    isLogging: true,
    noteInfoFileLog: 'This is the log file for my Flutter app.',
  );

  return logPath;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logPath = await setUpLogging(
    log: myLog,
    isIOS: Platform.isIOS,
    isAndroid: Platform.isAndroid,
    getDocumentsDirectory: getApplicationDocumentsDirectory,
    getDownloadsDirectory: getDownloadsDirectory,
  );

  if (logPath == null) {
    return;
  }

  runApp(MyApp(logPath: logPath));
}

MyConsoleLogController consoleLogController = MyConsoleLogController();

class MyApp extends StatelessWidget {
  final String logPath;
  const MyApp({super.key, required this.logPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: LogScreen(logPath: logPath),
      builder: (context, child) {
        return MyConsoleLog(
          controller: consoleLogController,
          children: [LogScreen(logPath: logPath)],
        );
      },
    );
  }
}

class LogScreen extends StatefulWidget {
  final String logPath;
  const LogScreen({super.key, required this.logPath});

  @override
  LogScreenState createState() => LogScreenState();
}

class LogScreenState extends State<LogScreen> {
  MyLog myLog = MyLog();
  String logContent = "";

  Future<void> readLogFile() async {
    try {
      File logFile = File(widget.logPath);
      if (await logFile.exists()) {
        String content = await logFile.readAsString();
        setState(() {
          logContent = content;
        });
      } else {
        setState(() {
          logContent = "Log file not found.";
        });
      }
    } catch (e) {
      setState(() {
        logContent = "Error reading log file: \$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Logging Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "STEP 1: show log dialog",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                consoleLogController.setShowConsoleLog(true);
              },
              child: const Text('Show realtime logs'),
            ),
            const SizedBox(height: 20),
            const Text(
              "STEP 2: create log",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                myLog.trace(1, tag: "Your tag", flag: "Your flag");
                myLog.info(2, tag: "Your tag", flag: "Your flag");
                myLog.debug(3);
                myLog.warning(4, tag: "Your tag", flag: "Your flag");
                myLog.error(5, tag: "Your tag", flag: "Your flag");
                myLog.fatal(6, error: "ERROR");
              },
              child: const Text('Press Me'),
            ),
            const SizedBox(height: 20),
            const Text(
              "STEP 3: save file log",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Log file saved at: ${widget.logPath}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: readLogFile,
              child: const Text('See logFile content'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(logContent, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
