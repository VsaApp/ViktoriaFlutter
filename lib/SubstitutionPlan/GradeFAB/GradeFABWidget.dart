import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'GradeFABView.dart';

/// Floating action button to select a grade for the substitution plan
class GradeFab extends StatefulWidget {
  /// Grade selected listener
  ///
  /// Function to recall after process the grade
  final Function(Function(String grade)) onSelectPressed;

  /// Grade selected listener
  final Function(String grade) onSelected;

  // ignore: public_member_api_docs
  const GradeFab({this.onSelectPressed, this.onSelected});

  @override
  GradeFabView createState() => GradeFabView();
}

// ignore: public_member_api_docs
abstract class GradeFabState extends State<GradeFab>
    with SingleTickerProviderStateMixin {
  /// All grades
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

  /// Defines if the FAB is opened
  bool isOpened = false;

  /// List of grades shortcuts
  List<String> shownGrades;

  /// The user grade
  String grade;

  @override
  void initState() {
    setState(() {
      grade = Storage.getString(Keys.grade);
      shownGrades = (Storage.getString(Keys.lastGrades) ?? '').split(':');
      if (shownGrades.isNotEmpty && shownGrades[0].isEmpty) {
        shownGrades = [];
      }
    });
    super.initState();
  }

  /// Remove a grade from last grades
  void removeGrade(String grade) {
    setState(() {
      final List<String> currentGrades =
          (Storage.getString(Keys.lastGrades) ?? '').split(':');
      print(currentGrades);
      String grades = '';
      currentGrades.forEach((String g) {
        if (g != grade) {
          grades += '$g:';
        }
      });
      print(grades);
      Storage.setString(Keys.lastGrades,
          grades.isNotEmpty ? grades.substring(0, grades.length - 1) : grades);
      shownGrades.remove(grade);
    });
  }

  /// Update last selected grades
  void updatePrefs(String grade) {
    if (!shownGrades.contains(grade)) {
      setState(() {
        if (shownGrades.isEmpty) {
          Storage.setString(Keys.lastGrades, grade);
          shownGrades.add(grade);
        } else {
          if (shownGrades.length == 1) {
            Storage.setString(Keys.lastGrades, '${shownGrades[0]}: $grade');
            shownGrades.add(grade);
          } else {
            Storage.setString(Keys.lastGrades, '${shownGrades[1]}: $grade');
            shownGrades[0] = shownGrades[1];
            shownGrades[1] = grade;
          }
        }
      });
    }
  }
}
