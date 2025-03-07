import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MyAnimatedLimiterItem extends StatelessWidget {
  final Widget child; // For Grid, list item
  final int index; // For Grid, list item
  final int? crossAxisCount; // For Grid

  const MyAnimatedLimiterItem({
    super.key,
    required this.child,
    required this.index,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: crossAxisCount != null,
      // For list view
      replacement: AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 200),
        child: SlideAnimation(
          verticalOffset: 20,
          child: FadeInAnimation(
            child: child,
          ),
        ),
      ),
      // For grid view
      child: AnimationConfiguration.staggeredGrid(
        position: index,
        duration: const Duration(milliseconds: 200),
        columnCount: crossAxisCount ?? 0,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child: child,
          ),
        ),
      ),
    );
  }
}
