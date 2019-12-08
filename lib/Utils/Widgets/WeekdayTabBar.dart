import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// A costume tab bar for weekdays
class WeekdayTabBar extends StatefulWidget implements PreferredSizeWidget {
  /// The tab controller of the TabBarView
  final TabController controller;

  /// All possible weekdays
  final List<String> weekdays;

  /// Tab bar height
  final double height;

  // ignore: public_member_api_docs
  const WeekdayTabBar(
      {@required this.controller, @required this.weekdays, this.height = 50});

  @override
  State<StatefulWidget> createState() => WeekdayTabBarView();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

// ignore: public_member_api_docs
class WeekdayTabBarView extends State<WeekdayTabBar> {
  /// The current animation state (-1 to 1)
  double _scrollState;

  /// Index of the weekday to animate from
  double _animatingFrom;

  /// Index of the weekday to animate to
  double _animatingTo;

  /// Is animating between days
  bool _isAnimating = false;

  /// Is fading the left arrow
  bool _fadeLeft = false;

  /// Is fading the right arrow
  bool _fadeRight = false;

  /// The show/hide arrows options
  List<bool> _show = [true, true, true];

  /// All align animations for the weekdays positions
  List<Animation<Alignment>> _animations;

  /// All widths of the sort and long weekdays
  List<List<double>> _headerSizes;

  @override
  void initState() {
    // Init all values

    _scrollState = widget.controller.animation.value;
    _show = [
      (_animatingTo ?? widget.controller.index) > 0,
      true,
      (_animatingTo ?? widget.controller.index) + 1 < widget.weekdays.length,
    ];
    _initTabs();

    // Add all tab bar view listener
    widget.controller.animation.addListener(_animationUpdated);
    widget.controller.addListener(_statusUpdated);

    super.initState();
  }

  /// Initializes all align animations for the weekdays tabs
  void _initTabs() {
    _animations = [];
    final int maxWeekday = widget.weekdays.length - 1;
    for (double i = 0; i < widget.weekdays.length; i++) {
      _animations.add(
        AlignmentTween(
          begin: Alignment(i, 0),
          end: Alignment(i - maxWeekday / maxWeekday, 0),
        ).animate(widget.controller.animation),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.animation.removeListener(_animationUpdated);
    widget.controller.removeListener(_statusUpdated);
    super.dispose();
  }

  /// Resets animations data after finishing
  void _statusUpdated() {
    if (!widget.controller.indexIsChanging) {
      _animatingTo = null;
      _animatingFrom = null;
      _isAnimating = false;
      _fadeLeft = false;
      _fadeRight = false;
    }
  }

  /// Animation controller callback
  void _animationUpdated() {
    setState(() {
      if (_isAnimating) {
        _scrollState = widget.controller.animation.value - _animatingFrom;
      } else if (widget.controller.animation.value % 1 != 0) {
        _startAnimation();
      }
    });
  }

  /// Calculates the widget with of a given text
  double _calculateTextWidth(
      BuildContext context, BoxConstraints constraints, String rawText) {
    final text = TextSpan(text: rawText);
    final richTextWidget = Text.rich(text).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context)
      ..layout(constraints);
    final lastBox = renderObject
        .getBoxesForSelection(TextSelection(
            baseOffset: 0, extentOffset: text.toPlainText().length))
        .last;
    return lastBox.right;
  }

  /// Prepares values for the animation
  void _startAnimation() {
    _animatingFrom = widget.controller.index.toDouble();
    final double scrollState =
        widget.controller.animation.value - _animatingFrom;
    _animatingTo = scrollState < 0 ? _animatingFrom - 1 : _animatingFrom + 1;
    _isAnimating = true;

    final show = _show;
    _show = [
      (_animatingTo ?? widget.controller.index) > 0,
      true,
      (_animatingTo ?? widget.controller.index) + 1 < widget.weekdays.length,
    ];
    _fadeLeft = show[0] != _show[0];
    _fadeRight = show[2] != _show[2];
  }

  /// Return a widget to fade with the given [value] between the long and the short from of the [text]
  Widget _fadeTransition({double value, String text}) {
    final key = GlobalKey();
    return Stack(
      children: <Widget>[
        Opacity(
          key: key,
          opacity: value,
          child: Text(text.substring(0, 2), maxLines: 1),
        ),
        Container(
          width: null,
          child: Opacity(
            opacity: 1 - value,
            child: Text(text, maxLines: 1),
          ),
        ),
      ],
    );
  }

  /// Animates the size of the given [child] between the long and the short text form
  Widget _sizeTransition({Widget child, int position}) {
    double size;
    if (_isAnimating) {
      final bool wasShort = _animatingFrom != position;
      final bool willBeShort = _animatingTo != position;
      final double relativeScroll = _scrollState.abs();
      if (wasShort && !willBeShort) {
        size = lerpDouble(
          _headerSizes[position][1],
          _headerSizes[position][0],
          relativeScroll,
        );
      } else if (!wasShort && willBeShort) {
        size = lerpDouble(
          _headerSizes[position][0],
          _headerSizes[position][1],
          relativeScroll,
        );
      } else {
        size = _headerSizes[position][wasShort ? 1 : 0];
      }
    } else {
      final bool isShort = widget.controller.index != position;
      size = _headerSizes[position][isShort ? 1 : 0];
    }
    return Stack(children: <Widget>[
      SizedBox(
        width: size + 5,
        child: child,
      ),
      Positioned(
        right: 0,
        child: Container(
          height: widget.height,
          width: 7,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                Color.fromARGB(0, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ])),
        ),
      )
    ]);
  }

