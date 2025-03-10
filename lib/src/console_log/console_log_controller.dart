import 'package:flutter/material.dart';

/*
Learn more: https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html#foundation.ChangeNotifier.1
This is the way that control a widget in outside.
*/
/// `MyConsoleLogController` is a [ChangeNotifier] that manages the state ofthe console log display and the path for saving logs.
///
/// It provides functionality to:
///   - Toggle the visibility of the console log.
///   - Set and get the file path where logs should be saved.
///   - Notify listeners when the state changes.
///
/// Thisclass is designed to be used with a state management solution like Provider or Riverpod,
/// allowing widgets to rebuild when the console log's visibility or the log file path changes.
class MyConsoleLogController with ChangeNotifier implements Listenable {
  /// Indicates whether the console log is currently being displayed.
  ///
  /// Defaults to `false`.
  bool _isShowConsoleLog = false;

  /// Returns `true` if the console log is currently visible, `false` otherwise.
  bool get isShowConsoleLog => _isShowConsoleLog;

  /// Sets the visibility of the console log.///
  /// When this method is called, it updates the [_isShowConsoleLog] property and
  /// notifies all registered listeners that the state has changed.
  ///
  /// [isShow] - `true` to show the console log, `false` to hide it.
  void setShowConsoleLog(bool isShow) {
    _isShowConsoleLog = isShow;
    notifyListeners();
  }

  /// The file path where logs are saved.
  ///
  /// If this is `null`, it indicates that logs are not being saved to a file.
  String? _pathSaveLog;

  /// Returns the current file path where logs are being saved, or `null` if logs are not being saved.
  String? get pathSaveLog => _pathSaveLog;

  /// Sets the file path where logs should be saved.
  ///
  /// If [path] is `null`, it indicates that logs should not be saved to a file.
  ///
  /// When this method is called, it updates the [_pathSaveLog] property and
  /// notifies all registered listeners that the state has changed.
  ///
  /// [path] - The file path to save logs to, or `null` to disable log saving.
  void setPathSaveLog(String? path) {
    // path == null is mean not save log
    _pathSaveLog = path;
    notifyListeners();
  }
}
