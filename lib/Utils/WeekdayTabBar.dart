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
  double _scrollState;
  double _animatingFrom;
  double _animatingTo;
  bool _isAnimating = false;

  // Define arrow animations
  bool _fadeLeft = false;
  bool _fadeRight = false;
  bool _showLeft;
  bool _showRight;

  // Define all texts
  final GlobalKey _dayLeft = GlobalKey();
  final GlobalKey _dayMiddleOld = GlobalKey();
  final GlobalKey _dayMiddleNew = GlobalKey();
  final GlobalKey _dayRight = GlobalKey();

  // Define text Positions

  @override
  void initState() {
    // Init all values
    _scrollState = widget.controller.animation.value;
    _showLeft = (_animatingTo ?? widget.controller.index) > 0;
    _showRight =
        (_animatingTo ?? widget.controller.index) + 1 < widget.weekdays.length;

    // Add all tab bar view listener
    widget.controller.animation.addListener(_animationUpdated);
    widget.controller.addListener(_statusUpdated);
    print(_scrollState);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.animation.removeListener(_animationUpdated);
    widget.controller.removeListener(_statusUpdated);
    super.dispose();
  }

  void _statusUpdated() {
    if (!widget.controller.indexIsChanging) {
      _animatingTo = null;
      _animatingFrom = null;
      _isAnimating = false;
      _fadeLeft = false;
      _fadeRight = false;
    }
  }

  void _animationUpdated() {
    setState(() {
      if (_isAnimating) {
        _scrollState = widget.controller.animation.value - _animatingFrom;
      } else if (widget.controller.animation.value % 1 != 0) {
        _startAnimation();
      }
    });
    double centerPos;
    double currentPos;
    if (_dayMiddleOld.currentState != null) {
      centerPos = (_dayMiddleOld.currentState as RenderBox)
          .localToGlobal(Offset.zero)
          .dx;
    }
    if (_dayLeft.currentState != null) {
      currentPos = (_dayLeft.currentState as RenderBox).localToGlobal(Offset.zero).dx;
    }
    if (centerPos != null && currentPos != null) {
      print('$centerPos - $currentPos: ${centerPos - currentPos}');
    } else {
      print('reload');
    }
  }

  void _startAnimation() {
    _animatingFrom = widget.controller.index.toDouble();
    final double scrollState =
        widget.controller.animation.value - _animatingFrom;
    _animatingTo = scrollState < 0 ? _animatingFrom - 1 : _animatingFrom + 1;
    _isAnimating = true;

    final bool showLeft = (_animatingTo ?? widget.controller.index) > 0;
    _fadeLeft = showLeft != _showLeft;
    _showLeft = showLeft;
    final bool showRight =
        (_animatingTo ?? widget.controller.index) + 1 < widget.weekdays.length;
    _fadeRight = showRight != _showRight;
    _showRight = showRight;
  }

  /// Creates a stack for the text animation
  Widget textStack(bool left) {
    String weekday;
    final bool show = left ? _showLeft : _showRight;
    final bool fade = left ? _fadeLeft : _fadeRight;
    if (show ^ fade) {
      weekday = widget.weekdays[widget.controller.index + (left ? -1 : 1)];
    }

    return Stack(
      children: <Widget>[
        if (show ^ fade)
          Align(
            alignment: left ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              weekday,
              maxLines: 1,
              textDirection: left ? TextDirection.ltr : TextDirection.rtl,
            ),
          ),
        if ((show ^ fade) && _isAnimating)
          Align(
            alignment: left ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              weekday,
              maxLines: 1,
              textDirection: left ? TextDirection.ltr : TextDirection.rtl,
            ),
          ),
        if ((show ^ fade) && _isAnimating)
          Align(
            alignment: left ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              weekday,
              maxLines: 1,
              textDirection: left ? TextDirection.ltr : TextDirection.rtl,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Opacity(
              opacity: _fadeLeft
                  ? _showLeft ? _scrollState.abs() : 1 - _scrollState.abs()
                  : _showLeft ? 1 : 0,
              child: Icon(
                MdiIcons.arrowLeft,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            key: _dayLeft,
            flex: 5,
            child: textStack(true),
          ),
          Expanded(
            key: _dayMiddleOld,
            flex: 60,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Opacity(
                    opacity: _isAnimating ? 1 - _scrollState.abs() : 1,
                    child: Center(
                      child: Text(
                        widget.weekdays[
                            (_animatingFrom ?? widget.controller.index)
                                .toInt()],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: _scrollState.abs(),
                    child: Center(
                      child: Text(
                        _animatingTo != null
                            ? widget.weekdays[_animatingTo.toInt()]
                            : '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            key: _dayRight,
            flex: 5,
            child: textStack(false),
          ),
          Expanded(
            flex: 10,
            child: Opacity(
              opacity: _fadeRight
                  ? _showRight ? _scrollState.abs() : 1 - _scrollState.abs()
                  : _showRight ? 1 : 0,
              child: Icon(
                MdiIcons.arrowRight,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
