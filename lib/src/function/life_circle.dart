import 'package:flutter/material.dart';

/// `MyLifeCircleWidget` is a StatefulWidget that provides callbacks for various lifecycle events.
///
/// It allows you to listen to events such as when the app is resumed, paused, inactive, detached, or hidden.
/// This is useful for performing actions that need to be synchronized withthe app's lifecycle,
/// such as starting or stopping animations, saving data, or releasing resources.
///
/// This widget is inspired by Android's activity lifecycle events.
///
/// Learn more: https://docs.flutter.dev/get-started/flutter-for/android-devs#how-do-i-listen-to-android-activity-lifecycle-events
class MyLifeCircleWidget extends StatefulWidget {
  /// Creates a [MyLifeCircleWidget].
  ///
  /// [child] is the widget that will be displayed.
  /// [onResumed]is a callback that is called when the app is resumed.
  /// [onInactive] is a callback that is called when the app is inactive.
  /// [onPaused] is a callback that is called when the app is paused.
  /// [onDetached] is a callback that is called when the app is detached.
  /// [onHidden] is a callback that is called when the app is hidden.
  const MyLifeCircleWidget({
    super.key,
    required this.child,
    this.onResumed,
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onHidden,
  });

  /// The widget that will be displayed.
  final Widget child;

  /// A callback function that is called when the app is resumed.
  final Function()? onResumed;

  /// A callback function that is called when the app is inactive.
  final Function()? onInactive;

  /// A callback function that is called when the app is paused.
  final Function()? onPaused;

  /// A callback function that is called when the app is detached.
  final Function()? onDetached;

  /// A callback function that is called when the app is hidden.
  final Function()? onHidden;

  @override
  State<MyLifeCircleWidget> createState() => _MyLifeCircleWidgetState();
}

class _MyLifeCircleWidgetState extends State<MyLifeCircleWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResumed?.call();
      case AppLifecycleState.inactive:
        widget.onInactive?.call();
      case AppLifecycleState.paused:
        widget.onPaused?.call();
      case AppLifecycleState.detached:
        widget.onDetached?.call();
      case AppLifecycleState.hidden:
        widget.onHidden?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
