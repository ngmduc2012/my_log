import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_log/my_log.dart';

void main() {
  group('MyFloatingWidget', () {
    testWidgets('autoCenter positions child', (tester) async {
      const childKey = Key('float-child');
      const size = Size(200, 200);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: size),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: MyFloatingWidget(
                child: const SizedBox(
                  key: childKey,
                  width: 50,
                  height: 40,
                ),
                children: const [SizedBox()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final topLeft = tester.getTopLeft(find.byKey(childKey));
      expect(topLeft.dx, closeTo(75, 0.1));
      expect(topLeft.dy, closeTo(80, 0.1));
    });

    testWidgets('uses dialogLeft and dialogTop when autoCenter is false',
        (tester) async {
      const childKey = Key('float-child');

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(200, 200)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: MyFloatingWidget(
                autoCenter: false,
                dialogLeft: 10,
                dialogTop: 20,
                child: const SizedBox(
                  key: childKey,
                  width: 50,
                  height: 40,
                ),
                children: const [SizedBox()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final topLeft = tester.getTopLeft(find.byKey(childKey));
      expect(topLeft.dx, closeTo(10, 0.1));
      expect(topLeft.dy, closeTo(20, 0.1));
    });

    testWidgets('drag updates position and calls onDrag', (tester) async {
      const childKey = Key('float-child');
      double? dragX;
      double? dragY;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(200, 200)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: MyFloatingWidget(
                autoCenter: false,
                dialogLeft: 0,
                dialogTop: 0,
                onDrag: (x, y) {
                  dragX = x;
                  dragY = y;
                },
                child: Container(
                  key: childKey,
                  width: 20,
                  height: 20,
                  color: Colors.transparent,
                ),
                children: const [SizedBox()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.drag(find.byKey(childKey), const Offset(10, 15));
      await tester.pump();

      final topLeft = tester.getTopLeft(find.byKey(childKey));
      expect(topLeft.dx, closeTo(10, 0.1));
      expect(topLeft.dy, closeTo(15, 0.1));
      expect(dragX, closeTo(10, 0.1));
      expect(dragY, closeTo(15, 0.1));
    });
  });

  group('MyLifeCircleWidget', () {
    testWidgets('calls onResumed', (tester) async {
      var called = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyLifeCircleWidget(
            child: const SizedBox(),
            onResumed: () {
              called = true;
            },
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onInactive', (tester) async {
      var called = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyLifeCircleWidget(
            child: const SizedBox(),
            onInactive: () {
              called = true;
            },
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onPaused', (tester) async {
      var called = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyLifeCircleWidget(
            child: const SizedBox(),
            onPaused: () {
              called = true;
            },
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onDetached', (tester) async {
      var called = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyLifeCircleWidget(
            child: const SizedBox(),
            onDetached: () {
              called = true;
            },
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onHidden', (tester) async {
      var called = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyLifeCircleWidget(
            child: const SizedBox(),
            onHidden: () {
              called = true;
            },
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      expect(called, isTrue);
    });
  });

  group('MyConsoleLogController', () {
    test('notifies listeners on state changes', () {
      final controller = MyConsoleLogController();
      var calls = 0;
      controller.addListener(() => calls++);

      expect(controller.isShowConsoleLog, isFalse);
      expect(controller.pathSaveLog, isNull);

      controller.setShowConsoleLog(true);
      controller.setPathSaveLog('log.txt');

      expect(controller.isShowConsoleLog, isTrue);
      expect(controller.pathSaveLog, 'log.txt');
      expect(calls, 2);
    });
  });

  group('MyConsoleLog', () {
    testWidgets('toggles overlay with controller', (tester) async {
      final controller = MyConsoleLogController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyConsoleLog(
            controller: controller,
            children: const [SizedBox()],
          ),
        ),
      );

      expect(find.byType(MyConsoleLogWidget), findsNothing);

      controller.setShowConsoleLog(true);
      await tester.pump();
      expect(find.byType(MyConsoleLogWidget), findsOneWidget);

      controller.setShowConsoleLog(false);
      await tester.pump();
      expect(find.byType(MyConsoleLogWidget), findsNothing);
    });

    testWidgets('zoom buttons adjust overlay constraints', (tester) async {
      final controller = MyConsoleLogController()..setShowConsoleLog(true);

      await tester.pumpWidget(
        MaterialApp(
          home: MyConsoleLog(
            controller: controller,
            children: const [SizedBox()],
          ),
        ),
      );

      await tester.pump();

      final containerFinder = find.ancestor(
        of: find.byType(MyConsoleLogWidget),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth != null &&
              widget.constraints?.maxHeight != null,
        ),
      );

      expect(containerFinder, findsOneWidget);

      final initialConstraints =
          tester.widget<Container>(containerFinder).constraints!;

      await tester.tap(find.byIcon(Icons.zoom_out_map));
      await tester.pump();

      final zoomInConstraints =
          tester.widget<Container>(containerFinder).constraints!;

      expect(zoomInConstraints.maxWidth, greaterThan(initialConstraints.maxWidth));
      expect(
          zoomInConstraints.maxHeight, greaterThan(initialConstraints.maxHeight));

      await tester.tap(find.byIcon(Icons.zoom_in_map));
      await tester.pump();

      final zoomOutConstraints =
          tester.widget<Container>(containerFinder).constraints!;

      expect(zoomOutConstraints.maxWidth, lessThan(zoomInConstraints.maxWidth));
      expect(zoomOutConstraints.maxHeight, lessThan(zoomInConstraints.maxHeight));
    });

    testWidgets('save icon only appears when pathSaveLog is set',
        (tester) async {
      final controller = MyConsoleLogController()..setShowConsoleLog(true);

      await tester.pumpWidget(
        MaterialApp(
          home: MyConsoleLog(
            controller: controller,
            children: const [SizedBox()],
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsNothing);

      controller.setPathSaveLog('log.txt');
      await tester.pump();

      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });

  group('AnsiParser', () {
    test('parses plain text into single span', () {
      final parser = AnsiParser(false);
      parser.parse('Hello');

      expect(parser.spans, hasLength(1));
      final span = parser.spans.single;
      expect(span.text, 'Hello');
      expect(span.style?.color, isNull);
      expect(span.style?.backgroundColor, isNull);
    });

    test('applies foreground color and reset', () {
      final parser = AnsiParser(true);
      const esc = '\u001b';
      parser.parse('A $esc[38;5;196mB$esc[0m C');

      expect(parser.spans, hasLength(3));
      expect(parser.spans[1].text, 'B');
      expect(parser.spans[1].style?.color, Colors.red[300]);
      expect(parser.spans[2].text, ' C');
      expect(parser.spans[2].style?.color, Colors.black);
      expect(parser.spans[2].style?.backgroundColor, Colors.transparent);
    });

    test('applies background color and reset', () {
      final parser = AnsiParser(false);
      const esc = '\u001b';
      parser.parse('$esc[48;5;208mBG$esc[49mN');

      expect(parser.spans, hasLength(2));
      expect(parser.spans[0].text, 'BG');
      expect(parser.spans[0].style?.backgroundColor, Colors.orange[700]);
      expect(parser.spans[1].text, 'N');
      expect(parser.spans[1].style?.backgroundColor, Colors.transparent);
    });

    test('preserves invalid escape sequences as text', () {
      final parser = AnsiParser(false);
      const esc = '\u001b';
      parser.parse('A ${esc}X B');

      expect(parser.spans.single.text, 'A ${esc}X B');
    });

    test('uses dark mode color mapping', () {
      final parser = AnsiParser(true);
      const esc = '\u001b';
      parser.parse('$esc[38;5;12mBlue');

      expect(parser.spans, hasLength(1));
      expect(parser.spans[0].style?.color, Colors.lightBlue[300]);
    });
  });

  group('MyAnimatedLimiterItem', () {
    testWidgets('uses list animation when crossAxisCount is null',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: MyAnimatedLimiterItem(
            index: 0,
            child: Text('A'),
          ),
        ),
      );

      expect(find.byType(SlideAnimation), findsOneWidget);
      expect(find.byType(ScaleAnimation), findsNothing);
      expect(find.byType(FadeInAnimation), findsOneWidget);
    });

    testWidgets('uses grid animation when crossAxisCount is set',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: MyAnimatedLimiterItem(
            index: 0,
            crossAxisCount: 2,
            child: Text('A'),
          ),
        ),
      );

      expect(find.byType(ScaleAnimation), findsOneWidget);
      expect(find.byType(SlideAnimation), findsNothing);
      expect(find.byType(FadeInAnimation), findsOneWidget);
    });
  });

  group('MyLogListView', () {
    test('requires children or itemBuilder', () {
      expect(() => MyLogListView(), throwsA(isA<AssertionError>()));
    });

    testWidgets('builds items with itemBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: MyLogListView(
                itemCount: 3,
                itemBuilder: (context, index) => Text(
                  'Item $index',
                  key: ValueKey('item-$index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('item-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('item-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('item-2')), findsOneWidget);
    });

    testWidgets('builds separators with separatorBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: MyLogListView(
                itemCount: 3,
                itemBuilder: (context, index) => Text(
                  'Item $index',
                  key: ValueKey('item-$index'),
                ),
                separatorBuilder: (context, index) => Text(
                  'Sep $index',
                  key: ValueKey('sep-$index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('sep-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('sep-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('sep-2')), findsNothing);
    });

    testWidgets('applies paddingStartAndEnd for vertical list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyLogListView(
              paddingStartAndEnd: 8,
              children: const [
                Text('A'),
                Text('B'),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(top: 8),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(bottom: 8),
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies paddingStartAndEnd for horizontal list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyLogListView(
              scrollDirection: Axis.horizontal,
              paddingStartAndEnd: 8,
              children: const [
                Text('A'),
                Text('B'),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(left: 8),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(right: 8),
        ),
        findsOneWidget,
      );
    });
  });
}
