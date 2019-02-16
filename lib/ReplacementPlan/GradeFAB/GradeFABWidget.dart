import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Keys.dart';
import 'GradeFABView.dart';

class GradeFab extends StatefulWidget {
  final Function(Function(String grade)) onSelectPressed;
  final Function(String grade) onSelected;

  GradeFab({this.onSelectPressed, this.onSelected});

  @override
  GradeFabView createState() => GradeFabView();
}

abstract class GradeFabState extends State<GradeFab>
    with SingleTickerProviderStateMixin {
  static List<String> grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];

  SharedPreferences sharedPreferences;
  bool isOpened = false;
  List<String> shownGrades;
  String grade;

  @override
  initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        grade = instance.getString(Keys.grade);
        shownGrades = (instance.getString(Keys.lastGrades) ?? '').split(':');
        if (shownGrades.length > 0) if (shownGrades[0].length == 0)
          shownGrades = [];
      });
    });
    super.initState();
  }

  // Update last selected grades
  void updatePrefs(String grade) {
    if (!shownGrades.contains(grade)) {
      setState(() {
        if (shownGrades.length == 0) {
          sharedPreferences.setString(Keys.lastGrades, grade);
          shownGrades.add(grade);
        } else if (shownGrades.length == 1) {
          sharedPreferences.setString(
              Keys.lastGrades, shownGrades[0] + ':' + grade);
          shownGrades.add(grade);
        } else {
          sharedPreferences.setString(
              Keys.lastGrades, shownGrades[1] + ':' + grade);
          shownGrades[0] = shownGrades[1];
          shownGrades[1] = grade;
        }
      });
    }
  }
}
