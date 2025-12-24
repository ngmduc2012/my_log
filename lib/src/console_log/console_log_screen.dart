import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_log/my_log.dart';

/// A floating console log widget that can display real-time logs on the screen.
/// It allows toggling visibility, resizing, and saving logs.
class MyConsoleLog extends StatefulWidget {
  /// Creates a console log overlay.
  ///
  /// [children] are required widgets that will be wrapped inside the floating widget.
  /// [controller] is an optional parameter to manage the log state externally.
  const MyConsoleLog({
    super.key,
    this.controller,
    required this.children,
  });

  /// Controller to manage the console log visibility and state.
  final MyConsoleLogController? controller;

  /// Child widgets that are wrapped inside the floating widget.
  final List<Widget> children;

  @override
  State<MyConsoleLog> createState() => _MyConsoleLogState();
}

class _MyConsoleLogState extends State<MyConsoleLog> {
  /// Internal controller instance (if not provided externally).
  MyConsoleLogController? _controller;
  VoidCallback? _controllerListener;
  bool _ownsController = false;

  static const double _minScale = 0.3;
  static const double _maxScale = 1.0;
  static const double _scaleStep = 0.1;

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  /// Scaling factor for resizing the console log UI
  double scale = 2 / 3;

  @visibleForTesting
  double get scaleFactor => scale;

  MyConsoleLogController get controller => _controller!;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  // Called when the widget is updated with new properties
  @override
  void didUpdateWidget(MyConsoleLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _attachController(widget.controller);
    }
  }

  void _attachController(MyConsoleLogController? nextController) {
    _detachController();
    _ownsController = nextController == null;
    _controller = nextController ?? MyConsoleLogController();
    _controllerListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    try {
      controller.addListener(_controllerListener!);
    } catch (e) {
      myLog.warning(e, error: e);
    }
  }

  void _detachController() {
    if (_controller == null) {
      return;
    }
    if (_controllerListener != null) {
      controller.removeListener(_controllerListener!);
      _controllerListener = null;
    }
    if (_ownsController) {
      controller.dispose();
    }
    _controller = null;
    _ownsController = false;
  }

  void _updateScale(double delta) {
    final nextScale = (scale + delta).clamp(_minScale, _maxScale) as double;
    if (nextScale == scale) {
      return;
    }
    setState(() {
      scale = nextScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyFloatingWidget(
      child: controller.isShowConsoleLog
          ? Container(
              // Set constraints based on screen size and scale factor
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * scale,
                maxHeight: MediaQuery.of(context).size.height * scale,
              ),
              child: MyConsoleLogWidget(
                pathSaveLog: controller.pathSaveLog,
                onClose: () {
                  controller.setShowConsoleLog(false);
                },
                onZoomIn: () {
                  _updateScale(_scaleStep);
                },
                onZoomOut: () {
                  _updateScale(-_scaleStep);
                },
              ),
            )
          : null,
      children: widget.children,
    );
  }
}
