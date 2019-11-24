import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'GradeFABWidget.dart';

// ignore: public_member_api_docs
class GradeFabView extends GradeFabState {
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 50;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _buttonColor = ColorTween(
          begin: Theme.of(context).primaryColor,
          end: Color(0xFF275600),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0,
            1,
            curve: Curves.linear,
          ),
        ));
        _translateButton = Tween<double>(
          begin: _fabHeight,
          end: 0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0,
            0.75,
            curve: _curve,
          ),
        ));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Animate the floating action buttons
  void animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  /// Small select FAB
  Widget select() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'select',
        mini: true,
        onPressed: () {
          animate();
          widget.onSelectPressed(updatePrefs);
        },
        tooltip: 'Select',
        child: Icon(Icons.playlist_add, color: Colors.white),
      ),
    );
  }

  /// Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'main',
        backgroundColor: _buttonColor.value,
        onPressed: () {
          if (GradeFabState.grades.isNotEmpty) {
            animate();
          } else {
            widget.onSelectPressed(updatePrefs);
          }
        },
        tooltip: 'Grade',
        child: AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_translateButton == null || _buttonColor == null) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0,
            _translateButton.value * (shownGrades.length + 1),
            0,
          ),
          child: select(),
        ),
        toggle(),
      ]..insertAll(
          1,
          shownGrades.map((grade) {
            return Transform(
                transform: Matrix4.translationValues(
                  0,
                  _translateButton.value *
                      (shownGrades.length - shownGrades.indexOf(grade)),
                  0,
                ),
                child: Container(
                    // Create FAB for every grade
                    child: Dismissible(
                        key: Key(grade),
                        onDismissed: (direction) => removeGrade(grade),
                        child: FloatingActionButton(
                          heroTag: 'substitutionPlan-$grade',
                          mini: true,
                          onPressed: () {
                            animate();
                            List<String> prefValue =
                                (Storage.getString(Keys.lastGrades) ?? '')
                                    .split(':');
                            if (prefValue.isNotEmpty && prefValue[0].isEmpty) {
                              prefValue = [];
                            }
                            if (!prefValue.contains(grade)) {
                              setState(() {
                                if (prefValue.isEmpty) {
                                  Storage.setString(Keys.lastGrades, grade);
                                  GradeFabState.grades[1] = grade;
                                } else if (prefValue.length == 1) {
                                  Storage.setString(Keys.lastGrades,
                                      '${prefValue[0]}:$grade');
                                  GradeFabState.grades[1] = grade;
                                } else {
                                  Storage.setString(Keys.lastGrades,
                                      '${prefValue[1]}:$grade');
                                  GradeFabState.grades[0] =
                                      GradeFabState.grades[1];
                                  GradeFabState.grades[1] = grade;
                                }
                              });
                            }
                            widget.onSelected(grade);
                          },
                          tooltip: grade,
                          child: Text(grade,
                              style: TextStyle(color: Colors.white)),
                        ))));
          }).toList(),
        ),
    );
  }
}
