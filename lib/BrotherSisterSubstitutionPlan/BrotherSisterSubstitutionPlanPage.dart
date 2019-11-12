import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
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
    days = Data.substitutionPlan.days;
    controller = TabController(vsync: this, length: days.length);
    super.initState();
  }
}
