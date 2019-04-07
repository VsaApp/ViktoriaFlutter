import 'package:flutter/material.dart';

import '../../Keys.dart';
import '../../Storage.dart';
import 'GradeFABWidget.dart';

class GradeFabView extends GradeFabState {
  AnimationController animationController;
  Animation<Color> buttonColor;
  Animation<double> animateIcon;
  Animation<double> translateButton;
  Curve curve = Curves.easeOut;
  double fabHeight = 50.0;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        buttonColor = ColorTween(
          begin: Theme.of(context).primaryColor,
          end: Color(0xFF275600),
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(
            0.00,
            1.00,
            curve: Curves.linear,
          ),
        ));
        translateButton = Tween<double>(
          begin: fabHeight,
          end: 0,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(
            0.0,
            0.75,
            curve: curve,
          ),
        ));
      });
    });
    super.initState();
  }

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    isOpened = !isOpened;
  }

  // Smaller select FAB
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

  // Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'main',
        backgroundColor: buttonColor.value,
        onPressed: () {
          if (GradeFabState.grades.length > 0)
            animate();
          else
            widget.onSelectPressed(updatePrefs);
        },
        tooltip: 'Grade',
        child: AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.menu_close,
          progress: animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (translateButton == null || buttonColor == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            translateButton.value * (shownGrades.length + 1),
            0.0,
          ),
          child: select(),
        ),
        toggle(),
      ]..insertAll(
          1,
          shownGrades.map((grade) {
            return Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  translateButton.value *
                      (shownGrades.length - shownGrades.indexOf(grade)),
                  0.0,
                ),
                child: Container(
                  // Create FAB for every grade
                  child: Dismissible(
                    key: Key(grade),
                    onDismissed: (direction) => removeGrade(grade),
                    child: FloatingActionButton(
                      heroTag: 'replacementplan-' + grade,
                      mini: true,
                      onPressed: () {
                        animate();
                        List<String> prefValue =
                        (Storage.getString(Keys.lastGrades) ?? '').split(':');
                        if (prefValue.length > 0) if (prefValue[0].length == 0)
                          prefValue = [];
                        if (!prefValue.contains(grade)) {
                          setState(() {
                            if (prefValue.length == 0) {
                              Storage.setString(Keys.lastGrades, grade);
                              GradeFabState.grades[1] = grade;
                            } else if (prefValue.length == 1) {
                              Storage.setString(
                                  Keys.lastGrades, prefValue[0] + ':' + grade);
                              GradeFabState.grades[1] = grade;
                            } else {
                              Storage.setString(
                                  Keys.lastGrades, prefValue[1] + ':' + grade);
                              GradeFabState.grades[0] = GradeFabState.grades[1];
                              GradeFabState.grades[1] = grade;
                            }
                          });
                        }
                        widget.onSelected(grade);
                      },
                      tooltip: grade,
                      child: Text(grade, style: TextStyle(color: Colors.white)),
                    )
                  )
                ));
          }).toList(),
        ),
    );
  }
}
