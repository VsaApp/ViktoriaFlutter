import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'SubstitutionPlanDayListView.dart';

class SubstitutionPlanDayList extends StatefulWidget {
  SubstitutionPlanDay day;
  final bool sort;
  final bool temp;
  final String grade;
  final int dayIndex;

  SubstitutionPlanDayList({
    Key key,
    @required this.day,
    @required this.dayIndex,
    @required this.sort,
    @required this.grade,
    this.temp = false,
  }) : super(key: key);

  @override
  SubstitutionPlanDayListView createState() => SubstitutionPlanDayListView();
}

abstract class SubstitutionPlanDayListState extends State<SubstitutionPlanDayList>
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

  List<Substitution> getUnsortedList(SubstitutionPlanDay day) {
    List<Substitution> changes = [
      day.myChanges,
      day.undefinedChanges,
      day.otherChanges
    ].expand((x) => x).toList();
    changes.sort((Substitution c1, Substitution c2) => c1.unit.compareTo(c2.unit));
    return changes;
  }
}
