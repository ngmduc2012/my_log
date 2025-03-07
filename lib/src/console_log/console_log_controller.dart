import 'package:flutter/material.dart';

/*
Learn more: https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html#foundation.ChangeNotifier.1
This is the way that control a widget in outside.
*/

/// Part II: Controller
class MyConsoleLogController with ChangeNotifier implements Listenable {
  /// Learn more: url_to_document_of_package

  bool _isShowConsoleLog = false;

  bool get isShowConsoleLog => _isShowConsoleLog;

  void setShowConsoleLog(bool isShow) {
    _isShowConsoleLog = isShow;
    notifyListeners();
  }

  String? _pathSaveLog;

  String? get pathSaveLog => _pathSaveLog;

  void setPathSaveLog(String? path) {
    // path == null is mean not save log
    _pathSaveLog = path;
    notifyListeners();
  }
}
