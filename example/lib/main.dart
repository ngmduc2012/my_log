import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_log/my_log.dart';
import 'package:path_provider/path_provider.dart';

const ourLogDiagram = "Activity Diagram";
MyConsoleLogController consoleLogController = MyConsoleLogController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory? downloadsDir = await getDownloadsDirectory();
  String logPath = '${downloadsDir?.path}/logfile.txt';
  MyLog myLog = MyLog();
  myLog.info('App started');
  await myLog.setUp(
    path: logPath,
    printTime: true,
    isLogging: true,
    noteInfoFileLog: 'This is the log file for my Flutter app.',
  );


  myLog.debug('Debugging info');
  myLog.error('An error occurred');
  myLog.info("ADS 4.4.7 | save image", flag: ourLogDiagram, tag: "Write log");

  runApp(MyApp(logPath: logPath));
}

class MyApp extends StatelessWidget {
  final String logPath;
  const MyApp({super.key, required this.logPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: LogScreen(logPath: logPath),
      builder: (context,child){
        return MyLocaleListener(didChangeLocales: (locale){
          myLog.warning(locale?.languageCode, tag: "didChangeLocales -> languageCode");

        },
          child:  MyConsoleLog(
            controller: consoleLogController,
            children: [
              LogScreen(logPath: logPath)
            ],
          ),
        );
      },
    );
  }
}

class LogScreen extends StatefulWidget {
  final String logPath;
  const LogScreen({super.key, required this.logPath});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
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
            Text("Log file saved at: ${widget.logPath}"),
            const SizedBox(height: 20),
            const Text("STEP 1:", style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                consoleLogController.setShowConsoleLog(true);
              },
              child: const Text('Show realtime logs'),
            ),
            const SizedBox(height: 20),
            const Text("STEP 2:", style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                myLog.debug('Button pressed');
                myLog.warning('This is a warning');
                myLog.error('This is an error');
              },
              child: const Text('Press Me'),
            ),
            const SizedBox(height: 20),
            const Text("STEP 3:", style: TextStyle(fontWeight: FontWeight.bold),),
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