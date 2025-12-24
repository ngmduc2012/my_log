import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_log/my_log.dart';

/// Learn more: https://pub.dev/packages/logger_plus

MyLog myLog = MyLog();

/// `MyConsoleLogWidget` is a StatefulWidget that displays the actual console log content.///
/// It provides a scrollable view of log messages, along with controls for closing, zooming,
/// and potentially saving the log to a file.
///
/// This widget is typically used within a [MyConsoleLog] widget to display the console log overlay.
class MyConsoleLogWidget extends StatefulWidget {
  /// Determines whether the widget should use a dark theme.
  ///
  /// Defaults to `false` (light theme).
  final bool dark;

  /// A callback function that is called when the close button is pressed.
  final Function()? onClose;

  /// A callback function that is called when the zoom in button is pressed.
  final Function()? onZoomIn;

  /// A callback function that is called when the zoom out button is pressed.
  final Function()? onZoomOut;

  /// The file path where logs are saved (if applicable).
  ///
  /// If this is `null`, it indicates that logs are not being saved to a file.
  final String? pathSaveLog;

  /// Creates a [MyConsoleLogWidget].
  ///
  /// [dark] determines whether the widget should use a dark theme.
  /// [onClose] is a callback function that is called when the close button is pressed.
  /// [onZoomIn] is a callback function that is called when the zoom in button is pressed.
  /// [onZoomOut] is a callback function that is called when the zoom out button is pressed.
  /// [pathSaveLog] is the file path where logs are saved (if applicable).
  const MyConsoleLogWidget(
      {super.key,
      this.dark = false,
      this.onClose,
      this.pathSaveLog,
      this.onZoomIn,
      this.onZoomOut});

  @override
  MyConsoleLogWidgetState createState() => MyConsoleLogWidgetState();
}

/// `RenderedEvent` represents a single log event that has been formatted for display.
///
/// It contains the log's ID, level, the formatted text span, and the lowercase text
/// for filtering purposes.
class RenderedEvent {
  /// Creates a [RenderedEvent].
  ///
  /// [id] is a unique identifier for the log event.
  /// [level] is the severity level of the log event.
  /// [span] is the formatted text span for display.
  /// [lowerCaseText] is the lowercase version of the log text for filtering.
  RenderedEvent(this.id, this.level, this.span, this.lowerCaseText);

  /// A unique identifier for the log event.
  final int id;

  /// The severity level of the log event.
  final Level level;

  /// The formatted text span for display.
  final TextSpan span;

  /// The lowercaseversion of the log text for filtering.
  final String lowerCaseText;
}

/// `MyConsoleLogWidgetState` is the State class for[MyConsoleLogWidget].
///
/// It manages the internal state of the console log widget, including the list of
/// rendered log events, filtering, and scrolling.
class MyConsoleLogWidgetState extends State<MyConsoleLogWidget> {
  final ListQueue<RenderedEvent> _renderedBuffer = ListQueue();
  List<RenderedEvent> _filteredBuffer = [];

  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _filterController = TextEditingController();

  Level _filterLevel = Level.debug;
  double _logFontSize = 10;

  var _currentId = 0;
  bool _followBottom = true;

  final ListQueue<OutputEvent> _outputEventBuffer = ListQueue();

  @visibleForTesting
  int get filteredCount => _filteredBuffer.length;

  @visibleForTesting
  double get logFontSize => _logFontSize;

  @visibleForTesting
  bool get isFollowingBottom => _followBottom;

  @visibleForTesting
  int get renderedCount => _renderedBuffer.length;

  @visibleForTesting
  int get outputEventCount => _outputEventBuffer.length;

  @visibleForTesting
  double get scrollOffset =>
      _scrollController.hasClients ? _scrollController.offset : 0;

  @visibleForTesting
  double get maxScrollExtent =>
      _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 0;

  @visibleForTesting
  ScrollController get scrollController => _scrollController;

