# Setting Up Colored Logs, Saving Logs to Device Memory, and Viewing Logs in Real-Time with MyLog

## Introduction
Logging is an essential aspect of application development, helping developers monitor application behavior, debug issues, and maintain logs for future reference. The `MyLog` package provides a powerful logging system that allows you to:
- Set up colored logs for better readability.
- Save log files to the device memory.
- Display logs in real-time on the screen.
- Support both front and rear cameras.
- Switch the application mode to development mode.

This guide will walk you through the installation, setup, and usage of `MyLog` in your Flutter application.

## Installation and Usage

### 1. Add the Package to Your `pubspec.yaml`
To get started, add `MyLog` as a dependency in your Flutter project by modifying your `pubspec.yaml` file:

```yaml
dependencies:
  my_log: ^latest_version
```

Then, run the following command to fetch the package:
```sh
flutter pub get
```

### 2. Initialize Logging in Your App
To properly initialize logging, configure `MyLog` in your main application file.

In the `main()` function of your application, after calling `WidgetsFlutterBinding.ensureInitialized();`, initialize `MyLog` using the `setUp()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MyLog myLog = MyLog();
  await myLog.setUp(
    path: 'path/to/your/logfile.txt', // Specify the log file path.
    printTime: true, // Enables timestamp in logs.
    isLogging: true, // Enables logging.
    noteInfoFileLog: 'This is the log file for my Flutter app.',
  );
  runApp(MyApp());
}
```

Once configured, logs will be saved to the specified file path.

### 3. Using Logging Methods
Throughout your application, use the logging methods provided by the `MyLog` class to record messages at different levels (trace, debug, info, warning, error, fatal).

Example usage:
```dart
myLog.debug('Button pressed');
myLog.warning('This is a warning');
myLog.error('This is an error');
```

### 4. Display Logs on Screen for Easy Tracking
To view logs in real-time on your application screen, follow these steps:

#### Step 1: Declare a Global Controller
Declare a global controller for log display:
```dart
MyConsoleLogController consoleLogController = MyConsoleLogController();
```

#### Step 2: Wrap Your Widget Tree in `MyConsoleLog`
Modify your `MaterialApp` builder to include `MyConsoleLog`:

```dart
return MaterialApp(
  builder: (context, child) {
    return MyConsoleLog(
      controller: consoleLogController,
      children: [
        LogScreen(logPath: logPath)
      ],
    );
  },
);
```

#### Step 3: Toggle Real-Time Log Display
To enable real-time log display, call the `setShowConsoleLog(true)` function:

```dart
ElevatedButton(
  onPressed: () {
    consoleLogController.setShowConsoleLog(true);
  },
  child: const Text('Show realtime logs'),
)
```

### 5. Switching to Development Mode
I have set up real-time logging to be displayed only in development (debug) mode. If you are in release mode but need to view real-time logs, you can easily switch to development mode using the following function:

```dart
myFuncChangeToDevMode();
```

This function will allow you to enable real-time logging even in release mode when necessary.

## Conclusion
With `MyLog`, you can efficiently monitor and debug your Flutter applications by setting up colored logs, saving logs to a file, and displaying real-time logs on-screen. By following this guide, you can seamlessly integrate logging into your Flutter projects, improving application maintainability and debugging efficiency.

Start using `MyLog` today to gain better insights into your application's behavior!

