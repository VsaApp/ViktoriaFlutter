import 'package:flutter/material.dart';

import '../ReplacementPlanModel.dart';
import 'ReplacementPlanDayListView.dart';

class ReplacementPlanDayList extends StatefulWidget {
  ReplacementPlanDay day;
  final bool sort;
  final bool temp;
  final String grade;
  final int dayIndex;

  ReplacementPlanDayList({
    Key key,
    @required this.day,
    @required this.dayIndex,
    @required this.sort,
    @required this.grade,
    this.temp = false,
  }) : super(key: key);

  @override
  ReplacementPlanDayListView createState() => ReplacementPlanDayListView();
}

abstract class ReplacementPlanDayListState extends State<ReplacementPlanDayList>
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

  List<Change> getUnsortedList(ReplacementPlanDay day) {
    List<Change> changes = [
      day.myChanges,
      day.undefinedChanges,
      day.otherChanges
    ].expand((x) => x).toList();
    changes.sort((Change c1, Change c2) => c1.unit.compareTo(c2.unit));
    return changes;
  }
}