  @visibleForTesting
  int calculateFilteredCount({Level? level, String? text}) {
    final filterLevel = level ?? _filterLevel;
    final filterText = text ?? _filterController.text;
    final normalized = filterText.toLowerCase();
    return _renderedBuffer.where((it) {
      final logLevelMatches = it.level.index >= filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (normalized.isNotEmpty) {
        return it.lowerCaseText.contains(normalized);
      } else {
        return true;
      }
    }).length;
  }

  @visibleForTesting
  void setFilterForTesting({Level? level, String? text}) {
    if (level != null) {
      _filterLevel = level;
    }
    if (text != null) {
      _filterController.text = text;
    }
    _refreshFilter();
  }

  /// Adds a new log event to the console log.
  ///
  /// This method receives an [OutputEvent], adds it to the[_outputEventBuffer],
  /// renders it into a [RenderedEvent], and updates the displayed log.
  ///
  /// [event] - The [OutputEvent] to add to the log.
  void addOutputListener(OutputEvent event) {
    // Add the new event to the buffer.
    _outputEventBuffer.add(event);

    // Skip the cleanIndex in the buffer.
    _outputEventBuffer.skip(cleanIndex);

    // Clear the rendered buffer to rebuild it.
    _renderedBuffer.clear();

    // Re-render all events in the buffer.
    for (final event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
    }

    // Refresh the filter to update the displayed logs.
    _refreshFilter();
  }

