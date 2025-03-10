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
  late MyConsoleLogController controller;

  @override
  void initState() {
    super.initState();
    // Use the provided controller or create a new one
    controller = widget.controller ?? MyConsoleLogController();
    try {
      // Listen for changes in the controller and update the UI accordingly
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      myLog.warning(e, error: e);
    }
  }

  // Called when the widget is updated with new properties
  @override
  void didUpdateWidget(MyConsoleLog oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Scaling factor for resizing the console log UI
  double scale = 2 / 3;

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
                  setState(() {
                    scale += 0.1;
                  });
                },
                onZoomOut: () {
                  setState(() {
                    scale -= 0.1;
                  });
                },
              ),
            )
          : null,
      children: widget.children,
    );
  }
}
