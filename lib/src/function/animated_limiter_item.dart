import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// `MyAnimatedLimiterItem` is a StatelessWidget that provides an animated entry effect foritems in a list or grid.
///
/// It is designed to be used with widgets like [ListView] or [GridView] to create a staggered animation
/// when items are added to the screen. Each item's animation is delayed based on its index,
/// creating a visually appealing effect.
////// This widget is particularly useful for enhancing the user experience when displaying lists or grids
/// that load dynamically.
class MyAnimatedLimiterItem extends StatelessWidget {
  /// Creates a [MyAnimatedLimiterItem].
  ///
  /// [child] is the widget to be animated.
  /// [index] is the index of the item in the list or grid.
  /// [crossAxisCount] is the number of items in the cross axis (for grids).
  const MyAnimatedLimiterItem({
    super.key,
    required this.child,
    required this.index,
    this.crossAxisCount,
  });

  /// The widget to be animated.
  ///
  /// This is typically a single item in a list or grid.
  final Widget child;

  /// The index of the item in the list or grid.
  ///
  /// This is used to calculate the animation delay.
  final int index;

  /// The number of items in the cross axis (for grids).
  ///
  /// If provided, this is used to adjust the animation delay for grid items.
  final int? crossAxisCount;

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
