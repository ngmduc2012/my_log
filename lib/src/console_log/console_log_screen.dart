import 'package:flutter/material.dart';
import 'package:my_log/my_log.dart';

import '../function/src.dart';
import 'src.dart';


/// Part I: Screen
class MyConsoleLog extends StatefulWidget {
  const MyConsoleLog({
    super.key,
    this.controller,
    required this.children,
  });

  final MyConsoleLogController? controller;
  final List<Widget> children;

  @override
  State<MyConsoleLog> createState() => _MyConsoleLogState();
}

class _MyConsoleLogState extends State<MyConsoleLog> {
  late MyConsoleLogController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? MyConsoleLogController();
    try {
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      myLog.warning(e, error: e);
    }
  }

  // update once properties is changed
  @override
  void didUpdateWidget(MyConsoleLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.path != oldWidget.path) {
    //
    // }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double scale = 2 / 3;

  @override
  Widget build(BuildContext context) {
    return MyFloatingWidget(
      child: controller.isShowConsoleLog
          ? Container(
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
              // child: MyMaterial(child: Container(
              //   color: Colors.white,
              //   child: Text("ok"),)),
            )
          : null,
      children: widget.children,
    );
  }
}
