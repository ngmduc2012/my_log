import 'package:flutter/material.dart';

/// Learn more: https://stackoverflow.com/a/75831000
class MyLocaleListener extends StatefulWidget {
  final Locale defaultLocale;
  final Widget? child;
  final Function(Locale? local) didChangeLocales;

  const MyLocaleListener({
    super.key,
    this.defaultLocale = const Locale('en_US'),
    this.child,
    required this.didChangeLocales,
  });

  @override
  State<MyLocaleListener> createState() => _MyLocaleListenerState();
}

class _MyLocaleListenerState extends State<MyLocaleListener> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    // Here locales is a list of all the locales enabled on the device.
    // Like: [Locale('en_US'), Locale('ar_SA')]

    // The first locale is the phone's main locale, but in reality you should
    // traverse until you find a supported locale.
    final currentLocale = locales?.first ?? widget.defaultLocale;
    widget.didChangeLocales.call(currentLocale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
