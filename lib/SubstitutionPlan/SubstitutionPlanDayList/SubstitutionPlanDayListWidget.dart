import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'SubstitutionPlanDayListView.dart';

/// A list of all substitutions of one day
class SubstitutionPlanDayList extends StatefulWidget {
  /// The day of the substitutions
  final SubstitutionPlanDay day;

  /// The grade to show
  final String grade;

  /// The index of the day in the substitution plan data
  final int dayIndex;

  // ignore: public_member_api_docs
  const SubstitutionPlanDayList({
    @required this.day,
    @required this.dayIndex,
    @required this.grade,
    Key key,
  }) : super(key: key);

  @override
  SubstitutionPlanDayListView createState() => SubstitutionPlanDayListView();
}

// ignore: public_member_api_docs
abstract class SubstitutionPlanDayListState
    extends State<SubstitutionPlanDayList> with SingleTickerProviderStateMixin {
  /// Returns the substitutions as non-personalized list
  List<Substitution> getUnsortedList(SubstitutionPlanDay day) {
    return day.data[widget.grade.toLowerCase()]
      ..sort((Substitution c1, Substitution c2) => c1.unit.compareTo(c2.unit));
  }
}