  @override
  void dispose() {
    Logger.removeOutputListener(addOutputListener);
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Logger.addOutputListener(addOutputListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _renderedBuffer.clear();
    for (final event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
    }
    _refreshFilter();
  }

  void _refreshFilter() {
    final newFilteredBuffer = _renderedBuffer.where((it) {
      final logLevelMatches = it.level.index >= _filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (_filterController.text.isNotEmpty) {
        final filterText = _filterController.text.toLowerCase();
        return it.lowerCaseText.contains(filterText);
      } else {
        return true;
      }
    }).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _filteredBuffer = newFilteredBuffer;
      });
    });

    if (_followBottom) {
      // Future.delayed(const Duration(milliseconds: 10), (){
      _scrollToBottom();
      // });
    }
  }

  /// The index from which to start cleaning the [_outputEventBuffer].
  ///
  /// This is used to optimize the cleaning process by onlyremoving events
  /// that are older than this index.
  int cleanIndex = 0;

  /// Clears the console log.
  ///
  /// This method removes all log events from the buffers and updates the UI.
  void clean() {
    // Set the clean index to the current length of the output buffer.
    // This ensures that any new events added after cleaning will not be removed.
    cleanIndex = _outputEventBuffer.length;

    // Remove all events from the output buffer.
    _outputEventBuffer.clear();

    // Remove all rendered events.
    _renderedBuffer.clear();

    // Clear the filtered buffer.
    _filteredBuffer = [];

    // Update the UI to reflect the changes.
    setState(() {
      _filteredBuffer = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyLifeCircleWidget(
      onResumed: clean,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: widget.dark
            ? ThemeData(
                brightness: Brightness.dark,
              )
            : ThemeData(
                brightness: Brightness.light,
              ),
        home: Material(
          color: widget.dark ? Colors.blueGrey[900] : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LogBar(
                dark: widget.dark,
                child: MyLogListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  mainAxisSpacing: 0,
                  children: [
                    if (widget.pathSaveLog != null)
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (widget.pathSaveLog != null) {
                            myLog.setUp(path: widget.pathSaveLog);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${widget.pathSaveLog}"),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon:
                          Icon(_followBottom ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() {
                            _followBottom = !_followBottom;
                          }),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: clean,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: _scrollToBottom,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() {
                            _logFontSize++;
                          }),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() {
                            _logFontSize--;
                          }),
                        );
                      },
                    ),
                    if (widget.onZoomOut != null)
                      IconButton(
                        icon: const Icon(Icons.zoom_in_map),
                        onPressed: widget.onZoomOut,
                      ),
                    if (widget.onZoomIn != null)
                      IconButton(
                        icon: const Icon(Icons.zoom_out_map),
                        onPressed: widget.onZoomIn,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: widget.dark ? Colors.black : Colors.grey[150],
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalScrollController,
                      child: Container(
                        color: widget.dark ? Colors.black : Colors.grey[150],
                        width: 1600,
                        child: Scrollbar(
                          controller: _scrollController,
                          scrollbarOrientation: ScrollbarOrientation.left,
                          child: MyLogListView(
                            mainAxisSpacing: 0,
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              final logEntry = _filteredBuffer[index];
                              return SelectableText.rich(
                                logEntry.span,
                                contextMenuBuilder:
                                    (BuildContext c, EditableTextState e) {
                                  e.copySelection(
                                      SelectionChangedCause.longPress);
                                  return const SizedBox.shrink();
                                },
                                key: Key(logEntry.id.toString()),
                                style: TextStyle(fontSize: _logFontSize),
                              );
                            },
                            itemCount: _filteredBuffer.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              LogBar(
                dark: widget.dark,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 20),
                        controller: _filterController,
                        onChanged: (s) => _refreshFilter(),
                        decoration: const InputDecoration(
                          labelText: "Filter log output",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton(
                      value: _filterLevel,
                      items: const [
                        DropdownMenuItem(
                          value: Level.trace,
                          child: Text("TRACE"),
                        ),
                        DropdownMenuItem(
                          value: Level.debug,
                          child: Text("DEBUG"),
                        ),
                        DropdownMenuItem(
                          value: Level.info,
                          child: Text("INFO"),
                        ),
                        DropdownMenuItem(
                          value: Level.warning,
                          child: Text("WARNING"),
                        ),
                        DropdownMenuItem(
                          value: Level.error,
                          child: Text("ERROR"),
                        ),
                        DropdownMenuItem(
                          value: Level.fatal,
                          child: Text("FATAL"),
                        ),
                      ],
                      onChanged: (value) {
                        _filterLevel = value!;
                        _refreshFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _followBottom = true;
      });
    });

    try {
      if (!_scrollController.hasClients) {
        return;
      }
      final scrollPosition = _scrollController.position;
      _scrollController.jumpTo(scrollPosition.maxScrollExtent);
    } catch (e) {
      print(e);
    }
  }

  RenderedEvent _renderEvent(OutputEvent event) {
    final parser = AnsiParser(widget.dark);
    final text = event.lines.join('\n');
    parser.parse(text);
    return RenderedEvent(
      _currentId++,
      event.level,
      TextSpan(children: parser.spans),
      text.toLowerCase(),
    );
  }

  // @override
  // FutureOr<void>? afterFirstLayout(BuildContext context) {
  //   _scrollControllerForView.jumpTo(150);
  // }
}

/// `LogBar` is a StatelessWidget that provides a styled container for log-related content.
///
/// It can be used to wrap a widget that displays log information, providing a consistent
/// look and feel. It supports both light and dark themes.
class LogBar extends StatelessWidget {
  /// Creates a [LogBar].
  ///
  /// [dark] determines whether the barshould use a dark theme.
  /// [child] is the widget to be displayed within the bar.
  const LogBar({
    super.key,
    required this.dark,
    required this.child,
  });

  /// Determines whether the bar should use a dark theme.
  ///
  /// If `true`, the bar will have a dark background and light text.
  /// If `false`, the bar will have a light background and dark text.
  final bool dark;

  /// The widget to be displayed within the bar.
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (!dark)
              BoxShadow(
                color: Colors.grey[400]!,
                blurRadius: 3,
              ),
          ],
        ),
        child: Material(
          color: dark ? Colors.blueGrey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// `AnsiParser` is a utility class for parsing ANSI escape codes within a string.
///
/// It is used to interpret ANSI codes that define text styling, such as colors,
/// and convert them into Flutter's [TextSpan] objects for rich text display.
///
/// This class maintains the current foreground and background colors, and
/// accumulates [TextSpan] objects asit parses the input string.
class AnsiParser {
  /// Represents the state of parsing plain text.
  static const textState = 0;

  /// Represents the state of parsing within a bracketed sequence.
  static const bracketState = 1;

  /// Represents the state of parsing a code within a bracketed sequence.
  static const codeState = 2;

  /// Indicates whether the parser should use a dark theme for default colors.
  final bool dark;

  /// Creates an [AnsiParser].
  ///
  /// [dark] determines whether the parser shoulduse a dark theme for default colors.
  AnsiParser(this.dark);

  /// The current foreground color being parsed.
  Color? foreground;

  /// The current background color being parsed.
  Color? background;

  /// The list of [TextSpan] objects generated during parsing.
  List<TextSpan> spans = [];

  /// Parses the given string [s] for ANSI escape codes and generates a list of [TextSpan] objects.
  ///
  /// This method resets the [spans] list before parsing.
  ///
  /// [s] - The string to parse for ANSI escape codes.
  void parse(String s) {
    spans = [];
    var state = textState;
    StringBuffer? buffer;
    final text = StringBuffer();
    var code = 0;
    List<int> codes = [];

    for (var i = 0, n = s.length; i < n; i++) {
      final c = s[i];

      switch (state) {
        case textState:
          if (c == '\u001b') {
            state = bracketState;
            buffer = StringBuffer(c);
            code = 0;
            codes = [];
          } else {
            text.write(c);
          }

        case bracketState:
          buffer?.write(c);
          if (c == '[') {
            state = codeState;
          } else {
            state = textState;
            text.write(buffer);
          }

        case codeState:
          buffer?.write(c);
          final codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans.add(createSpan(text.toString()));
              text.clear();
            }
            state = textState;
            if (c == 'm') {
              codes.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }
      }
    }

    spans.add(createSpan(text.toString()));
  }

  /// Handles a list of ANSI codes.
  ///
  /// This method processes a list of integer codes that represent ANSI escape
  /// sequences. It updates the foreground and background colors, and other
  /// text styling properties based on the codes.
  ///
  /// If the list of codes is empty, it defaults to a single code of `0` (reset).
  ///
  /// [codes] - The list of ANSI codes to handle.
  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0, true);
        background = getColor(0, false);
      case 38:
        foreground = getColor(codes[2], true);
      case 39:
        foreground = getColor(0, true);
      case 48:
        background = getColor(codes[2], false);
      case 49:
        background = getColor(0, false);
    }
  }

  /// Gets a [Color] based on the given ANSI color code.
  ///
  /// This method maps ANSI color codes to Flutter [Color] objects. It takes
  /// into account whether the color is for the foreground or background, and
  /// whether a dark theme is being used.
  ///
  /// [colorCode] - The ANSI color code to map.
  /// [foreground] - `true` if the color is for the foreground, `false` for the background.
  /// Returns a [Color] object if a mapping exists, otherwise `null`.
  Color? getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 0:
        return foreground ? Colors.black : Colors.transparent;
      case 12:
        return dark ? Colors.lightBlue[300] : Colors.indigo[700];
      case 208:
        return dark ? Colors.orange[300] : Colors.orange[700];
      case 196:
        return dark ? Colors.red[300] : Colors.red[700];
      case 199:
        return dark ? Colors.pink[300] : Colors.pink[700];
    }
    return null;
  }

  /// Creates a [TextSpan] with the given text and current styling.
  ////// This method creates a [TextSpan] object with the specified [text] and
  /// applies the current foreground and background colors to its style.
  ///
  /// [text] - The text content of the span.
  /// Returns a [TextSpan] object with the specified text and styling.
  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
