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

abstract class SubstitutionPlanDayListState
    extends State<SubstitutionPlanDayList> with SingleTickerProviderStateMixin {


  List<Substitution> getUnsortedList(SubstitutionPlanDay day) {
    List<Substitution> changes = day.data[widget.grade.toLowerCase()];
    changes
        .sort((Substitution c1, Substitution c2) => c1.unit.compareTo(c2.unit));
    return changes;
  }
}
