import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_log/my_log.dart';
import 'package:my_log/src/function/src.dart';

/// Learn more: https://pub.dev/packages/logger_plus

class MyConsoleLogWidget extends StatefulWidget {
  final bool dark;
  final Function()? onClose;
  final Function()? onZoomIn;
  final Function()? onZoomOut;
  final String? pathSaveLog;

  const MyConsoleLogWidget({super.key, this.dark = false, this.onClose, this.pathSaveLog, this.onZoomIn, this.onZoomOut});

  @override
  _MyConsoleLogWidgetState createState() => _MyConsoleLogWidgetState();
}

class RenderedEvent {
  final int id;
  final Level level;
  final TextSpan span;
  final String lowerCaseText;

  RenderedEvent(this.id, this.level, this.span, this.lowerCaseText);
}

class _MyConsoleLogWidgetState extends State<MyConsoleLogWidget> {
  final ListQueue<RenderedEvent> _renderedBuffer = ListQueue();
  List<RenderedEvent> _filteredBuffer = [];

  final _scrollController = ScrollController();
  final _filterController = TextEditingController();

  Level _filterLevel = Level.debug;
  double _logFontSize = 10;

  var _currentId = 0;
  bool _followBottom = true;

  final ListQueue<OutputEvent> _outputEventBuffer = ListQueue();

  void addOutputListener(OutputEvent event) {
    // myPrint(2);
    _outputEventBuffer.add(event);
    _outputEventBuffer.skip(cleanIndex);
    // myPrint(_outputEventBuffer.length);
    _renderedBuffer.clear();
    for (final event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
      // myPrint(_renderedBuffer.length);
    }
    _refreshFilter();
  }

  @override
  void dispose() {
    Logger.removeOutputListener(addOutputListener);
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        _filteredBuffer = newFilteredBuffer;
      }),
    );

    if (_followBottom) {
      // Future.delayed(const Duration(milliseconds: 10), (){
      _scrollToBottom();
      // });
    }
  }

  int cleanIndex = 0;
  void clean() {
    cleanIndex = _outputEventBuffer.length;
    _outputEventBuffer.clear();
    _renderedBuffer.clear();
    _filteredBuffer = [];
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
                child: MyListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  mainAxisSpacing: 0,
                  children: [
                    if (widget.pathSaveLog != null)
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (myEnviDevelop) myLog.setUp(path: widget.pathSaveLog);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${widget.pathSaveLog}"),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(_followBottom ? Icons.pause : Icons.play_arrow),
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: widget.dark ? Colors.black : Colors.grey[150],
                        width: 1600,
                        child: Scrollbar(
                          scrollbarOrientation: ScrollbarOrientation.left,
                          child: MyListView(
                            mainAxisSpacing: 0,
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              final logEntry = _filteredBuffer[index];
                              return SelectableText.rich(
                                logEntry.span,
                                contextMenuBuilder: (BuildContext c, EditableTextState e) {
                                  e.copySelection(SelectionChangedCause.longPress);
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        _followBottom = true;
      }),
    );

    try {
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

class LogBar extends StatelessWidget {
  final bool dark;
  final Widget child;

  const LogBar({super.key, required this.dark, required this.child});

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

class AnsiParser {
  static const TEXT = 0;
  static const BRACKET = 1;
  static const CODE = 2;

  final bool dark;

  AnsiParser(this.dark);

  Color? foreground;
  Color? background;
  List<TextSpan> spans = [];

  void parse(String s) {
    spans = [];
    var state = TEXT;
    StringBuffer? buffer;
    final text = StringBuffer();
    var code = 0;
    List<int> codes = [];

    for (var i = 0, n = s.length; i < n; i++) {
      final c = s[i];

      switch (state) {
        case TEXT:
          if (c == '\u001b') {
            state = BRACKET;
            buffer = StringBuffer(c);
            code = 0;
            codes = [];
          } else {
            text.write(c);
          }

        case BRACKET:
          buffer?.write(c);
          if (c == '[') {
            state = CODE;
          } else {
            state = TEXT;
            text.write(buffer);
          }

        case CODE:
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
            state = TEXT;
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
