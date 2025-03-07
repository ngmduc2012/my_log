import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Learn more: https://pub.dev/packages/floating_dialog

class MyFloatingWidget extends StatefulWidget {
  const MyFloatingWidget({
    super.key,
    this.onClose,
    this.onDrag,
    this.autoCenter = true,
    this.child,
    this.dialogLeft,
    this.dialogTop,
    required this.children,
  });

  final void Function()? onClose;
  final void Function(double x, double y)? onDrag;
  final Widget? child;
  final List<Widget> children;
  final bool autoCenter;
  final double? dialogLeft;
  final double? dialogTop;

  @override
  MyFloatingWidgetState createState() => MyFloatingWidgetState();
}

class MyFloatingWidgetState extends State<MyFloatingWidget> {
  bool _dragging = false;
  double _xOffset = -1;
  double _yOffset = -1;
  Rect _rect = Rect.zero;
  final widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
  }

  void postFrameCallback(_) {
    final context = widgetKey.currentContext;
    if (context == null) return;

    if (_rect == Rect.zero && widget.autoCenter) {
      final r = context.findRenderObject()?.paintBounds;
      if (r != null) {
        // we detected the widget size, let's set and build again
        _rect = r;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rect != Rect.zero && widget.autoCenter && _xOffset == -1) {
      _xOffset = (MediaQuery.of(context).size.width - _rect.width) / 2;
      _yOffset = (MediaQuery.of(context).size.height - _rect.height) / 2;
    } else {
      if (_xOffset == -1) {
        _xOffset = widget.dialogLeft ?? _xOffset;
        _yOffset = widget.dialogTop ?? _yOffset;
      }
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...widget.children,
        if (widget.child != null)
          Positioned(
            left: _xOffset == -1 ? 0 : _xOffset,
            top: _yOffset == -1 ? 0 : _yOffset,
            child: GestureDetector(
              onPanStart: (details) {
                if (mounted) {
                  setState(() {
                    _dragging = true;
                  });
                }
              },
              onPanUpdate: (details) {
                if (!mounted) {
                  return;
                }
                _xOffset += details.delta.dx;
                _yOffset += details.delta.dy;

                widget.onDrag?.call(_xOffset, _yOffset);

                setState(() {});
              },
              onPanEnd: (details) {
                if (mounted) {
                  setState(() {
                    _dragging = false;
                  });
                }
              },
              child: Builder(
                key: widgetKey,
                builder: (context) {
                  return widget.child ?? const SizedBox.shrink();
                },
              ),
            ),
          ),
      ],
    );
  }
}