  /// Creates a tab with all needed animations
  Widget createTab(BuildContext context, int position) {
    final double value = min(_animations[position].value.x.abs(), 1);

    // Only create the object when it is in screen
    if (_animations[position].value.x.abs() > 1.5) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: AlignTransition(
        key: ValueKey(position),
        alignment: _animations[position],
        child: _sizeTransition(
          position: position,
          child: _fadeTransition(
            value: value,
            text: widget.weekdays[position],
          ),
        ),
      ),
    );
  }

  /// Calculates all sizes for each header
  void _calculateHeaderSizes(BuildContext context, BoxConstraints constraints) {
    _headerSizes = [];
    widget.weekdays.forEach((weekday) {
      _headerSizes.add([
        _calculateTextWidth(context, constraints, weekday),
        _calculateTextWidth(context, constraints, weekday.substring(0, 2)),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      /// First calculate the sizes for each title
      _calculateHeaderSizes(context, constraints);
      return Container(
        height: widget.height,
        color: Colors.white,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            // Left arrow
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: _show[0]
                    ? () =>
                        widget.controller.animateTo(widget.controller.index - 1)
                    : null,
                child: Opacity(
                  opacity: _fadeLeft
                      ? _show[0] ? _scrollState.abs() : 1 - _scrollState.abs()
                      : _show[0] ? 1 : 0,
                  child: Icon(
                    MdiIcons.arrowLeft,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            // All titles in a stack
            Expanded(
              flex: 70,
              child: Stack(
                children: [
                  ...widget.weekdays.map((d) {
                    return createTab(context, widget.weekdays.indexOf(d));
                  }).toList(),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: widget.height,
                      width: 5,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: const [
                            Color.fromARGB(255, 255, 255, 255),
                            Color.fromARGB(0, 255, 255, 255),
                          ])),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      height: widget.height,
                      width: 5,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: const [
                            Color.fromARGB(255, 255, 255, 255),
                            Color.fromARGB(0, 255, 255, 255),
                          ])),
                    ),
                  )
                ],
              ),
            ),
            // Right arrow
            Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: _show[2]
                      ? () => widget.controller
                          .animateTo(widget.controller.index + 1)
                      : null,
                  child: Opacity(
                    opacity: _fadeRight
                        ? _show[2] ? _scrollState.abs() : 1 - _scrollState.abs()
                        : _show[2] ? 1 : 0,
                    child: Icon(
                      MdiIcons.arrowRight,
                      color: Colors.black54,
                    ),
                  ),
                )),
          ],
        ),
      );
    });
  }
}
