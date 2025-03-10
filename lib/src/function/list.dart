import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

import 'animated_limiter_item.dart';

/// `MyLogListView` is a StatelessWidget that provides a customizable list view.
////// It simplifies the creation of lists with various configurations, including
/// item count, shrink-wrapping, item and separator builders, scroll control,
/// padding, physics, scroll direction, reverse order, and more.
///
/// This widget can be used to create both simple lists with a fixed set of children/// or more complex lists that build their items on demand.
///
/// It offers flexibility similar to Flutter's built-in [ListView] but with a
/// simplified interface for common use cases.
class MyLogListView extends StatelessWidget {
  /// The number of items in the list.
  ///
  /// This is required when using [itemBuilder].
  final int? itemCount;

  /// Determines whether the list should shrink-wrap its content.
  ///
  /// If `true`, the list will only take up as much space as its children require.
  /// Defaults to `false`.
  final bool shrinkWrap;

  /// A builder function for creating list items.
  ///
  /// This is required when building the list dynamically.
  final Widget? Function(BuildContext, int)? itemBuilder;

  /// A builder function for creating separator widgets between items.
  final Widget? Function(BuildContext, int)? separatorBuilder;

  /// A [ScrollController] for controlling the list's scroll position.
  final ScrollController? controller;

  /// The padding around the list.
  final EdgeInsetsGeometry? padding;

  /// The scroll physics for the list.
  final ScrollPhysics? physics;

  /// The direction in which the list scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Determines whether the list should be displayed in reverse order.
  ///
  /// Defaults to `false`.
  final bool reverse;

  /// The padding at the start and end of the list.
  ///
  /// This is added in addition to any [padding] specified.
  final double paddingStartAndEnd;

  /// A list of widgets to display.
  ///
  /// This is required when building the list with a fixed set of children.
  final List<Widget>? children;

  /// The minimum height of the list.
  final double? minHeight;

  /// The spacing between items along the main axis.
  ///
  /// Defaults to `0`.
  final double mainAxisSpacing;

  /// Creates a [MyLogListView].
  ///
  /// [itemCount] is the number of items in the list (required for builder).
  /// [shrinkWrap] determines whether the list should shrink-wrap its content.
  /// [itemBuilder] is a builder function for creating list items (required for builder).
  /// [separatorBuilder] isa builder function for creating separator widgets between items.
  /// [controller] is a [ScrollController] for controlling the list's scroll position.
  /// [padding] is the padding around the list.
  /// [physics] is the scroll physics for the list.
  /// [scrollDirection] is the direction in which the list scrolls.
  /// [reverse] determines whether the list should be displayed in reverse order.
  /// [paddingStartAndEnd] is the padding at the start and end of the list.
  /// [children] is a list of widgets to display (required for non-builder).
  /// [minHeight] is the minimum height of the list.
  /// [mainAxisSpacing] is the spacing between items along the main axis.
  const MyLogListView({
    super.key,
    this.itemCount,
    this.shrinkWrap = false,
    this.itemBuilder,
    this.controller,
    this.physics,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.paddingStartAndEnd = 0,
    this.children,
    this.minHeight,
    this.separatorBuilder,
    this.mainAxisSpacing = 15,
  }) : assert(
          children != null || (itemBuilder != null && itemCount != null),
          "children vs (itemBuilder, itemCount) chỉ sử dụng 1 trong 2",
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: AnimationLimiter(
        child: ListView.separated(
          // primary: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: reverse,
          scrollDirection: scrollDirection,
          padding: padding ?? EdgeInsets.zero,
          controller: controller,
          shrinkWrap: minHeight != null || shrinkWrap,
          physics: physics ??
              const BouncingScrollPhysics(
                  // parent: RangeMaintainingScrollPhysics(),
                  ),
          itemCount: children == null ? itemCount! : children!.length,
          itemBuilder: (context, index) => MyAnimatedLimiterItem(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(
                left: scrollDirection == Axis.horizontal && index == 0
                    ? paddingStartAndEnd
                    : 0,
                top: scrollDirection == Axis.vertical && index == 0
                    ? paddingStartAndEnd
                    : 0,
                right: scrollDirection == Axis.horizontal &&
                        index ==
                            (children == null ? itemCount! : children!.length) -
                                1
                    ? paddingStartAndEnd
                    : 0,
                bottom: scrollDirection == Axis.vertical &&
                        index ==
                            (children == null ? itemCount! : children!.length) -
                                1
                    ? paddingStartAndEnd
                    : 0,
              ),
              child: Visibility(
                visible: children == null,
                replacement: children == null
                    ? const SizedBox.shrink()
                    : children![index],
                child: (itemBuilder == null
                        ? const SizedBox.shrink()
                        : itemBuilder!(context, index)) ??
                    const SizedBox.shrink(),
              ),
            ),
          ),
          separatorBuilder: (context, index) => MyAnimatedLimiterItem(
            index: index,
            child: Visibility(
              visible: separatorBuilder == null,
              replacement: (separatorBuilder == null
                      ? const SizedBox.shrink()
                      : separatorBuilder!(context, index)) ??
                  const SizedBox.shrink(),
              child: Gap(mainAxisSpacing),
            ),
          ),
        ),
      ),
    );
  }
}
