import 'package:flutter/material.dart';

import '../SubstitutionPlan/SubstitutionPlanData.dart' as substitutionPlan;
import '../SubstitutionPlan/SubstitutionPlanModel.dart';
import '../Timetable/TimetableData.dart' as timetable;
import 'BrotherSisterSubstitutionPlanView.dart';

class BrotherSisterSubstitutionPlanPage extends StatefulWidget {
  final String grade;

  BrotherSisterSubstitutionPlanPage({Key key, @required this.grade})
      : super(key: key);

  @override
  BrotherSisterSubstitutionPlanPageView createState() =>
      BrotherSisterSubstitutionPlanPageView();
}

abstract class BrotherSisterSubstitutionPlanPageState
    extends State<BrotherSisterSubstitutionPlanPage>
    with SingleTickerProviderStateMixin {
  List<SubstitutionPlanDay> days;
  TabController controller;

  @override
  void initState() {
    timetable.download(widget.grade, true).then((days1) {
      setState(() {
        days = substitutionPlan.load(days1, true);
        controller = TabController(vsync: this, length: days.length);
      });
    });
    super.initState();
  }
}
