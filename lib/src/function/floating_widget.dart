import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Learn more: https://pub.dev/packages/floating_dialog
/// `MyFloatingWidget` is a StatefulWidget that provides a draggable and optionally auto-centeredfloating widget.
///
/// It allows you to display a widget (`child`) that can be dragged around the screen.
/// It also supports an optional close button and can be configured to automatically center itself
/// when first displayed.
///
/// This widget is useful for creating floating panels, dialogs,or other UI elements that
/// need to be positioned freely on the screen.
///
/// Example usage:
///
///
class MyFloatingWidget extends StatefulWidget {
  /// Creates a [MyFloatingWidget].
  ///
  /// [children] must not be null.
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

  /// A callback function that is called when the close button is pressed.
  final void Function()? onClose;

  /// A callback function that is called when the widget is dragged.
  ///
  /// Provides the new x and y coordinates of the widget.
  final void Function(double x, double y)? onDrag;

  /// The widget to be displayed as the floating element.
  ///
  /// If null, no floating element will be displayed.
  final Widget? child;

  /// The list of widgets that will be displayed below the floating widget.
  ///
  /// Typically, this will be your main application content.
  final List<Widget> children;

  /// Determines whether the widget should automatically center itself when first displayed.
  ///
  /// Defaults to `true`.
  final bool autoCenter;

  /// The initial left position of the floating widget.
  ///
  /// If null, the widget will be positioned based on [autoCenter].
  final double? dialogLeft;

  /// The initial top position of the floating widget.
  ///
  /// If null, the widget will be positioned based on [autoCenter].
  final double? dialogTop;

  @override
  MyFloatingWidgetState createState() => MyFloatingWidgetState();
}

/// `MyFloatingWidgetState` is the State class for [MyFloatingWidget].
///
/// It manages the internal state of the floating widget, including its position and visibility.
class MyFloatingWidgetState extends State<MyFloatingWidget> {
  // bool _dragging = false;
  double _xOffset = -1;
  double _yOffset = -1;
  Rect _rect = Rect.zero;

  /// A [GlobalKey] used to access the widget's size and position.
  ///
  /// This key is attached to the floating widget's child.
  final widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
  }

  /// Callback function executed after the frame is rendered.
  ///
  /// This method is scheduled to run after the current frame has been built.
  /// It is used to perform tasks that require the widget's layout to be complete,
  /// such as calculating its size and position.
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
                // if (mounted) {
                //   setState(() {
                //     _dragging = true;
                //   });
                // }
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
                // if (mounted) {
                //   setState(() {
                //     _dragging = false;
                //   });
                // }
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
